import 'package:flutter/material.dart';
import 'package:ngo/models/category_field_modal.dart';
import 'package:ngo/screens/donation_request/user_info.dart';

import 'package:ngo/widgets/button.dart';
import 'package:ngo/widgets/category_field.dart';
import 'package:ngo/widgets/item_images.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../providers/submit_page_provider.dart';

class FoodDonation extends StatefulWidget {
  const FoodDonation({Key? key}) : super(key: key);

  @override
  _FoodDonationState createState() => _FoodDonationState();
}

class _FoodDonationState extends State<FoodDonation> {
  @override
  Widget build(BuildContext context) {
    final manager = Provider.of<SubmitPageProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header(),
          const SizedBox(height: 8.0),
          Consumer<SubmitPageProvider>(
            builder: (BuildContext context, value, Widget? child) {
              return CategoryField(
                manager: manager,
                // controllers: _controllers,
              );
            },
          ),
          const SizedBox(height: 12.0),
          addFieldBtn(manager),
          const SizedBox(height: 12.0),
          CategoryImages(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Button('Next', () {
              if (manager.foodControllerIsEmpty &&
                      manager.quantityControllerIsEmpty ||
                  manager.items.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Add item to donate!'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (manager.foodControllerIsEmpty &&
                  !manager.quantityControllerIsEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Specify the type of product'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else if (!manager.foodControllerIsEmpty &&
                  manager.quantityControllerIsEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Specify the quantity of product'),
                  backgroundColor: Theme.of(context).errorColor,
                ));
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfo(),
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Types of food',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            'Quantity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget addFieldBtn(SubmitPageProvider manager) {
    return TextButton(
      onPressed: () {
        if (manager.foodControllerIsEmpty &&
            manager.quantityControllerIsEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Add item to donate!'),
            backgroundColor: Theme.of(context).errorColor,
          ));
        } else if (manager.foodControllerIsEmpty &&
            !manager.quantityControllerIsEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Specify the type of product'),
            backgroundColor: Theme.of(context).errorColor,
          ));
        } else if (!manager.foodControllerIsEmpty &&
            manager.quantityControllerIsEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Specify the quantity of product'),
            backgroundColor: Theme.of(context).errorColor,
          ));
        } else {
          manager.addItem(
            CategoryFieldModal(id: const Uuid().v1()),
          );
          manager
              .addTypeFoodControllerToControllerList(TextEditingController());
          manager
              .addQuantityControllerToControllerList(TextEditingController());

          // _controllers.add(TextEditingController());
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.add),
          Text('ADD'),
        ],
      ),
    );
  }
}
