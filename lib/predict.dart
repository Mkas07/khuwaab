import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'predictionscreen.dart'; // Import your result screen file
import 'appbar.dart';
import 'bottomnav.dart';

class HousePricePredictionScreen extends StatefulWidget {
  @override
  _HousePricePredictionScreenState createState() => _HousePricePredictionScreenState();
}

class _HousePricePredictionScreenState extends State<HousePricePredictionScreen> {
  String? selectedArea;
  final List<String> areas = [
    'Bahria Town Karachi', 'Nazimabad', 'Gulistan-e-Jauhar',
    'DHA Defence', 'Cantt', 'North Karachi', 'Federal B Area',
    'Clifton', 'Malir', 'Shah Faisal Town', 'Gulshan-e-Iqbal Town',
    'University Road', 'Tariq Road', 'Korangi'
  ];

  int? selectedBeds;
  int? selectedBaths;
  final TextEditingController areaController = TextEditingController();
  bool isLoading = false;

  Future<void> _predictPrice() async {
    if (selectedBeds == null || selectedBaths == null || selectedArea == null || areaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }

    final double area = double.parse(areaController.text);

    if (area < 60 || area > 2500) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Area must be between 60 and 2500 square yards.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://flaskapipredictmodel-530b9d33d462.herokuapp.com/predict'), // Update with your Flask server address
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'baths': selectedBaths,
        'bedrooms': selectedBeds,
        'AreaSqYards': area,
        'location': selectedArea,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionResultScreen(
            beds: selectedBeds!,
            baths: selectedBaths!,
            location: selectedArea ?? '',
            areaSqft: area,
            predictedPrice: data['predicted_price'],
          ),
        ),
      );
    } else {
      // Handle error response
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'House Price Prediction',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF082430),
                  ),
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Area',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: selectedArea,
                onChanged: (newValue) {
                  setState(() {
                    selectedArea = newValue;
                  });
                },
                items: areas.map((area) {
                  return DropdownMenuItem(
                    child: Text(area),
                    value: area,
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'No of Beds',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: selectedBeds,
                onChanged: (newValue) {
                  setState(() {
                    selectedBeds = newValue;
                  });
                },
                items: List.generate(16, (index) => index).map((value) {
                  return DropdownMenuItem(
                    child: Text(value.toString()),
                    value: value,
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'No of Baths',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: selectedBaths,
                onChanged: (newValue) {
                  setState(() {
                    selectedBaths = newValue;
                  });
                },
                items: List.generate(16, (index) => index).map((value) {
                  return DropdownMenuItem(
                    child: Text(value.toString()),
                    value: value,
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: areaController,
                decoration: InputDecoration(
                  labelText: 'Area (Square Yards)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: isLoading
                    ? CircularProgressIndicator() // Show loading indicator
                    : ElevatedButton(
                  onPressed: _predictPrice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF082430),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Predict',
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
      bottomNavigationBar: BottomNavBar(currentIndex: 1), // Add this line
    );
  }
}
