import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/chat_message.dart';

//TODO Add Voice Recognition or NLP

//TODO DENİZ: Add to knowledge base: Öğrenci Kayıt Süreci

//TODO When sending a message, add info about the user. Ex: App language

class ChatController extends GetxController {
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  List<ChatMessage> get messages => _messages.reversed.toList();

  late Database _database;
  bool isTyping = false;
  final RxBool isLoading = true.obs;

  final ScrollController scrollController = ScrollController();
  final RxBool showScrollDownButton = false.obs;

  //TODO DENİZ Soruları düzenle. app_tr ve app_en'de
  List<String> get sampleQuestions => [
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
      // User is near the top
      showScrollDownButton.value = false;
    } else {
      // User is not near the top
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
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, isSentByUser INTEGER)',
        );
      },
      version: 1,
    );
    _loadMessages();
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
    isTyping = true;
    update(); // Refresh the UI

    try {
      //TODO Remove later, dummy delay
      await Future.delayed(Duration(seconds: 1));
      // Make an HTTP request
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('Failed to fetch data: $e');
      // Handle the error, e.g., show a message to the user
    }

    // Mock delay and reply
    final replyMessage =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
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

    // Hide typing indicator
    isTyping = false;
    update(); // Refresh the UI
  }
}
