import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile_page.dart';

class ConnectionsListPage extends StatefulWidget {
  final String userId;
  final String language; // 'en', 'hi', 'mr'

  const ConnectionsListPage({
    super.key,
    required this.userId,
    required this.language,
  });

  @override
  State<ConnectionsListPage> createState() => _ConnectionsListPageState();
}

class _ConnectionsListPageState extends State<ConnectionsListPage> {
  List<Map<String, dynamic>> mates = [];
  List<Map<String, dynamic>> filteredMates = [];
  bool isLoading = true;
  String searchQuery = '';

  final Color primaryColor = const Color(0xFF0A66C2); // Blue shade

  final Map<String, Map<String, String>> translations = {
    'en': {
      'connectionsList': 'Connections List',
      'searchHint': 'Search by business name...',
      'noMatesFound': 'No mates found.',
      'locationNotSpecified': 'Not specified',
      'category': 'Category',
    },
    'hi': {
      'connectionsList': 'संपर्क सूची',
      'searchHint': 'व्यवसाय नाम से खोजें...',
      'noMatesFound': 'कोई संपर्क नहीं मिला।',
      'locationNotSpecified': 'निर्दिष्ट नहीं',
      'category': 'श्रेणी',
    },
    'mr': {
      'connectionsList': 'संपर्क यादी',
      'searchHint': 'व्यवसाय नावाने शोधा...',
      'noMatesFound': 'कोणतेही संपर्क सापडले नाहीत.',
      'locationNotSpecified': 'निर्दिष्ट नाही',
      'category': 'श्रेणी',
    },
  };

  String tr(String key) {
    return translations[widget.language]?[key] ?? translations['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadMates();
  }

  Future<void> _loadMates() async {
    try {
      final requestSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('connectionRequests')
          .where('status', isEqualTo: 'accepted')
          .get();

      final List<Map<String, dynamic>> loaded = [];

      for (var doc in requestSnapshot.docs) {
        final mateId = doc.id;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(mateId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() ?? {};
          loaded.add({
            'id': mateId,
            'name': data['businessName']?.toString().trim().isNotEmpty == true
                ? data['businessName']
                : data['email'] ?? 'User',
            'profileImageUrl': data['profileImageUrl'] ?? '',
            'location': data['location'] ?? '',
            'category': data['category'] ?? 'Unknown',
          });
        }
      }

      setState(() {
        mates = loaded;
        filteredMates = loaded;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading mates: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMates(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      searchQuery = query;
      filteredMates = mates
          .where((mate) =>
              (mate['name'] as String).toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        title: Text(tr('connectionsList'),
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: _filterMates,
                    decoration: InputDecoration(
                      hintText: tr('searchHint'),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredMates.isEmpty
                      ? Center(
                          child: Text(
                            tr('noMatesFound'),
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filteredMates.length,
                          itemBuilder: (context, index) {
                            final mate = filteredMates[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfilePage(
                                        userId: mate['id'],
                                        language: widget.language),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                color: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey.shade300,
                                        backgroundImage:
                                            mate['profileImageUrl'] != ''
                                                ? NetworkImage(
                                                    mate['profileImageUrl'])
                                                : null,
                                        child: mate['profileImageUrl'] == ''
                                            ? const Icon(Icons.person,
                                                size: 30, color: Colors.grey)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              mate['name'] ?? 'User',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              mate['location'] != ''
                                                  ? mate['location']
                                                  : tr('locationNotSpecified'),
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              "${tr('category')}: ${mate['category'] ?? 'Unknown'}",
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black45),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 16, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
