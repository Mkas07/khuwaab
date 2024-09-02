import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/predict');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/map');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/about');
            break;
        }
      },
      backgroundColor: Colors.lightBlueAccent,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.house),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Predict',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'About Us',
        ),
      ],
    );
  }
}
