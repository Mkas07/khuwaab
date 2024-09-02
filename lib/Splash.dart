import 'package:flutter/material.dart';
import 'main.dart'; // Import your main.dart file to access routes

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // Background color
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
            ),
            // Image with blend mode and BoxFit.contain
            Center(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.1), // The color to blend with
                  BlendMode.lighten, // The blend mode
                ),
                child: Image.asset(
                  'Assets/Screenshot_2024-07-29_201558-removebg-preview.png', // Your image asset
                  fit: BoxFit.contain, // Prevents image from enlarging too much
                  width: 600, // You can set a specific width
                  height: 600, // You can set a specific height
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
