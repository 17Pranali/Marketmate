import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketMateAIPage extends StatefulWidget {
  const MarketMateAIPage({super.key});

  @override
  State<MarketMateAIPage> createState() => _MarketMateAIPageState();
}

class _MarketMateAIPageState extends State<MarketMateAIPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  void sendMessage(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
      _controller.clear();
    });

    await Future.delayed(const Duration(milliseconds: 500));

    String answer = await getBestMatchingAnswer(text.trim());

    setState(() {
      messages.add({"role": "ai", "text": answer});
    });
  }

  Future<String> getBestMatchingAnswer(String userInput) async {
    final words = userInput.toLowerCase().split(RegExp(r'\W+'));
    final snapshot =
        await FirebaseFirestore.instance.collection('questions').get();

    String bestAnswer = "Sorry, I don’t know the answer to that.";
    int maxMatchCount = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rawKeywords = data['keywords'];

      if (rawKeywords == null || rawKeywords is! List) continue;

      final keywords =
          rawKeywords.map((e) => e.toString().toLowerCase()).toList();
      final answer = (data['answer'] ?? "").toString().trim();

      int matchCount = words.where((word) => keywords.contains(word)).length;

      if (matchCount > maxMatchCount && matchCount > 0) {
        maxMatchCount = matchCount;
        bestAnswer = answer;
      }
    }

    return bestAnswer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MarketMate Chatbot"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      "Heyy, how can I help you?",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message['role'] == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                isUser ? Colors.blue[100] : Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(message['text'] ?? ''),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask something...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromARGB(255, 77, 41, 184)),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      sendMessage(_controller.text.trim());
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
