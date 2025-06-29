import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'category_users_page.dart';
import 'notification_page.dart';
import 'profile_creation_page.dart';
import 'recent_chats_page.dart';
import 'signup_page.dart';
import 'user_profile_page.dart';
import 'waste_management_page.dart';
import 'premium_page.dart';
import 'marketmate_ai_page.dart';

class HomePage extends StatefulWidget {
  final String language;

  const HomePage({Key? key, required this.language}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String language;
  int _selectedIndex = 0;
  int requestNotificationCount = 0;
  String? profileImageUrl;

  Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'home': 'Home', // 'मुखपृष्ठ'
      'chats': 'Chats', // 'चॅट्स'
      'notifications': 'Notifications', // 'सूचनाएं'
      'waste': 'Waste Management', // 'कचरा व्यवस्थापन'
      'exploreWasteManagement':
          'Explore Waste Management', // 'कचरा व्यवस्थापन अन्वेषण करा'
      'viewProfile': 'View Profile', // 'प्रोफाइल पहा'
      'editProfile': 'Edit Profile', // 'प्रोफाइल संपादित करा'
      'logOut': 'Log Out', // 'लॉग आउट'
      'categories': 'Categories', // 'वर्ग'
      'bakery': 'Bakery', // 'बेकरी'
      'grocery': 'Grocery', // 'ग्रॉसरी'
      'pharmacy': 'Pharmacy', // 'फार्मसी'
      'restaurant': 'Restaurant', // 'रेस्टोरंट'
      'electronics': 'Electronics', // 'इलेक्ट्रॉनिक्स'
      'automobile': 'Automobile', // 'ऑटोमोबाइल'
      'noCategories':
          'No categories available.', // 'कोणतेही वर्ग उपलब्ध नाहीत.'
      'marketMate': 'MarketMate',
      "areYouSureToLogout": "Are you sure you want to log out?",
      'premium_required': 'Premium Required',
      'waste_premium_msg':
          'To access Waste Management, you need to be a premium user.',
      'take_premium_now': 'Take Premium Now',
      'later': 'Later',
    },
    'hi': {
      'home': 'मुखपृष्ठ',
      'chats': 'चैट्स',
      'notifications': 'सूचनाएं',
      'waste': 'कचरा प्रबंधन',
      'exploreWasteManagement': 'कचरा प्रबंधन खोजें',
      'viewProfile': 'प्रोफाइल देखें',
      'editProfile': 'प्रोफाइल संपादित करें',
      'logOut': 'लॉग आउट',
      'categories': 'श्रेणियाँ',
      'bakery': 'बेकरी',
      'grocery': 'किराना',
      'pharmacy': 'दवा की दुकान',
      'restaurant': 'रेस्तरां',
      'electronics': 'इलेक्ट्रॉनिक्स',
      'automobile': 'ऑटोमोबाइल',
      'noCategories': 'कोई श्रेणियाँ उपलब्ध नहीं हैं।',
      "areYouSureToLogout": 'तुम्हाला लॉग आउट करायचं आहे का?',
      'marketMate': 'मार्केटमेट',
      'premium_required': 'प्रीमियम आवश्यक',
      'waste_premium_msg':
          'वेस्ट मैनेजमेंट एक्सेस करने के लिए, आपको प्रीमियम उपयोगकर्ता होना होगा।',
      'take_premium_now': 'अभी प्रीमियम लें',
      'later': 'बाद में',
    },
    'mr': {
      'home': 'मुखपृष्ठ',
      'chats': 'चॅट्स',
      'notifications': 'सूचनाएं',
      'waste': 'कचरा व्यवस्थापन',
      'exploreWasteManagement': 'कचरा व्यवस्थापन अन्वेषण करा',
      'viewProfile': 'प्रोफाइल पहा',
      'editProfile': 'प्रोफाइल संपादित करा',
      'logOut': 'लॉग आउट',
      'categories': 'वर्ग',
      'bakery': 'बेकरी',
      'grocery': 'ग्रॉसरी',
      'pharmacy': 'फार्मसी',
      'restaurant': 'रेस्टोरंट',
      'electronics': 'इलेक्ट्रॉनिक्स',
      'automobile': 'ऑटोमोबाइल',
      'noCategories': 'कोणतेही वर्ग उपलब्ध नाहीत.',
      'marketMate': 'मार्केटमेट',
      "areYouSureToLogout": 'तुम्हाला लॉग आउट करायचं आहे का?',
      'premium_required': 'प्रीमियम आवश्यक आहे',
      'waste_premium_msg':
          'वेस्ट मॅनेजमेंट वापरण्यासाठी, तुम्ही प्रीमियम वापरकर्ता असणे आवश्यक आहे.',
      'take_premium_now': 'आता प्रीमियम घ्या',
      'later': 'नंतर',
    },
    'gu': {
      'signIn': 'સાઇન ઇન કરો',
      'email': 'ઇમેઇલ',
      'password': 'પાસવર્ડ',
      'login': 'લોગિન',
      'forgotPassword': 'પાસવર્ડ ભૂલી ગયા?',
      'enterEmail': 'તમારું ઇમેઇલ દાખલ કરો',
      'enterPassword': 'તમારું પાસવર્ડ દાખલ કરો',
      'resetPrompt': 'પાસવર્ડ રીસેટ કરવા માટે તમારું ઇમેઇલ દાખલ કરો.',
      'resetFail': 'પાસવર્ડ રીસેટ ઇમેઇલ મોકલવામાં નિષ્ફળ',
      'loginFail': 'લોગિન નિષ્ફળ ગયું'
    },
    'kn': {
      'signIn': 'ಸೈನ್ ಇನ್',
      'email': 'ಇಮೇಲ್',
      'password': 'ಪಾಸ್ವರ್ಡ್',
      'login': 'ಲಾಗಿನ್',
      'forgotPassword': 'ಪಾಸ್ವರ್ಡ್ ಮರೆತಿರಾ?',
      'enterEmail': 'ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ',
      'enterPassword': 'ನಿಮ್ಮ ಪಾಸ್ವರ್ಡ್ ನಮೂದಿಸಿ',
      'resetPrompt': 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸಲು ನಿಮ್ಮ ಇಮೇಲ್ ನಮೂದಿಸಿ.',
      'resetFail': 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸುವ ಇಮೇಲ್ ಕಳುಹಿಸಲು ವಿಫಲವಾಯಿತು',
      'loginFail': 'ಲಾಗಿನ್ ವಿಫಲವಾಯಿತು'
    },
    'ta': {
      'home': 'హోమ్',
      'chats': 'చాట్స్',
      'notifications': 'ప్రకటనలు',
      'waste': 'అవశేషాల నిర్వహణ',
      'exploreWasteManagement': 'అవశేషాల నిర్వహణను అన్వేషించండి',
      'viewProfile': 'ప్రొఫైల్ చూడండి',
      'editProfile': 'ప్రొఫైల్ ఎడిట్ చేయండి',
      'logOut': 'లాగ్ ఔట్',
      'categories': 'వర్గాలు',
      'bakery': 'బేకరీ',
      'grocery': 'కిరాణా',
      'pharmacy': 'ఫార్మసీ',
      'restaurant': 'రెస్టారెంట్',
      'electronics': 'ఎలక్ట్రానిక్స్',
      'automobile': 'ఆటోమొబైల్',
      'noCategories': 'ఏ వర్గాలు లేవు.',
      'marketMate': 'మార్కెట్ మేట్',
    }
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationCounts();
    _loadProfileImage();
    language = widget.language;
  }

