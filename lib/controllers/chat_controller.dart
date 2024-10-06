import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

import '../models/chat_message.dart';

class ChatController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  late Database _database;
  bool isTyping = false; // Declare isTyping
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initDatabase();
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
    messages.addAll(List.generate(maps.length, (i) {
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
    if (count != null && count >= 20) {
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
    messages.add(ChatMessage(id: id, message: message, isSentByUser: isSentByUser));

    // Show typing indicator
    isTyping = true;
    update(); // Refresh the UI

    // Mock delay and reply
    await Future.delayed(const Duration(seconds: 2));
    final replyId = await _database.insert(
      'messages',
      ChatMessage(message: "This will be a reply from chatgpt", isSentByUser: false).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    messages.add(ChatMessage(
        id: replyId, message: "This will be a reply from chatgpt", isSentByUser: false));

    // Hide typing indicator
    isTyping = false;
    update(); // Refresh the UI
  }
}
