import 'package:btech_project/frontend/home_page.dart';
import 'package:btech_project/frontend/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'connection_service.dart';
import 'user_profile_page.dart';
import 'dart:async';

class CategoryUsersPage extends StatefulWidget {
  final String category;
  final String language;

  const CategoryUsersPage(
      {super.key, required this.category, required this.language});

  @override
  _CategoryUsersPageState createState() => _CategoryUsersPageState();
}

class _CategoryUsersPageState extends State<CategoryUsersPage> {
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> filteredUsers = [];
  Timer? _debounce;
  String? profileImageUrl;

  int _selectedIndex = 0; // Add this at the top of _CategoryUsersPageState

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(language: widget.language)),
        );
        break;

      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  NotificationPage(language: widget.language)),
        );

        break;
      case 2:
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                  userId: currentUserId, language: widget.language),
            ),
          );
        }
        break;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
    // Call the method to load the profile image URL
  }

  final Map<String, Map<String, String>> translations = {
    'en': {
      'users': 'Users',
      'search_hint': 'Search by Business Name',
      'no_users': 'No users found in this category.',
      'location_unavailable': 'Location not available',
      'connected': 'Connected',
      'request_sent': 'Request Sent',
      'make connection': 'Make Connection',
      'home': 'Home',
      'notifications': 'Notifications',
      'profile': 'Profile',
    },
    'hi': {
      'users': 'उपयोगकर्ता',
      'search_hint': 'व्यवसाय नाम से खोजें',
      'no_users': 'इस श्रेणी में कोई उपयोगकर्ता नहीं मिला।',
      'location_unavailable': 'स्थान उपलब्ध नहीं है',
      'connected': 'जुड़े हुए',
      'request_sent': 'अनुरोध भेजा गया',
      'make connection': 'संपर्क करें',
      'home': 'मुखपृष्ठ',
      'notifications': 'सूचनाएं',
      'profile': 'प्रोफ़ाइल',
    },
    'mr': {
      'users': 'वापरकर्ते',
      'search_hint': 'व्यवसाय नावाने शोधा',
      'no_users': 'या श्रेणीत कोणतेही वापरकर्ते सापडले नाहीत.',
      'location_unavailable': 'स्थान उपलब्ध नाही',
      'connected': 'जोडलेले',
      'request_sent': 'विनंती पाठवली',
      'make connection': 'जोडा',
      'home': 'मुख्यपृष्ठ',
      'notifications': 'सूचना',
      'profile': 'प्रोफाईल',
    },
  };

  // Define the _loadUserProfileImage method
  Future<void> _loadUserProfileImage() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      if (userDoc.exists) {
        setState(() {
          profileImageUrl = userDoc.data()?[
              'profileImageUrl']; // Make sure 'profileImageUrl' is the correct field in Firestore
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} Users',
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 59, 39, 242),
                Color.fromARGB(255, 77, 25, 234)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    _filterUsers(value);
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search by Business Name',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('category', isEqualTo: widget.category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No users found in this category.'));
          }

          final users = snapshot.data!.docs
              .where((user) => user['uid'] != currentUserId)
              .toList();

          final displayUsers =
              filteredUsers.isEmpty && searchController.text.isEmpty
                  ? users
                  : filteredUsers;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: displayUsers.length,
            itemBuilder: (context, index) {
              final user = displayUsers[index];
              final userId = user['uid'];
              final isSelf = userId == currentUserId;

              return GestureDetector(
                onTap: () => _navigateToUserProfile(userId),
                child: Card(
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        height: 70, // reduced height,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isSelf
                                  ? '${user['businessName'] ?? 'No Name'} (You)'
                                  : user['businessName'] ?? 'No Name',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Display location instead of category
                            Text(
                              user['location'] ?? 'Location not available',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color.fromARGB(179, 46, 13, 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0D4F7),
                              borderRadius: BorderRadius.circular(12),
                              image: user['profileImageUrl'] != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(user['profileImageUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user['profileImageUrl'] == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.deepPurple,
                                    size: 60,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2), // reduced gap here
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4), // reduced padding here
                        child: ConnectionStatusText(targetUserId: userId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: profileImageUrl == null
                ? CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl!),
                  ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _filterUsers(String query) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('category', isEqualTo: widget.category)
        .get();

    setState(() {
      filteredUsers = snapshot.docs.where((user) {
        final businessName = user['businessName']?.toLowerCase() ?? '';
        final uid = user['uid'];
        return businessName.contains(query.toLowerCase()) &&
            uid != currentUserId;
      }).toList();
    });
  }

  void _navigateToUserProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserProfilePage(userId: userId, language: widget.language),
      ),
    );
  }
}