// This function sends a request and updates the notification count
  Future<void> _sendRequest(String receiverUid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Add notification to the receiver
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .collection('notifications')
        .add({
      'type': 'request',
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update the notification count for the receiver
    _updateNotificationCount(receiverUid);
  }

// This function is called when the user accepts a request
  Future<void> _acceptRequest(String receiverUid, String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Mark the request as accepted (you can change the type or flag)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .collection('notifications')
        .doc(notificationId)
        .update({
      'type': 'accepted',
      'read': true,
    });

    // Decrease the notification count
    _updateNotificationCount(receiverUid);
  }

// This function deletes the notification
  Future<void> _deleteNotification(
      String receiverUid, String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Delete the notification from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .collection('notifications')
        .doc(notificationId)
        .delete();

    // Decrease the notification count
    _updateNotificationCount(receiverUid);
  }

// Update the notification count
  Future<void> _updateNotificationCount(String receiverUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .where('type', whereIn: ['request', 'accepted']).get();

    int requestCount = snapshot.docs.length;

    // Update the notification count in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverUid)
        .update({
      'notificationCount': requestCount,
    });
  }

  Future<void> _loadNotificationCounts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .where('type', whereIn: ['request', 'accepted']).get();

    setState(() {
      requestNotificationCount = snapshot.docs.length;
    });
  }

  Future<void> _loadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      profileImageUrl = snapshot.data()?['profileImageUrl'];
    });
  }

  Future<bool> _isPremiumUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return snapshot.data()?['isPremium'] == true;
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${localizedStrings[widget.language]!['premium_required']}',
        ),
        content: Text(
          '${localizedStrings[widget.language]!['waste_premium_msg']}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PremiumPage(
                          language: widget.language,
                        )),
              );
            },
            child: Text(
              '${localizedStrings[widget.language]!['take_premium_now']}',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WasteManagementPage(
                    language: widget.language,
                  ),
                ),
              );
            },
            child: Text(
              '${localizedStrings[widget.language]!['later']}',
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _fetchAllCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    final validDocs = snapshot.docs.where((doc) =>
        doc.data().containsKey('uid') && doc.data().containsKey('category'));

    final categories = validDocs
        .map((doc) => doc['category']?.toString())
        .whereType<String>()
        .toSet()
        .toList();

    categories.removeWhere((cat) => cat.toLowerCase() == "waste management");

    return categories;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bakery':
        return Icons.cake;
      case 'grocery':
        return Icons.local_grocery_store;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'restaurant':
        return Icons.restaurant;
      case 'electronics':
        return Icons.devices_other;
      case 'automobile':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  void _logout() async {
    final confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: Text(localizedStrings[language]?['areYouSureToLogout'] ??
            'Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SignUpPage(language: 'en')),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final crossAxisCount = width > 800
        ? 4
        : width > 600
            ? 3
            : 2;

    final List<Widget> _pages = [
      Column(
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 20),
          _buildWasteManagementCard(isDark),
          Expanded(child: _buildCategoryGrid(isDark, crossAxisCount)),
        ],
      ),
      RecentChatsPage(language: widget.language),
      NotificationPage(language: widget.language),
      MarketMateAIPage(), // Placeholder for Waste Management, handled manually
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Don't exit the app
        }
        return true; // Exit the app if already at Home page
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF4F4F9),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  type: BottomNavigationBarType.fixed,
  selectedItemColor: Colors.deepPurple,
  unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
  backgroundColor: isDark ? const Color(0xFF2A213D) : Colors.white,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: localizedStrings[language]?['home'] ?? 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: localizedStrings[language]?['chats'] ?? 'Chats',
    ),
    BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications),
          if (requestNotificationCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      label: localizedStrings[language]!['notifications'],
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      label: 'Chatbot',
    ),
  ],
),

      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Color(0xFF2E1F4D),
                  Color(0xFF3B2A61)
                ] // Darker colors for dark mode
              : [
                  Color(0xFFE0C3FC),
                  Color.fromARGB(255, 26, 66, 105)
                ], // Existing light mode colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizedStrings[language]?['marketMate'] ?? 'MarketMate',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId != null) {
                    // Show dropdown menu with options to view or edit profile
                    _showProfileOptionsMenu(userId);
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              _iconWithBackground(icon: Icons.logout, onTap: _logout),
            ],
          ),
        ],
      ),
    );
  }

