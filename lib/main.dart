import 'package:flutter/material.dart';
import 'package:kfyp2/post_ad.dart';
import 'package:kfyp2/profile.dart';
import 'splash.dart'; // Import the splash screen file
import 'login.dart'; // Import the login screen file
import 'signup.dart'; // Import the signup screen file
import 'homescreen.dart'; // Import the home screen file
import 'predict.dart';
import 'aboutus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ad.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set splash screen as the initial route
      routes: {
        '/': (context) => SplashScreen(), // Initial route
        '/home': (context) => MarketPlaceScreen(), // Home route
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/predict': (context) => HousePricePredictionScreen(),
        '/about': (context) => AboutUsScreen(),
        '/post_ad':(context)=> PostAdScreen(),
        '/profile':(context)=> ProfileScreen(),
        '/ad_details': (context) => AdDetailsScreen(),

      },
    );
  }
}
