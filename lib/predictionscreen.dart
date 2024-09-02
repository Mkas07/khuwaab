import 'package:flutter/material.dart';
import 'appbar.dart';
import 'bottomnav.dart';
class PredictionResultScreen extends StatelessWidget {
  final int beds;
  final int baths;
  final String location;
  final double areaSqft;
  final double predictedPrice;

  PredictionResultScreen({
    required this.beds,
    required this.baths,
    required this.location,
    required this.areaSqft,
    required this.predictedPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Your custom app bar
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Prediction Result',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF082430),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Display result fields
              _buildResultField('No of Beds', beds.toString()),
              _buildResultField('No of Baths', baths.toString()),
              _buildResultField('Location', location),
              _buildResultField('Area per SqYard', areaSqft.toString()),
              SizedBox(height: 20),
              _buildResultField('Predicted Price','Rs '+ predictedPrice.toStringAsFixed(2)),
              SizedBox(height: 20),
              // Return button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF082430),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Return',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1), // Your custom bottom navigation bar
    );
  }

  Widget _buildResultField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF082430),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF082430),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
