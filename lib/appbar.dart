import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({this.title = ''});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.lightBlue,
      elevation: 0,
      title: Text(
        title,
        style: TextStyle(color: Color(0xFF082430), fontFamily: 'Gupter Medium'),
      ),
      leading: IconButton(
        icon: Image.asset('Assets/logo.png'), // Replace with your logo path
        onPressed: () {
          Navigator.pushNamed(context, '/home'); // Navigate to home screen
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu, color: Color(0xFF082430)),
          onPressed: () {
            _showSidebar(context);
          },
        ),
      ],
    );
  }

  void _showSidebar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: user == null
              ? [
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Signup'),
              onTap: () {
                Navigator.pushNamed(context, '/signup');
              },
            ),
          ]
              : [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact Us'),
              onTap: () {
                // Implement your contact us navigation here
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
