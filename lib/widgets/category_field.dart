import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/providers/submit_page_provider.dart';

class CategoryField extends StatefulWidget {
  const CategoryField({
    Key? key,
    required this.manager,
    // required this.controllers,
  }) : super(key: key);
  final SubmitPageProvider manager;
  // final List<TextEditingController> controllers;

  @override
  _CategoryFieldState createState() => _CategoryFieldState();
}

class _CategoryFieldState extends State<CategoryField> {
  final List<String> foodTypes = const [
    'Fruits/Vegetables',
    'Dairy Products',
    'Cooked Food',
    'Packed Food',
  ];
  final List<String> quantityTypes = const ['Kg', 'Per'];

  void showModal(BuildContext context, Map<String, dynamic> item,
      TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Category',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 14.0,
                    runSpacing: 14.0,
                    children: [
                      buildCategoryOption(foodTypes[0], item, controller),
                      buildCategoryOption(foodTypes[1], item, controller),
                      buildCategoryOption(foodTypes[2], item, controller),
                      buildCategoryOption(foodTypes[3], item, controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.manager.items;
    final typeFoodControllers = widget.manager.typeFoodControllers;
    final quantityControllers = widget.manager.quantityControllers;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final typeFoodController = typeFoodControllers[index];
        final quantityController = quantityControllers[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Dismissible(
            key: Key(item['id']),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 50.0,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              widget.manager.deleteItem(item['id']);
              widget.manager.removeTypeFoodControllerFromControllerList(
                  typeFoodController);
              widget.manager.removeQuantityControllerFromControllerList(
                  quantityController);
              if (widget.manager.items.isEmpty) {
                widget.manager.foodControllerIsEmpty = false;
                widget.manager.quantityControllerIsEmpty = false;
              }
            },
            child: Row(
              children: [
                Expanded(
                    child:
                        inputField(item, typeFoodController, widget.manager)),
                const SizedBox(width: 10.0),
                Expanded(
                    child: inputFieldOther(
                        item, quantityController, widget.manager)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget inputField(Map<String, dynamic> item, TextEditingController controller,
      SubmitPageProvider manager) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
          ),
        ],
        color: AppTheme.nearlyWhite,
      ),
      child: TextFormField(
        readOnly: true,
        autovalidateMode: AutovalidateMode.always,
        validator: (text) {
          if (text == null || text.isEmpty) {
            manager.foodControllerIsEmpty = true;
          } else if (text.isNotEmpty) {
            manager.foodControllerIsEmpty = false;
          }
        },
        cursorColor: Colors.black,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        ),
        controller: controller,
        style: const TextStyle(fontSize: 14),
        onTap: () => showModal(context, item, controller),
      ),
    );
  }

  Widget inputFieldOther(Map<String, dynamic> item,
      TextEditingController controller, SubmitPageProvider manager) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 1),
          ),
        ],
        color: AppTheme.nearlyWhite,
      ),
      child: TextFormField(
        cursorColor: Colors.black,
        controller: controller,
        autovalidateMode: AutovalidateMode.always,
        validator: (text) {
          if (text == null || text.isEmpty) {
            manager.quantityControllerIsEmpty = true;
          } else if (text.isNotEmpty) {
            manager.quantityControllerIsEmpty = false;
          }
        },
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          suffix: TextButton(
            child: Text(item['quantityType']),
            onPressed: () {
              if (item['quantityType'] == quantityTypes[0]) {
                setState(() => item['quantityType'] = quantityTypes[1]);
              } else {
                setState(() => item['quantityType'] = quantityTypes[0]);
              }
            },
          ),
        ),
        onChanged: (value) => item['foodQuantity'] = double.parse(value),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  InkWell buildCategoryOption(String text, Map<String, dynamic> item,
      TextEditingController controller) {
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () {
        setState(() => item['foodType'] = text);
        controller.text = item['foodType'];
        Navigator.pop(context);
      },
      child: Ink(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppTheme.background.withOpacity(0.2),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
