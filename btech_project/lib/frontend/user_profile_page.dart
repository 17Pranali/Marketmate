import 'package:btech_project/frontend/premium_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'connection_service.dart';
import 'connections_list_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final String language;

  const UserProfilePage(
      {super.key, required this.userId, required this.language});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late bool isSelf;
  String connectionStatus = 'none';
  bool isCurrentUser = false;
  int connectionsCount = 0;

  final TextEditingController _urlController = TextEditingController();
  List<Map<String, dynamic>> mates = [];

  @override
  void initState() {
    super.initState();
    isSelf = widget.userId == currentUser?.uid;
    _checkIfCurrentUser();
    _loadMates(widget.userId); // <- Load connections for any user
    if (!isSelf) {
      _loadConnectionStatus();
    }
  }

  void _checkIfCurrentUser() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    setState(() {
      isCurrentUser = widget.userId == currentUserId;
    });
  }

  final Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'userProfile': 'User Profile',
      'businessProfile': 'Business Profile',
      'businessName': 'Business Name',
      'ownerName': 'Owner Name',
      'email': 'Email',
      'location': 'Location',
      'message': 'Message',
      'connect': 'Connect+',
      'cancelRequest': 'Cancel Request',
      'connected': 'Connected',
      'connections': 'Connections',
      'gallery': 'Gallery',
      'pasteUrl': 'Paste image URL here...',
      'noImages': 'No images in gallery.',
      'deleteImage': 'Delete Image',
      'confirmDelete': 'Are you sure you want to delete this image?',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'paste_image_url': 'Paste image URL here...',
    },
    'hi': {
      'userProfile': 'उपयोगकर्ता प्रोफ़ाइल',
      'businessProfile': 'व्यवसाय प्रोफ़ाइल',
      'businessName': 'व्यवसाय का नाम',
      'ownerName': 'मालिक का नाम',
      'email': 'ईमेल',
      'location': 'स्थान',
      'message': 'संदेश',
      'connect': 'कनेक्ट+',
      'cancelRequest': 'अनुरोध रद्द करें',
      'connected': 'कनेक्टेड',
      'connections': 'संपर्क',
      'gallery': 'गैलरी',
      'pasteUrl': 'यहाँ इमेज URL पेस्ट करें...',
      'noImages': 'गैलरी में कोई छवि नहीं है।',
      'deleteImage': 'छवि हटाएं',
      'confirmDelete': 'क्या आप वाकई इस छवि को हटाना चाहते हैं?',
      'cancel': 'रद्द करें',
      'delete': 'हटाएं',
      'paste_image_url': 'यहाँ छवि URL चिपकाएँ...',
    },
    'mr': {
      'userProfile': 'वापरकर्ता प्रोफाइल',
      'businessProfile': 'व्यवसाय प्रोफाइल',
      'businessName': 'व्यवसायाचे नाव',
      'ownerName': 'मालकाचे नाव',
      'email': 'ईमेल',
      'location': 'स्थान',
      'message': 'संदेश',
      'connect': 'कनेक्ट+',
      'cancelRequest': 'विनंती रद्द करा',
      'connected': 'जोडले गेले',
      'connections': 'संपर्क',
      'gallery': 'गॅलरी',
      'pasteUrl': 'येथे इमेज URL पेस्ट करा...',
      'noImages': 'गॅलरीमध्ये चित्रे नाहीत.',
      'deleteImage': 'प्रतिमा हटवा',
      'confirmDelete': 'आपण ही प्रतिमा खरोखर हटवू इच्छिता?',
      'cancel': 'रद्द करा',
      'delete': 'हटवा',
      'paste_image_url': 'इथे प्रतिमा URL चिकटवा...',
    },
  };

  Future<void> _loadConnectionStatus() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || widget.userId == currentUserId) return;

    final targetDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('connectionRequests')
        .doc(currentUserId)
        .get();

    if (targetDoc.exists && targetDoc.data()?['status'] == 'accepted') {
      setState(() => connectionStatus = 'Connected');
    } else if (targetDoc.exists && targetDoc.data()?['status'] == 'pending') {
      setState(() => connectionStatus = 'Request Sent');
    } else {
      setState(() => connectionStatus = 'Make Connection');
    }
  }

  Future<void> _loadMates([String? userId]) async {
    final targetUserId = userId ?? currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(targetUserId)
        .collection('connectionRequests')
        .where('status', isEqualTo: 'accepted')
        .get();

    final Set<String> uniqueMateIds = {};

    final List<Map<String, dynamic>> loadedMates = [];

    for (var doc in snapshot.docs) {
      final mateId = doc.id;

      // Avoid counting self
      if (mateId == targetUserId || uniqueMateIds.contains(mateId)) continue;

      final mateDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(mateId)
          .get();

      if (mateDoc.exists) {
        final mateData = mateDoc.data()!;
        loadedMates.add({
          'id': mateId,
          'name': mateData['businessName'] ?? mateData['email'] ?? 'User',
        });
        uniqueMateIds.add(mateId);
      }
    }

    setState(() {
      mates = loadedMates;
      connectionsCount = loadedMates.length;
    });
  }

  Future<void> _handleConnectionAction() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    if (connectionStatus == 'Make Connection') {
      final confirm = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Send Connection',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const SizedBox
              .shrink(); // Required by API, we override in transitionBuilder
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
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
                    backgroundColor: const Color.fromARGB(255, 241, 21, 135),
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
        await ConnectionService.sendConnectionRequest(widget.userId);
      }
    } else if (connectionStatus == 'Request Sent') {
      await ConnectionService.cancelRequest(widget.userId);
    } else if (connectionStatus == 'Connected') {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pageBuilder: (context, anim1, anim2) {
          return Center(
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, // wider width
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.white,
                  titlePadding: const EdgeInsets.only(top: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
    }
    await _loadConnectionStatus();
  }

  Future<void> _addImageUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userDoc = await userRef.get();
    final isPremium = userDoc.data()?['isPremium'] ?? false;

    final gallerySnapshot = await userRef.collection('gallery').get();
    final imageCount = gallerySnapshot.docs.length;

    if (!isPremium && imageCount >= 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Upgrade to Premium'),
          content: const Text(
              'Only Premium users can upload more than 5 gallery images.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            ElevatedButton(
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
              child: const Text('Go Premium'),
            ),
          ],
        ),
      );
      return;
    }

    await userRef.collection('gallery').add({'url': url});
    _urlController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image added to gallery')),
    );
  }

  Future<void> _deleteImage(String docId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('gallery')
        .doc(docId)
        .delete();
  }

  Widget _buildLabelValue(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(value ?? 'Not available'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color softPink = Color(0xFFF8BBD0);
    const Color rosePink = Color.fromARGB(255, 251, 91, 144);
    const Color blushPink = Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: blushPink,
      appBar: AppBar(
        title: Text(localizedStrings[widget.language]!['userProfile']!),
        backgroundColor: const Color.fromARGB(255, 243, 97, 145),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists)
            return const Center(child: Text('User not found'));

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFB6F92), Color(0xFFFEC8D8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      localizedStrings[widget.language]!['businessProfile']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    if (user['profileImageUrl'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImagePage(
                            imageUrl: user['profileImageUrl'],
                          ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: user['profileImageUrl'] != null
                        ? NetworkImage(user['profileImageUrl'])
                        : null,
                    child: user['profileImageUrl'] == null
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildLabelValue(
                            Icons.business,
                            localizedStrings[widget.language]!['businessName']!,
                            user['businessName']),
                        _buildLabelValue(
                            Icons.person,
                            localizedStrings[widget.language]!['ownerName']!,
                            user['ownerName']),
                        _buildLabelValue(
                            Icons.email,
                            localizedStrings[widget.language]!['email']!,
                            user['email']),
                        _buildLabelValue(
                            Icons.location_on,
                            localizedStrings[widget.language]!['location']!,
                            user['location']),
                      ],
                    ),
                  ),
                ),
                if (!isSelf)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.message),
                        label: Text(
                            localizedStrings[widget.language]!['message']!),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                receiverId: widget.userId,
                                receiverName: user['businessName'] ?? 'User',
                                language: widget.language,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[850],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ElevatedButton(
                            onPressed: _handleConnectionAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: connectionStatus == 'Connected'
                                  ? Colors.green
                                  : connectionStatus == 'Request Sent'
                                      ? const Color.fromARGB(255, 14, 60, 188)
                                      : const Color.fromARGB(255, 234, 59, 15),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text(
                              connectionStatus == 'Connected'
                                  ? 'Connected'
                                  : connectionStatus == 'Request Sent'
                                      ? 'Cancel Request'
                                      : 'Connect+',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (mates.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConnectionsListPage(
                              userId: widget.userId, language: widget.language),
                        ),
                      );
                    },
                    icon: const Icon(Icons.people),
                    label: Text(
                        '${localizedStrings[widget.language]!['connections']} ($connectionsCount)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 231, 22, 162),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                const SizedBox(height: 10),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${localizedStrings[widget.language]!['gallery']}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                if (isSelf)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            hintText:
                                '${localizedStrings[widget.language]!['paste_image_url']}',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: softPink),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addImageUrl,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: rosePink,
                          foregroundColor: Colors.white,
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('gallery')
                      .snapshots(),
                  builder: (context, gallerySnap) {
                    if (!gallerySnap.hasData)
                      return const CircularProgressIndicator();
                    final images = gallerySnap.data!.docs;

                    if (images.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('No images in gallery.'),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: images.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final doc = images[index];
                        final imageUrl = doc['url'];

                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FullScreenImagePage(imageUrl: imageUrl),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                          child: Icon(Icons.broken_image)),
                                ),
                              ),
                            ),
                            if (isSelf)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () async {
                                    final shouldDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Image'),
                                        content: const Text(
                                            'Are you sure you want to delete this image?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldDelete == true) {
                                      await _deleteImage(doc.id);
                                    }
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white, size: 16),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: Colors.white, size: 60),
          ),
        ),
      ),
    );
  }
}
