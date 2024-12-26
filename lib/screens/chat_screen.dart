import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/chat_controller.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/typing_indicator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  static const String routeName = '/chat';

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  //TODO Links look weird in the chat, fix the link style

  TextSpan buildMessageSpan(String message) {
    //TODO Something wrong here, message repeats itself.
    final locRegex = RegExp(r'<loc_(\d+)>');
    final urlRegex = RegExp(r'<url_(https?://[^\s]+)>');
    // final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    int start = 0;

    message.splitMapJoin(
      RegExp(r'<loc_(\d+)>|<url_(https?://[^\s]+)>'), // Remove bold regex from here
      onMatch: (match) {
        final locMatch = locRegex.firstMatch(match[0]!);
        final urlMatch = urlRegex.firstMatch(match[0]!);
        // final boldMatch = boldRegex.firstMatch(match[0]!); // Comment out bold match

        if (locMatch != null) {
          final locationNumber = locMatch.group(1);
          spans.add(TextSpan(
            text: message.substring(start, match.start),
          ));
          spans.add(TextSpan(
            text: 'loc_$locationNumber',
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                final locationId = int.tryParse(locationNumber ?? '');
                if (locationId != null) {
                  Get.offAndToNamed('/map', arguments: {'initialLocationId': locationId});
                }
              },
          ));
          start = match.end;
        } else if (urlMatch != null) {
          final url = urlMatch.group(1);
          spans.add(TextSpan(
            text: message.substring(start, match.start),
          ));
          spans.add(TextSpan(
            text: url,
            style: TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(url!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $url';
                }
              },
          ));
          start = match.end;
        }

        return '';
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(text: nonMatch));
        return '';
      },
    );
    for (var span in spans) {
      log(span.toString());
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put<ChatController>(ChatController());

    return BaseScaffold(
      appBarTitle: AppLocalizations.of(context)!.chatScreenTitle,
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GetBuilder<ChatController>(builder: (controller) {
                    return chatController.isLoading.value
                        ? Center(child: const CircularProgressIndicator.adaptive())
                        : ListView.builder(
                            controller: chatController.scrollController,
                            itemCount: chatController.messages.length + 2,
                            reverse: true,
                            itemBuilder: (context, index) {
                              if (index == 1) {
                                return TypingIndicator(
                                  isTyping: chatController.isTyping.value,
                                );
                              }
                              if (index == 0) {
                                return SizedBox(
                                  height:
                                      Theme.of(context).platform == TargetPlatform.iOS ? 22 : 56,
                                );
                              }
                              final message = chatController.messages[index - 2];
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
                                    child: RichText(
                                      text: buildMessageSpan(message.message),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                  }),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 60,
                      child: RawScrollbar(
                        scrollbarOrientation: ScrollbarOrientation.top,
                        controller: _scrollController,
                        interactive: false,
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
                                margin: EdgeInsets.only(
                                  right: 8.0,
                                  left: 8.0,
                                  bottom: 8.0,
                                  top: 8.0,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[700],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    chatController.sampleQuestions[index],
                                    style:
                                        const TextStyle(color: Color.fromARGB(255, 230, 230, 230)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 70,
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 8.0,
                left: 8.0,
                bottom: 8.0,
              ),
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