// Function to show the profile options dropdown menu
  void _showProfileOptionsMenu(String userId) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + 50, // X position adjusted to align properly
        offset.dy + 50, // Y position adjusted to appear below the profile icon
        20.0,
        0.0,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'viewProfile',
          child: Row(
            children: [
              const Icon(Icons.visibility,
                  color: Colors.black), // View profile icon
              const SizedBox(width: 10),
              Text(
                  localizedStrings[language]?['viewProfile'] ?? 'View Profile'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'editProfile',
          child: Row(
            children: [
              const Icon(Icons.edit, color: Colors.black), // Edit profile icon
              const SizedBox(width: 10),
              Text(
                  localizedStrings[language]?['editProfile'] ?? 'Edit Profile'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'viewProfile') {
        // Navigate to the user's profile page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                UserProfilePage(language: widget.language, userId: userId),
          ),
        );
      } else if (value == 'editProfile') {
        // Navigate to the profile edit page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileCreationPage(language: widget.language),
          ),
        );
      }
    });
  }

  Widget _buildWasteManagementCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          final userId = FirebaseAuth.instance.currentUser?.uid;
          if (userId == null) return;

          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (!userDoc.exists) return;

          final userData = userDoc.data()!;
          final userCategory = userData['category']?.toString().toLowerCase();
          final isPremium = userData['isPremium'] == true;

          if (userCategory == 'waste management' || isPremium) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WasteManagementPage(language: widget.language)),
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Premium Feature'),
                  content:
                      Text('This feature is available for premium users only.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PremiumPage(
                                    language: widget.language,
                                  )),
                        );
                      },
                      child: Text('Take Premium Now'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WasteManagementPage(
                                  language: widget.language)),
                        );
                      },
                      child: Text('Later'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? const Color(0xFF3C2A57) : const Color(0xFFFFE0B2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black45
                    : Colors.orangeAccent.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.delete_forever,
                  size: 30, color: Colors.deepOrange),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  localizedStrings[language]?['exploreWasteManagement'] ??
                      'Explore Waste Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.deepOrange,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.deepOrange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDark, int crossAxisCount) {
    return FutureBuilder<List<String>>(
      future: _fetchAllCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final categories = snapshot.data ?? [];
        if (categories.isEmpty) {
          return const Center(child: Text("No categories available."));
        }

        categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final icon = _getCategoryIcon(category);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryUsersPage(
                          category: category, language: widget.language),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF4C3A6D), const Color(0xFF6B547E)]
                          : [
                              const Color.fromARGB(255, 142, 46, 232),
                              const Color.fromARGB(255, 21, 73, 124)
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black54
                            : Colors.deepPurple.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _iconWithBackground({
    required IconData icon,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: Icon(icon, size: 24, color: Colors.black),
      ),
    );
  }
}
