import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;

  const TypingIndicator({super.key, required this.isTyping});

  @override
  Widget build(BuildContext context) {
    return isTyping
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.more_horiz, color: Colors.grey),
              Text("Typing...", style: TextStyle(color: Colors.grey)),
            ],
          )
        : Container();
  }
}
