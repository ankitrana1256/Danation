import 'package:flutter/material.dart';
import 'package:ngo/authentication/components/forgot_password.dart';
import 'package:ngo/authentication/components/settings.dart';
import 'package:ngo/authentication/components/verify_user.dart';
import 'package:ngo/flow/splash.dart';
import 'package:ngo/flow/wrapper.dart';
import 'package:ngo/introduction/introductionanimation.dart';
import 'package:ngo/providers/bottom_navigation_bar.dart';
import 'package:ngo/providers/chat_screen_provider.dart';
import 'package:ngo/providers/donation_requests_provder.dart';
import 'package:ngo/providers/submit_page_provider.dart';
import 'package:ngo/providers/user_state_provider.dart';
import 'package:ngo/screens/donation_request/category.dart';
import 'package:provider/provider.dart';
import 'apptheme.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication/signup.dart';
import 'homepage/home_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then(
    (_) {
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BottomNavigationProvider>(
              create: (context) => BottomNavigationProvider(),
            ),
            ChangeNotifierProvider<ChatScreenProvider>(
              create: (context) => ChatScreenProvider(),
              // child: ChatScreen(),
            ),
            ChangeNotifierProvider<DonationRequestsCardProvider>(
              create: (context) => DonationRequestsCardProvider(),
              // child: ChatScreen(),
            ),
            ChangeNotifierProvider<SubmitPageProvider>(
              create: (context) => SubmitPageProvider(),
              // child: ChatScreen(),
            ),
            ChangeNotifierProvider<UserTypeProvider>(
              create: (context) => UserTypeProvider(),
            )
          ],
          child: MaterialApp(
            title: 'Danation',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'WorkSans',
              textTheme: AppTheme.textTheme,
              platform: TargetPlatform.iOS,
            ),
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const Splash(),
              '/wrapper': (context) => const Wrapper(),
              '/homepage': (context) => const HomePage(),
              '/login': (context) => const LoginPage(),
              '/intro': (context) => const IntroductionAnimationScreen(),
              '/verify': (context) => const VerifyUser(),
              '/forgotPass': (context) => const ForgotPassword(),
              '/usersettings': (context) => const UserProfile(),
              '/category': (context) => const CategoryScreen()
            },
          ),
        ),
      );
    },
  );
}


// HR/2021/0285383