import 'package:flutter/material.dart';
import 'bottomnav.dart';
import 'appbar.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'About Us',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF082430),
                  fontFamily: 'Gupter Medium',
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Khuwaab Realty Pro, your ultimate real estate companion. We are a team of passionate final-year students from Bahria University Karachi Campus, dedicated to revolutionizing the way you navigate the real estate market. Our team comprises Muhammad Khurram Aimad, Syed Faris, and Isfandyar Khurram, guided by our esteemed supervisor, Ms. Hadiqua Fazal.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Regular',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Our Vision',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Medium',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'At Khuwaab Realty Pro, we aim to simplify the property buying, selling, and renting processes through innovative technology and data-driven insights. Our app is designed to provide users with comprehensive market information and a seamless user experience, ensuring informed decision-making.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Regular',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'The App',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Medium',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Khuwaab Realty Pro offers a range of features to cater to all your real estate needs:',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Regular',
              ),
            ),
            SizedBox(height: 10),
            BulletPoint(text: 'Login and Signup: Securely create accounts and log in to access the app\'s features.'),
            BulletPoint(text: 'Marketplace: Browse and list properties for sale or rent with ease.'),
            BulletPoint(text: 'Index: View current house prices, helping you stay ahead in the market.'),
            BulletPoint(text: 'Geospatial Insights: Explore an interactive map with price zones, identifying high, medium, and low property price areas.'),
            SizedBox(height: 20),
            Text(
              'Join us on this journey to make real estate simple, transparent, and efficient with Khuwaab Realty Pro.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Regular',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.brightness_1,
            size: 6,
            color: Color(0xFF082430),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF082430),
                fontFamily: 'Gupter Regular',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
