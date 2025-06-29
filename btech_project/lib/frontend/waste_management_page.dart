import 'package:btech_project/frontend/recent_chats_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_profile_page.dart'; // Make sure this exists and accepts a user ID or user data

class WasteManagementPage extends StatefulWidget {
  final String language;
  const WasteManagementPage({super.key, required this.language});

  @override
  State<WasteManagementPage> createState() => _WasteManagementPageState();
}

class _WasteManagementPageState extends State<WasteManagementPage> {
  List<DocumentSnapshot> _users = [];
  String _searchTerm = '';
  String currentUserId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWasteUsers();
  }

  Future<void> _loadWasteUsers() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    currentUserId = uid ?? '';

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('category', isEqualTo: 'Waste Management')
        .get();

    setState(() {
      _users = snapshot.docs;
      _isLoading = false;
    });
  }

  List<DocumentSnapshot> get _filteredUsers {
    if (_searchTerm.isEmpty) return _users;
    return _users.where((doc) {
      final name = doc['businessName'].toString().toLowerCase();
      final area = (doc['area'] ?? '').toString().toLowerCase();
      return name.contains(_searchTerm.toLowerCase()) ||
          area.contains(_searchTerm.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Management'),
        backgroundColor: const Color(0xFFCE9FFC),
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFFFF1FB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by name or area',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() => _searchTerm = val),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final imageUrl = user['profileImageUrl'] ?? '';
                      final isCurrentUser = user['uid'] == currentUserId;
                      final businessName = user['businessName'] ?? 'No Name';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : const AssetImage(
                                        'assets/avatar_placeholder.png')
                                    as ImageProvider,
                          ),
                          title: Text(
                            isCurrentUser
                                ? '$businessName (You)'
                                : businessName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Owner: ${user['ownerName'] ?? ''}"),
                              Text("Area: ${user['area'] ?? ''}"),
                              Text("Location: ${user['location'] ?? ''}"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RecentChatsPage(
                                        language: widget.language)),
                              );
                              // Navigate to chat screen with this user
                              // You can pass user['uid'] to your chat screen here
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfilePage(
                                    userId: user['uid'],
                                    language: widget
                                        .language // Pass userId or full user data as needed
                                    ),
                              ),
                            );
                          },
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
