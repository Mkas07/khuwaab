import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottomnav.dart';
import 'appbar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final adId = args['adId'];

    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('ads').doc(adId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var ad = snapshot.data!.data() as Map<String, dynamic>;

          // Format the date using intl package
          String formattedDate = DateFormat.yMMMd().format(ad['createdAt'].toDate().toLocal());

          return SingleChildScrollView(  // Make the page scrollable
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Carousel using PageView
                Container(
                  height: 250,
                  child: PageView.builder(
                    itemCount: ad['imageUrls'].length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ad['imageUrls'][index],
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15),

                // Display title and other details
                Text(
                  'Rs ${ad['price']}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  ad['selectedArea'],
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bed, color: Colors.grey[600]),
                    SizedBox(width: 5),
                    Text('Beds: ${ad['beds']}', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 20),
                    Icon(Icons.bathtub, color: Colors.grey[600]),
                    SizedBox(width: 5),
                    Text('Baths: ${ad['baths']}', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.area_chart, color: Colors.grey[600]),
                    SizedBox(width: 5),
                    Text('Area: ${ad['area']} sq yard', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 15),
                Text(
                  ad['description'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 15),

                // Display the formatted date
                Text(
                  'Date Posted: $formattedDate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 25),

                // Display Phone Number as Contact Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _contactSeller(context, ad['phone']);
                    },
                    icon: Icon(Icons.phone, color: Colors.white),
                    label: Text(ad['phone']),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }

  void _contactSeller(BuildContext context, String phoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch the dialer.')),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Required'),
            content: Text('Users can access the number only after logging in.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
