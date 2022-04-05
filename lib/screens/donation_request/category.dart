import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/screens/donation_request/coming_soon.dart';
import 'package:ngo/screens/donation_request/food_donate.dart';
import 'package:ngo/widgets/button.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int screenIndex = 0;

  static List<Widget> screens = [
    const FoodDonation(),
    Container(),
    const ComingSoon(),
    const ComingSoon(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text(
          'Category',
          style: AppTheme.title,
        ),
        toolbarHeight: 60,
      ),
      body: screenIndex == 0 ? scrollingColumn() : expandedColumn(),
    );
  }

  Widget scrollingColumn() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              option(Icons.fastfood_outlined, 'Food', 0),
              option(Icons.checkroom_outlined, 'Clothing', 1),
              option(Icons.cast_for_education_outlined, 'Education', 2),
              option(Icons.more_horiz_outlined, 'More', 3),
            ],
          ),
          const SizedBox(height: 18),
          screens[screenIndex],
        ],
      ),
    );
  }

  Widget expandedColumn() {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            option(Icons.fastfood_outlined, 'Food', 0),
            option(Icons.checkroom_outlined, 'Clothing', 1),
            option(Icons.cast_for_education_outlined, 'Education', 2),
            option(Icons.more_horiz_outlined, 'More', 3),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(child: screens[screenIndex]),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Button('Next', () {}),
        ),
      ],
    );
  }

  Widget option(IconData iconData, String label, int index) {
    return GestureDetector(
      onTap: () {
        setState(
          () {
            screenIndex = index;
          },
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  screenIndex == index ? AppTheme.button : AppTheme.background,
            ),
            child: Icon(
              iconData,
              color: screenIndex == index
                  ? const Color(0xFFE7E6FF)
                  : const Color(0xFF0f096d),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0f096d),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
