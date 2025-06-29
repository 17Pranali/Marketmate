import 'package:flutter/material.dart';
import 'marketmate_ai_page.dart';

class MarketMateAIFab extends StatelessWidget {
  const MarketMateAIFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      child: const Icon(Icons.chat),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MarketMateAIPage()),
        );
      },
    );
  }
}
