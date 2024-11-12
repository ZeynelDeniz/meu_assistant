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
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put<ChatController>(ChatController());

    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.chatScreenTitle,
      body: Obx(() {
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: GetBuilder<ChatController>(builder: (controller) {
                    return chatController.isLoading.value
                        ? Center(child: const CircularProgressIndicator.adaptive())
                        : ListView.builder(
                            controller: chatController.scrollController,
                            itemCount: chatController.messages.length,
                            reverse: true,
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
                SizedBox(
                  height: 50,
                  child: Scrollbar(
                    controller: _scrollController,
                    interactive: true,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: chatController.sampleQuestions.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: chatController.isLoading.value
                              ? null
                              : () {
                                  final message = chatController.sampleQuestions[index];
                                  chatController.addMessage(message, true);
                                },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                chatController.sampleQuestions[index],
                                style: const TextStyle(color: Color.fromARGB(255, 230, 230, 230)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
            ),
            Positioned(
              bottom: 80,
              right: 16,
              child: chatController.showScrollDownButton.value
                  ? FadeTransition(
                      opacity: AlwaysStoppedAnimation(1.0),
                      child: FloatingActionButton(
                        onPressed: chatController.animateToBottom,
                        child: const Icon(Icons.arrow_downward),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      }),
    );
  }
}