class ConnectionStatusText extends StatefulWidget {
  final String targetUserId;

  const ConnectionStatusText({super.key, required this.targetUserId});

  @override
  State<ConnectionStatusText> createState() => _ConnectionStatusTextState();
}

class _ConnectionStatusTextState extends State<ConnectionStatusText> {
  String status = 'none';

  @override
  void initState() {
    super.initState();
    _loadConnectionStatus();
  }

  Future<void> _loadConnectionStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final targetUserId = widget.targetUserId;

// Check if the target user has a request from current user
    final targetDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId)
        .collection('connectionRequests')
        .doc(currentUserId)
        .get();

    // // Check if current user sent request to target user
    // final sentDoc = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(currentUserId)
    //     .collection('connectionRequests')
    //     .doc(targetUserId)
    //     .get();

    if (targetDoc.exists && targetDoc.data()?['status'] == 'accepted') {
      setState(() {
        status = 'Connected';
      });
    } else if (targetDoc.exists && targetDoc.data()?['status'] == 'pending') {
      setState(() {
        status = 'Request Sent';
      });
    } else {
      setState(() {
        status = 'Make Connection';
      });
    }
  }

  // Future<void> _handleAction() async {
  //   if (status == 'none') {
  //     await ConnectionService.sendConnectionRequest(widget.targetUserId);
  //   } else if (status == 'pending') {
  //     await ConnectionService.cancelRequest(widget.targetUserId);
  //   } else if (status == 'accepted') {
  //     await ConnectionService.removeMate(widget.targetUserId);
  //   }

  //   await _loadConnectionStatus();
  // }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String buttonText;

    switch (status) {
      case 'Connected':
        statusColor = const Color.fromARGB(255, 34, 123, 37);
        buttonText = 'Connected';
        break;
      case 'Request Sent':
        statusColor = Colors.blueAccent;
        buttonText = 'Request Sent';
        break;
      default:
        statusColor = const Color.fromARGB(255, 241, 95, 4);
        buttonText = 'Make Connection';
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        final userId = widget.targetUserId;

        if (status == 'Make Connection') {
          final confirm = await showGeneralDialog<bool>(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'Send Connection',
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) {
              return const SizedBox
                  .shrink(); // Required by API, we override in `transitionBuilder`
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale:
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: const [
                      Icon(Icons.person_add_alt_1_rounded, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Connect Request'),
                    ],
                  ),
                  content: const Text(
                    'Do you want to send a connection request to this user?',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      label: const Text('Cancel'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 251, 9, 207),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ),
              );
            },
          );

          if (confirm == true) {
            await ConnectionService.sendConnectionRequest(userId);
          }
        } else if (status == 'Request Sent') {
          await ConnectionService.cancelRequest(userId);
        } else if (status == 'Connected') {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            pageBuilder: (context, anim1, anim2) {
              return Center(
                child: ScaleTransition(
                  scale:
                      CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width * 0.85, // wider width
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: Colors.white,
                      titlePadding: const EdgeInsets.only(top: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      title: Column(
                        children: [
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            child: const Icon(
                              Icons.handshake_rounded,
                              size: 80,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Already Connected!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                      content: const Text(
                        'You and this user are already connected.\nFeel free to interact and grow together! 💬🤝',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      actionsAlignment: MainAxisAlignment.center,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Got it!'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return FadeTransition(
                opacity:
                    CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          );
        }

        await _loadConnectionStatus(); // Refresh status
      },
      child: Text(buttonText),
    );
  }
}
