
// File: chat_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'premium_page.dart';
import 'user_profile_page.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String language;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.language,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? _receiverImageUrl;
  Map<String, String> _userProfilePhotos = {};
  Set<String> _selectedMessages = {};
  bool _isSelecting = false;

  String get chatId {
    final ids = [currentUserId, widget.receiverId]..sort();
    return ids.join('_');
  }

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _loadReceiverProfile();
  }

  Future<void> _loadReceiverProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .get();
    if (doc.exists) {
      setState(() {
        _receiverImageUrl = doc.data()?['profileImageUrl'] ?? '';
      });
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    if (_userProfilePhotos.containsKey(userId)) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (doc.exists) {
      setState(() {
        _userProfilePhotos[userId] = doc.data()?['profileImageUrl'] ?? '';
      });
    }
  }

  Future<void> _markMessagesAsRead() async {
    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .get();

    for (var doc in unreadMessages.docs) {
      doc.reference.update({'read': true});
    }
  }

  Future<bool> _checkIfConnected(String currentUserId, String receiverId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('connectionRequests')
        .where('fromUid', isEqualTo: receiverId)
        .where('status', isEqualTo: 'accepted')
        .get();
    return snapshot.docs.isNotEmpty;
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Premium Required"),
        content: const Text("You've reached the free limit of 5 messages. Upgrade to premium to continue."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PremiumPage(language: widget.language),
                ),
              );
            },
            child: const Text("Get Premium"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final text = _controller.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    final bool isPremium = currentUserDoc.data()?['isPremium'] == true;
    final bool isConnected = await _checkIfConnected(currentUserId, widget.receiverId);

    if (isPremium || isConnected) {
      await _actuallySendMessage(imageUrl ?? text, imageUrl != null);
      return;
    }

    final limitDocRef = FirebaseFirestore.instance
        .collection('limits')
        .doc(currentUserId)
        .collection('chats')
        .doc(widget.receiverId);

    final limitDoc = await limitDocRef.get();
    int currentCount = limitDoc.exists && limitDoc.data()?['count'] is int
        ? limitDoc.data()!['count']
        : 0;

    if (currentCount < 3) {
      await _actuallySendMessage(imageUrl ?? text, imageUrl != null);
      await limitDocRef.set({'count': currentCount + 1}, SetOptions(merge: true));
    } else {
      _showPremiumDialog();
    }
  }

  Future<void> _actuallySendMessage(String messageText, bool isImage) async {
    final timestamp = Timestamp.now();
    final sender = FirebaseAuth.instance.currentUser!;
    final messageRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    await messageRef.add({
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'text': messageText,
      'timestamp': timestamp,
      'read': false,
      'isImage': isImage,
      'senderName': sender.displayName ?? sender.email ?? 'User',
    });

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'participants': [currentUserId, widget.receiverId],
      'lastMessage': messageText,
      'timestamp': timestamp,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.receiverId)
        .collection('notifications')
        .add({
      'type': 'message',
      'from': currentUserId,
      'fromName': sender.displayName ?? sender.email ?? 'Someone',
      'text': messageText,
      'timestamp': timestamp,
      'read': false,
    });

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _toggleSelection(String messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
      } else {
        _selectedMessages.add(messageId);
      }
      _isSelecting = _selectedMessages.isNotEmpty;
    });
  }

  Future<void> _deleteSelectedMessages() async {
    final batch = FirebaseFirestore.instance.batch();
    for (var id in _selectedMessages) {
      final docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(id);
      batch.delete(docRef);
    }
    await batch.commit();
    setState(() {
      _selectedMessages.clear();
      _isSelecting = false;
    });
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final messages = await FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .get();

              final batch = FirebaseFirestore.instance.batch();
              for (var msg in messages.docs) {
                batch.delete(msg.reference);
              }
              await batch.commit();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAddImageDialog() {
    final TextEditingController urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Send Image via URL"),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: "Enter Image URL"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final url = urlController.text.trim();
                final isValidImageUrl = Uri.tryParse(url)?.hasAbsolutePath == true &&
                    (url.endsWith('.jpg') ||
                        url.endsWith('.jpeg') ||
                        url.endsWith('.png') ||
                        url.endsWith('.gif') ||
                        url.endsWith('.webp'));

                if (isValidImageUrl) {
                  _sendMessage(imageUrl: url);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid image URL')),
                  );
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E44AD),
        elevation: 2,
        title: Text(widget.receiverName),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedMessages,
                ),
              ]
            : [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'clear') _confirmClearChat();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
                  ],
                ),
              ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return const Center(child: Text('Say Hi 👋'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final data = msg.data() as Map<String, dynamic>;
                    final senderId = data['senderId'];
                    final isMe = senderId == currentUserId;
                    final timestamp = data['timestamp'] != null
                        ? (data['timestamp'] as Timestamp).toDate()
                        : DateTime.now();
                    final time = DateFormat('h:mm a').format(timestamp);
                    final isImage = data['isImage'] ?? false;
                    final text = data['text'] ?? '';
                    final selected = _selectedMessages.contains(msg.id);

                    return GestureDetector(
                      onLongPress: isMe ? () => _toggleSelection(msg.id) : null,
                      onTap: _isSelecting && isMe ? () => _toggleSelection(msg.id) : null,
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.red[200]
                                : isMe
                                    ? const Color(0xFF8E44AD)
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isMe ? 12 : 0),
                              bottomRight: Radius.circular(isMe ? 0 : 12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              isImage
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(text, width: 180, height: 150, fit: BoxFit.cover),
                                    )
                                  : Text(
                                      text,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isMe ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showAddImageDialog,
                  icon: const Icon(Icons.image, color: Color(0xFF8E44AD)),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type message...",
                      border: InputBorder.none,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                IconButton(
                  onPressed: () => _sendMessage(),
                  icon: const Icon(Icons.send, color: Color(0xFF8E44AD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
