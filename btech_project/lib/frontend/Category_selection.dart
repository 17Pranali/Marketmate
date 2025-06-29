import 'package:flutter/material.dart';
import 'package:btech_project/frontend/business_information_page.dart';

class CategorySelectionPage extends StatefulWidget {
  final String userUid;
  final String language;

  const CategorySelectionPage(
      {Key? key, required this.userUid, required this.language})
      : super(key: key);

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Grocery', 'icon': Icons.store},
    {'name': 'Bakery', 'icon': Icons.cake},
    {'name': 'Electronics', 'icon': Icons.phone_android},
    {'name': 'Medical', 'icon': Icons.local_hospital},
    {'name': 'Hotel', 'icon': Icons.hotel},
    {'name': 'Automobiles', 'icon': Icons.directions_car},
    {'name': 'Stationary', 'icon': Icons.book},
    {'name': 'Fashion', 'icon': Icons.shopping_bag},
    {'name': 'Furniture', 'icon': Icons.chair},
    {'name': 'Toys', 'icon': Icons.toys},
    {'name': 'Sports', 'icon': Icons.sports_soccer},
    {'name': 'Books', 'icon': Icons.book_online},
    // Add more categories if needed
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Category'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextField(
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Categories',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                ),
              ),
              // Categories Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        1.2, // Adjust to your liking for responsiveness
                  ),
                  itemCount: categories
                      .where((category) => category['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                      .toList()
                      .length,
                  itemBuilder: (context, index) {
                    final category = categories
                        .where((category) => category['name']
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList()[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessInformationForm(
                              userUid: widget.userUid,
                              language: widget.language,
                              category: category['name'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              size: 50,
                              color: Colors.teal,
                            ),
                            SizedBox(height: 8),
                            Text(
                              category['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
