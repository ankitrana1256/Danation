import 'package:flutter/material.dart';
import 'package:ngo/apptheme.dart';
import 'package:ngo/flow/to_ngo_profile.dart';
import 'package:ngo/flow/wrapper.dart';
import 'package:ngo/homepage/home_page.dart';
import 'package:ngo/homepage/home_page2.dart';
import 'package:ngo/providers/bottom_navigation_bar.dart';
import 'package:ngo/screens/chat/people_screen.dart';
import 'package:ngo/screens/donation_request/category.dart';
import 'package:ngo/screens/ngo_donation_requests.dart';
import 'package:provider/provider.dart';
import 'authentication/components/settings.dart';

class ShowBottomNavigationBar extends StatefulWidget {
  final String? ngoName;
  final userType userstate;
  const ShowBottomNavigationBar(
      {Key? key, this.ngoName, required this.userstate})
      : super(key: key);

  @override
  _ShowBottomNavigationBarState createState() =>
      _ShowBottomNavigationBarState();
}

class _ShowBottomNavigationBarState extends State<ShowBottomNavigationBar> {
  int currentIndex = 0;

  late final PageController _pageController =
      PageController(initialPage: currentIndex);
  PageStorageBucket bucket = PageStorageBucket();

  var currentTab = [
    const HomePage(
      key: PageStorageKey('map'),
    ),
    const AllUsersChatList(
      key: PageStorageKey('people'),
    ),
    const CategoryScreen(
      key: PageStorageKey('category'),
    ),
    const UserProfile(
      key: PageStorageKey('UserProfile'),
    )
  ];

  var currentTab2 = [
    const HomePage2(
      key: PageStorageKey('map'),
    ),
    const AllUsersChatList(
      key: PageStorageKey('people'),
    ),
    const NgoDonationsRequests(
      key: PageStorageKey('category'),
    ),
    const ToNgoProfile(
      key: PageStorageKey('UserProfile'),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Consumer<BottomNavigationProvider>(builder: (context, value, child) {
        return PageView(
          children:
              widget.userstate == userType.donor ? currentTab : currentTab2,
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
        );
      }),
      bottomNavigationBar: Consumer<BottomNavigationProvider>(
        builder: (context, value, child) {
          return BottomNavigationBar(
            elevation: 5,
            type: BottomNavigationBarType.fixed,
            fixedColor: Colors.deepPurple,
            unselectedItemColor: AppTheme.button,
            backgroundColor: AppTheme.nearlyWhite,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(
                () {
                  currentIndex = index;
                  _pageController.jumpToPage(currentIndex);
                },
              );
            },
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.map), label: 'Map'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.chat), label: 'Chat'),
              widget.userstate == userType.donor
                  ? const BottomNavigationBarItem(
                      icon: Icon(Icons.accessibility_new_rounded),
                      label: 'Donate')
                  : const BottomNavigationBarItem(
                      icon: Icon(Icons.request_page), label: 'Request'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
          );
        },
      ),
    );
  }
}
