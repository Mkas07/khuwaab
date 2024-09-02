import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottomnav.dart';
import 'appbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'homescreen.dart';

class PostAdScreen extends StatefulWidget {
  @override
  _PostAdScreenState createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  List<XFile>? _imageFiles;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedArea;
  String? _selectedBeds;
  String? _selectedBaths;

  final List<String> _areas = [
    'Bahria Town Karachi', 'Nazimabad', 'Gulistan-e-Jauhar', 'DHA Defence', 'Cantt',
    'North Karachi', 'Federal B Area', 'Clifton', 'Malir', 'Shah Faisal Town',
    'Gulshan-e-Iqbal Town', 'University Road', 'Tariq Road', 'Korangi'
  ];
  final List<String> _bedOptions = List.generate(16, (index) => index.toString());
  final List<String> _bathOptions = List.generate(16, (index) => index.toString());

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User is not logged in'),
      ));
      return;
    }

    String userEmail = user.email!;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();

    if (userDoc.exists) {
      setState(() {
        _phoneNumberController.text = '0' + userDoc['phone'].toString();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User data not found'),
      ));
    }
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _imageFiles = pickedFiles;
      });
    }
  }

  Future<void> _showImageUploadDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Required'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please upload at least one image to post your ad.'),
              ],
            ),
          ),
          actions: <Widget>[
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

  int _wordCount(String text) {
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  Future<void> _saveAd() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_imageFiles == null || _imageFiles!.isEmpty) {
      await _showImageUploadDialog();
      return;
    }

    if (_wordCount(_descriptionController.text) < 20) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Description is less.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userEmail = user.email!;
        String phoneNumber = _phoneNumberController.text.trim();

        if (phoneNumber.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Phone number is not available'),
          ));
          return;
        }

        List<String> imageUrls = [];
        for (var imageFile in _imageFiles!) {
          try {
            String fileName = DateTime.now().millisecondsSinceEpoch.toString();
            Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');

            await storageRef.putFile(File(imageFile.path));
            String downloadUrl = await storageRef.getDownloadURL();
            imageUrls.add(downloadUrl);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to upload an image. Please try again.'),
            ));
            return;
          }
        }

        if (imageUrls.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to upload images. Please try again.'),
          ));
          return;
        }

        Map<String, dynamic> adData = {
          'title': _titleController.text,
          'price': int.parse(_priceController.text),
          'beds': int.parse(_selectedBeds!),
          'baths': int.parse(_selectedBaths!),
          'area': int.parse(_areaController.text),
          'selectedArea': _selectedArea,
          'description': _descriptionController.text,
          'phone': phoneNumber,
          'userEmail': userEmail,
          'createdAt': Timestamp.now(),
          'imageUrls': imageUrls,
          'status': 'pending',
        };

        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String docId = '$phoneNumber-$timestamp';

        await FirebaseFirestore.instance.collection('ads').doc(docId).set(adData);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ad posted for Review!'),
        ));

        _formKey.currentState!.reset();
        _phoneNumberController.clear();
        _titleController.clear();
        _priceController.clear();
        _selectedBeds = null;
        _selectedBaths = null;
        _areaController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedArea = null;
          _imageFiles = null;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MarketPlaceScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to post ad: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post an Ad',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(labelText: 'Price in Rs'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          } else if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (int.parse(value) < 1000000 || int.parse(value) > 500000000) {
                            return 'Price must be between 1,000,000 and 500,000,000 Rs';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedBeds,
                        hint: Text('Select number of beds'),
                        items: _bedOptions.map((bed) {
                          return DropdownMenuItem<String>(
                            value: bed,
                            child: Text(bed),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBeds = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the number of beds';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedBaths,
                        hint: Text('Select number of baths'),
                        items: _bathOptions.map((bath) {
                          return DropdownMenuItem<String>(
                            value: bath,
                            child: Text(bath),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBaths = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select the number of baths';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedArea,
                        hint: Text('Select Area'),
                        items: _areas.map((area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(area),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedArea = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an area';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _areaController,
                        decoration: InputDecoration(labelText: 'Area in Sq Yards'),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the area';
                          } else if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (int.parse(value) < 60 || int.parse(value) > 10000) {
                            return 'Area must be between 60 and 10,000 Sq Yards';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 5,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Text('Upload Images (Required)'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImages,
                        child: Text('Choose Images'),
                      ),
                      SizedBox(height: 10),
                      if (_imageFiles != null && _imageFiles!.isNotEmpty)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _imageFiles!.map((image) {
                            return Image.file(
                              File(image.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 20),
                      if (_isLoading)
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      else
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveAd,
                            child: Text('Post Ad'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0,),
    );
  }
}
