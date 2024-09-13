import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class ChatPage extends StatefulWidget {
  final String selectedUserId;
  final String chatId;

  const ChatPage({Key? key, required this.selectedUserId, required this.chatId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final logger = Logger();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead(); // Đánh dấu tin nhắn là đã đọc khi người nhận mở cuộc trò chuyện
  }

  // Đánh dấu tất cả tin nhắn là đã đọc cho người nhận
  void _markMessagesAsRead() async {
    try {
      // Kiểm tra nếu người dùng hiện tại là người nhận (người không gửi tin nhắn)
      if (_auth.currentUser!.uid == widget.selectedUserId) {
        await _firestore.collection('chats').doc(widget.chatId).update({
          'lastMessageRead': true, // Đánh dấu tin nhắn là đã đọc cho người nhận
        });
      }
    } catch (e) {
      logger.e('Error marking messages as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == _auth.currentUser!.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(0),
                            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(18),
                          ),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blueAccent,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm gửi tin nhắn
  void _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty) return;

    try {
      // Khi gửi tin nhắn, cập nhật trạng thái tin nhắn là chưa đọc cho người nhận
      await _firestore.collection('chats').doc(widget.chatId).set({
        'participants': [_auth.currentUser!.uid, widget.selectedUserId],
        'lastMessageRead': false, // Đánh dấu tin nhắn cuối là chưa đọc cho người nhận
      }, SetOptions(merge: true));

      // Lưu tin nhắn vào sub-collection 'messages'
      await _firestore.collection('chats').doc(widget.chatId).collection('messages').add({
        'text': message,
        'senderId': _auth.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    } catch (e) {
      logger.e('Error sending message: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
