import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class BusinessProfilePage extends StatefulWidget {
  final String userUid;
  final String language;

  const BusinessProfilePage({
    Key? key,
    required this.userUid,
    required this.language,
  }) : super(key: key);

  @override
  _BusinessProfilePageState createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  String profilePicUrl = '';
  String businessName = '';
  String ownerName = '';
  String location = '';
  String email = '';
  String contact = '';
  int connections = 0;

  final List<String> productImages = [
    'assets/cookies.jpg',
    'assets/grocery.png',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchBusinessProfile();
  }

  Map<String, Map<String, String>> translations = {
    'en': {
      'businessProfile': 'Business Profile',
      'connections': 'Connections',
      'businessName': 'Business Name',
      'ownerName': 'Owner Name',
      'location': 'Location',
      'email': 'Email',
      'contact': 'Contact',
      'availableProducts': 'Available Products',
      'addProduct': 'Add Product',
      'proceed': 'Proceed',
      'productAdded': 'Product image added successfully!',
    },
    'hi': {
      'businessProfile': 'व्यवसाय प्रोफ़ाइल',
      'connections': 'संपर्क',
      'businessName': 'व्यवसाय का नाम',
      'ownerName': 'मालिक का नाम',
      'location': 'स्थान',
      'email': 'ईमेल',
      'contact': 'संपर्क नंबर',
      'availableProducts': 'उपलब्ध उत्पाद',
      'addProduct': 'उत्पाद जोड़ें',
      'proceed': 'आगे बढ़ें',
      'productAdded': 'उत्पाद छवि सफलतापूर्वक जोड़ी गई!',
    },
    'mr': {
      'businessProfile': 'व्यवसाय प्रोफाइल',
      'connections': 'संपर्क',
      'businessName': 'व्यवसायाचे नाव',
      'ownerName': 'मालकाचे नाव',
      'location': 'स्थान',
      'email': 'ईमेल',
      'contact': 'संपर्क',
      'availableProducts': 'उपलब्ध उत्पादने',
      'addProduct': 'उत्पादन जोडा',
      'proceed': 'पुढे जा',
      'productAdded': 'उत्पादन प्रतिमा यशस्वीरित्या जोडली गेली!',
    },
  };

  String t(BuildContext context, String key, String language) {
    return translations[language]?[key] ?? key;
  }

  Future<void> _fetchBusinessProfile() async {
    final businessSnapshot = await FirebaseFirestore.instance
        .collection('business_categories')
        .where('userUid', isEqualTo: widget.userUid)
        .limit(1)
        .get();

    if (businessSnapshot.docs.isNotEmpty) {
      final data = businessSnapshot.docs.first.data();
      setState(() {
        profilePicUrl = data['profilePicUrl'] ?? '';
        businessName = data['businessName'] ?? '';
        ownerName = data['businessOwner'] ?? '';
        location = data['location'] ?? '';
        email = data['email'] ?? '';
        contact = data['contact'] ?? '';
        connections = data['connections'] ?? 0;
      });
    }
  }

  Future<void> _addProductImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        productImages.add(imageFile.path);
      });

      String fileName =
          'product_${DateTime.now().millisecondsSinceEpoch}.${pickedFile.path.split('.').last}';
      Reference storageRef =
          FirebaseStorage.instance.ref().child('products/$fileName');
      await storageRef.putFile(imageFile);
      String imageUrl = await storageRef.getDownloadURL();

      setState(() {
        productImages.remove(imageFile.path);
        productImages.add(imageUrl);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t(context, 'productAdded', widget.language))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          businessName.isNotEmpty
              ? businessName
              : t(context, 'businessProfile', widget.language),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage:
                  profilePicUrl.isNotEmpty ? NetworkImage(profilePicUrl) : null,
              child: profilePicUrl.isEmpty
                  ? Icon(Icons.person, size: 60, color: Colors.grey)
                  : null,
            ),
            SizedBox(height: 12),
            Text(
              businessName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              ownerName,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            _buildStatsRow(),
            SizedBox(height: 10),
            _buildProfileDetailsCard(),
            _buildProductImagesSection(),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _navigateNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              icon: Icon(Icons.arrow_forward),
              label: Text(
                t(context, 'proceed', widget.language),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProductImage,
        backgroundColor: Colors.blueAccent,
        icon: Icon(Icons.add_photo_alternate),
        label: Text(t(context, 'addProduct', widget.language)),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(t(context, 'connections', widget.language),
              connections.toString()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfileDetailsCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.business,
                t(context, 'businessName', widget.language), businessName),
            _buildInfoRow(Icons.person,
                t(context, 'ownerName', widget.language), ownerName),
            _buildInfoRow(Icons.location_on,
                t(context, 'location', widget.language), location),
            _buildInfoRow(
                Icons.email, t(context, 'email', widget.language), email),
            _buildInfoRow(
                Icons.phone, t(context, 'contact', widget.language), contact),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 15),
                children: [
                  TextSpan(
                      text: "$label: ",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImagesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(context, 'availableProducts', widget.language),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: productImages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              String image = productImages[index];
              if (image.startsWith('assets')) {
                return _buildProductCard(Image.asset(image, fit: BoxFit.cover));
              } else if (kIsWeb || image.startsWith('http')) {
                return _buildProductCard(
                    Image.network(image, fit: BoxFit.cover));
              } else {
                return _buildProductCard(
                    Image.file(File(image), fit: BoxFit.cover));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Widget imageWidget) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: imageWidget,
      ),
    );
  }

  void _navigateNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(language: widget.language),
      ),
    );
  }
}
