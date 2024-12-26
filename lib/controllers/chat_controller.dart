import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:meu_assistant/constants/api_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/chat_message.dart';

//TODO Connect the map pins, add a button to navigate from chat to map with the selected location

class ChatController extends GetxController {
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  List<ChatMessage> get messages => _messages.reversed.toList();

  late Database _database;
  final RxBool isLoading = true.obs;
  final RxBool isTyping = false.obs;

  final ScrollController scrollController = ScrollController();
  final RxBool showScrollDownButton = false.obs;

  late String _conversationId;

  List<String> get sampleQuestions => [
        //TODO Change static questions to dynamic, randomize.
        AppLocalizations.of(Get.context!)!.question1,
        AppLocalizations.of(Get.context!)!.question2,
        AppLocalizations.of(Get.context!)!.question3,
        AppLocalizations.of(Get.context!)!.question4,
        AppLocalizations.of(Get.context!)!.question5,
      ];

  void animateToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onInit() {
    super.onInit();
    // _deleteOldDatabase();
    _initDatabase();
    scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  void _scrollListener() {
    const threshold = 1000; // Adjust this value as needed
    if (scrollController.position.pixels <= threshold) {
      // User is not near the top
      showScrollDownButton.value = false;
    } else {
      // User is near the top
      showScrollDownButton.value = true;
    }
  }

  //* Uncomment this method and add to onInit to delete the old database
  // Future<void> _deleteOldDatabase() async {
  //   final databasePath = path.join(await getDatabasesPath(), 'chat_database.db');
  //   await deleteDatabase(databasePath);
  // }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      path.join(await getDatabasesPath(), 'chat_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, isSentByUser INTEGER)',
        );
        await db.execute(
          'CREATE TABLE conversation(id INTEGER PRIMARY KEY AUTOINCREMENT, conversationId TEXT)',
        );
      },
      version: 1,
    );
    await _loadConversationId();
    _loadMessages();
  }

  Future<void> _loadConversationId() async {
    final List<Map<String, dynamic>> maps = await _database.query('conversation');
    if (maps.isNotEmpty) {
      _conversationId = maps.first['conversationId'];
    } else {
      _conversationId = _generateConversationId();
      await _database.insert(
        'conversation',
        {'conversationId': _conversationId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  String _generateConversationId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> _loadMessages() async {
    final List<Map<String, dynamic>> maps = await _database.query('messages');
    _messages.addAll(List.generate(maps.length, (i) {
      return ChatMessage(
        id: maps[i]['id'],
        message: maps[i]['message'],
        isSentByUser: maps[i]['isSentByUser'] == 1,
      );
    }));
    isLoading(false);
    update(); // Update the UI after loading messages
  }

  String formattedMessage(String message) {
    log('Message without Format: $message');

    // Remove messages written in []
    final regex = RegExp(r'\[.*?\]');
    message = message.replaceAll(regex, '');

    // Remove the **
    message = message.replaceAll('**', '');

    // Find and replace loc_XX with a placeholder
    final locRegex = RegExp(r'loc_(\d+)');
    message = message.replaceAllMapped(locRegex, (match) {
      final locationNumber = match.group(1);
      return '<loc_$locationNumber>'; // Placeholder for clickable text
    });

    // Find and replace URLs within parentheses with a placeholder
    final urlRegex = RegExp(r'\((https?://[^\s]+)\)');
    message = message.replaceAllMapped(urlRegex, (match) {
      final url = match.group(1);
      return '<url_$url>'; // Placeholder for clickable URL
    });

    log('Message with Format: $message');

    return message.trim();
  }

  Future<void> addMessage(String message, bool isSentByUser) async {
    // Check the number of messages
    final count = Sqflite.firstIntValue(await _database.rawQuery('SELECT COUNT(*) FROM messages'));
    if (count != null && count >= 30) {
      // Delete the oldest message
      await _database.delete(
        'messages',
        where: 'id = (SELECT id FROM messages ORDER BY id ASC LIMIT 1)',
      );
    }

    // Insert the new message without specifying the id
    final id = await _database.insert(
      'messages',
      ChatMessage(message: message, isSentByUser: isSentByUser).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _messages.add(ChatMessage(id: id, message: message, isSentByUser: isSentByUser));

    // Show typing indicator
    isTyping.value = true;
    update(); // Refresh the UI

    try {
      // Prepare the messages for the API request
      final messagesForApi = _messages.map((msg) {
        return {
          'content': msg.message,
          'role': msg.isSentByUser ? 'user' : 'assistant',
        };
      }).toList();

      log('Conversation ID: $_conversationId');

      // Make an HTTP request to the Chatbase API
      final response = await http.post(
        Uri.parse(chatbaseApiUrl),
        headers: {
          'Authorization': 'Bearer $chatbaseKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'messages': messagesForApi,
          'chatbotId': chatBotId,
          'conversationId': _conversationId,
          'stream': false,
          'temperature': 0,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        log('Failed to fetch data: ${errorData['message']}');
      }

      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      String replyMessage = data['text'];
      replyMessage += ' loc_45'; //TODO Temporary, implement later.

      log('Reply message: $replyMessage');

      // Format the reply message
      replyMessage = formattedMessage(replyMessage);

      // Insert the reply message into the database
      final replyId = await _database.insert(
        'messages',
        ChatMessage(
          message: replyMessage,
          isSentByUser: false,
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _messages.add(
        ChatMessage(
          id: replyId,
          message: replyMessage,
          isSentByUser: false,
        ),
      );
    } catch (e) {
      log('Failed to fetch data: $e');
      // Handle the error, e.g., show a message to the user
    }

    // Hide typing indicator
    isTyping.value = false;
    update(); // Refresh the UI
  }
}
