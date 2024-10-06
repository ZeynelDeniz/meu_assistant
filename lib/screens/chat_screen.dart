import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  static const String routeName = '/chat';

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put<ChatController>(ChatController());

    return BaseScaffold(
      appBarTitle: "AI Asistan",
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: GetBuilder<ChatController>(builder: (controller) {
                return ListView.builder(
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatController.messages[index];
                    return ListTile(
                      title: Align(
                        alignment:
                            message.isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.isSentByUser ? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            GetBuilder<ChatController>(
              builder: (controller) {
                return TypingIndicator(isTyping: controller.isTyping);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: !chatController.isLoading.value,
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter your message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: chatController.isLoading.value
                        ? null
                        : () {
                            final message = _controller.text;
                            if (message.isNotEmpty) {
                              chatController.addMessage(message, true);
                              _controller.clear();
                            }
                          },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
