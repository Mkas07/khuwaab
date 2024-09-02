import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kfyp2/appbar.dart';
import 'bottomnav.dart';

class MarketPlaceScreen extends StatefulWidget {
  @override
  _MarketPlaceScreenState createState() => _MarketPlaceScreenState();
}

class _MarketPlaceScreenState extends State<MarketPlaceScreen> {
  String searchQuery = '';
  String sortBy = 'createdAt';
  bool isDescending = true;
  int currentPage = 1;
  int itemsPerPage = 10;
  List<DocumentSnapshot> allAds = [];
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMoreAds();
  }

  Future<void> _refreshData() async {
    setState(() {
      allAds.clear();
      currentPage = 1;
      hasMore = true;
    });
    await _loadMoreAds();
  }

  Future<void> _loadMoreAds() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      Query query = FirebaseFirestore.instance
          .collection('ads')
          .where('status', isEqualTo: 'Accepted');

      if (sortBy == 'createdAt') {
        query = query.orderBy('createdAt', descending: isDescending);
      } else {
        query = query.orderBy(sortBy, descending: isDescending)
            .orderBy('createdAt', descending: true);
      }

      query = query.limit(itemsPerPage);

      if (allAds.isNotEmpty) {
        query = query.startAfterDocument(allAds.last);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          hasMore = false;
        });
      } else {
        setState(() {
          allAds.addAll(querySnapshot.docs);
          currentPage++;
        });
      }
    } catch (e) {
      print('Error loading ads: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load ads. Please try again.'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAds = allAds.where(_adMatchesSearch).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search properties',
                  prefixIcon: Icon(Icons.search, color: Color(0xFFB83D2E)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterButton(
                    label: 'By Price',
                    onPressed: () => _setSortBy('price'),
                    isSelected: sortBy == 'price',
                  ),
                  SizedBox(width: 10),
                  FilterButton(
                    label: 'By Bedrooms',
                    onPressed: () => _setSortBy('beds'),
                    isSelected: sortBy == 'beds',
                  ),
                  SizedBox(width: 10),
                  FilterButton(
                    label: 'By Bathrooms',
                    onPressed: () => _setSortBy('baths'),
                    isSelected: sortBy == 'baths',
                  ),
                  SizedBox(width: 10),
                  FilterButton(
                    label: 'By Area',
                    onPressed: () => _setSortBy('area'),
                    isSelected: sortBy == 'area',
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: Color(0xFFB83D2E),
                child: filteredAds.isEmpty && !isLoading
                    ? Center(child: Text('No ads found'))
                    : ListView.builder(
                  itemCount: filteredAds.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < filteredAds.length) {
                      var ad = filteredAds[index];
                      return PropertyCard(
                        imageUrl: ad['imageUrls'] != null && ad['imageUrls'].isNotEmpty
                            ? ad['imageUrls'][0]
                            : 'https://placeholder.com/image.jpg',
                        price: ad['price'],
                        beds: ad['beds'],
                        baths: ad['baths'],
                        area: ad['area'],
                        selectedArea: ad['selectedArea'],
                        adId: ad.id,
                      );
                    } else if (hasMore) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: _loadMoreAds,
                          child: Text('Load More'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Color(0xFFB83D2E),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handlePostAdTap(context),
        icon: Icon(Icons.add),
        label: Text('Post an Ad'),
        backgroundColor: Color(0xFFB83D2E),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavBar(currentIndex: 0),
    );
  }

  bool _adMatchesSearch(DocumentSnapshot ad) {
    if (searchQuery.isEmpty) return true;
    final location = ad['selectedArea'].toString().toLowerCase();
    final beds = ad['beds'].toString();
    final baths = ad['baths'].toString();
    final area = ad['area'].toString();
    return location.contains(searchQuery) ||
        beds.contains(searchQuery) ||
        baths.contains(searchQuery) ||
        area.contains(searchQuery);
  }

  void _handlePostAdTap(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushNamed(context, '/post_ad');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  void _setSortBy(String newSortBy) {
    setState(() {
      if (sortBy == newSortBy) {
        // If the same button is pressed again, reset to default
        sortBy = 'createdAt';
        isDescending = true;
      } else {
        sortBy = newSortBy;
        isDescending = true;
      }
      allAds.clear();
      currentPage = 1;
      hasMore = true;
    });
    _loadMoreAds();
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  FilterButton({required this.label, required this.onPressed, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Color(0xFFB83D2E),
        backgroundColor: isSelected ? Color(0xFFB83D2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Color(0xFFB83D2E)),
        ),
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final int price;
  final int beds;
  final int baths;
  final int area;
  final String selectedArea;
  final String adId;

  PropertyCard({
    required this.imageUrl,
    required this.price,
    required this.beds,
    required this.baths,
    required this.area,
    required this.selectedArea,
    required this.adId,
  });

  String formatPrice(int price) {
    if (price >= 10000000) {
      double crores = price / 10000000;
      return '${crores.toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      double lakhs = price / 100000;
      return '${lakhs.toStringAsFixed(2)} L';
    } else {
      return 'RS $price';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/ad_details',
            arguments: {'adId': adId},
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPrice(price),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB83D2E),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.king_bed, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('$beds'),
                      SizedBox(width: 16),
                      Icon(Icons.bathtub, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('$baths'),
                      SizedBox(width: 16),
                      Icon(Icons.square_foot, size: 18, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('$area sq.yard'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    selectedArea,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}