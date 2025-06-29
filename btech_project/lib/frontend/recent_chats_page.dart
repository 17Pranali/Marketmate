import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class RecentChatsPage extends StatefulWidget {
  final String language; // 'en', 'mr', or 'hi'
  const RecentChatsPage({super.key, required this.language});

  @override
  State<RecentChatsPage> createState() => _RecentChatsPageState();
}

class _RecentChatsPageState extends State<RecentChatsPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> allChats = [];
  List<Map<String, dynamic>> filteredChats = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  // Translations map
  final Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'recent_chats': 'Recent Chats',
      'search_hint': 'Search by Business Name...',
      'no_chats': 'No Recent Chats Found!',
    },
    'mr': {
      'recent_chats': 'अलीकडील चॅट्स',
      'search_hint': 'व्यवसाय नावाने शोधा...',
      'no_chats': 'कोणतेही अलीकडील चॅट्स आढळले नाहीत!',
    },
    'hi': {
      'recent_chats': 'हाल की चैट्स',
      'search_hint': 'व्यवसाय के नाम से खोजें...',
      'no_chats': 'कोई हाल की चैट नहीं मिली!',
    },
  };

  String getText(String key) {
    return localizedStrings[widget.language]?[key] ??
        localizedStrings['en']![key]!;
  }

  @override
  void initState() {
    super.initState();
    _loadChats();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredChats = allChats.where((chat) {
        final name = chat['userName'].toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _loadChats() async {
    final chatsSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    List<Map<String, dynamic>> recentChats = [];

    for (var doc in chatsSnapshot.docs) {
      final data = doc.data();
      String chatId = doc.id;

      String? lastMessage = data['lastMessage'];
      Timestamp? timestamp = data['timestamp'];

      if (lastMessage == null || timestamp == null) {
        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final msg = messagesSnapshot.docs.first.data();
          lastMessage = msg['text'] ?? '';
          timestamp = msg['timestamp'];
        }
      }

      if (lastMessage == null || timestamp == null) continue;

      List participants = data['participants'] ?? [];
      String otherUserId = participants.firstWhere((id) => id != currentUserId);

      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get();
      final userData = userSnapshot.data();

      if (userData != null) {
        recentChats.add({
          'userId': otherUserId,
          'userName': userData['businessName'] ??
              userData['ownerName'] ??
              userData['email'] ??
              'User',
          'lastMessage': lastMessage,
          'timestamp': timestamp,
          'profileImageUrl': userData['profileImageUrl'],
        });
      }
    }

    recentChats.sort((a, b) =>
        (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

    setState(() {
      allChats = recentChats;
      filteredChats = recentChats;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color rosePink = Color(0xFFE91E63);
    const Color softPink = Color(0xFFF8BBD0);
    const Color lightPink = Color(0xFFFFF0F5);

    return Scaffold(
      backgroundColor: lightPink,
      appBar: AppBar(
        title: Text(getText('recent_chats')),
        backgroundColor: rosePink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: getText('search_hint'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // --- Chat List ---
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE91E63)),
                  )
                : filteredChats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_bubble_outline,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 20),
                            Text(
                              getText('no_chats'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredChats.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                      receiverId: chat['userId'],
                                      receiverName: chat['userName'],
                                      language: widget.language),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color.fromARGB(255, 248, 246, 247)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(color: softPink),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: softPink,
                                  backgroundImage: chat['profileImageUrl'] !=
                                          null
                                      ? NetworkImage(chat['profileImageUrl'])
                                      : null,
                                  child: chat['profileImageUrl'] == null
                                      ? const Icon(Icons.person,
                                          color: Colors.white, size: 30)
                                      : null,
                                ),
                                title: Text(
                                  chat['userName'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    chat['lastMessage'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: rosePink.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatTime((chat['timestamp'] as Timestamp)
                                        .toDate()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}
