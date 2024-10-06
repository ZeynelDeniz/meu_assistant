import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/typing_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  static const String routeName = '/chat';

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put<ChatController>(ChatController());

    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.chatScreenTitle,
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: GetBuilder<ChatController>(builder: (controller) {
                return chatController.isLoading.value
                    ? Center(child: const CircularProgressIndicator.adaptive())
                    : ListView.builder(
                        controller: chatController.scrollController,
                        itemCount: chatController.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatController.messages[index];
                          return ListTile(
                            title: Align(
                              alignment: message.isSentByUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: message.isSentByUser
                                    ? const EdgeInsets.only(left: 100)
                                    : const EdgeInsets.only(right: 100),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: message.isSentByUser
                                      ? Colors.blue
                                      : const Color.fromARGB(255, 80, 80, 80),
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
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.chatScreenInputHint,
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
