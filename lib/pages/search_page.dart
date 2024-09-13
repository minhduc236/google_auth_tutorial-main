import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/chat_page.dart'; // Import ChatPage

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<DocumentSnapshot> _userResults = [];
  List<DocumentSnapshot> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations(); // Load previous conversations
  }

  // Hàm tạo ID duy nhất cho cuộc trò chuyện giữa hai người dùng
  String _getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode ? '$userId1-$userId2' : '$userId2-$userId1';
  }

  // Load previously messaged users (lấy những người đã nhắn tin gần đây)
  void _loadConversations() async {
    try {
      final QuerySnapshot conversationSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: _currentUserId)
          .get();

      if (mounted) {
        setState(() {
          _conversations = conversationSnapshot.docs;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error loading conversations: $e');
      }
    }
  }

  // Xóa cuộc trò chuyện và tất cả tin nhắn liên quan
  void _deleteConversation(String chatId) async {
    try {
      // Xóa các tin nhắn trong cuộc trò chuyện trước
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete(); // Xóa từng tin nhắn
      }

      // Sau khi xóa hết tin nhắn, xóa cuộc trò chuyện
      await _firestore.collection('chats').doc(chatId).delete();

      setState(() {
        _conversations.removeWhere((conversation) => conversation.id == chatId);
      });
    } catch (e) {
      _showErrorMessage('Error deleting conversation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm người dùng'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm người dùng (số điện thoại hoặc email)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchUsers,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Cuộc trò chuyện gần đây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          // List of previously messaged users (danh sách cuộc trò chuyện gần đây)
          Expanded(
            child: _userResults.isEmpty // Nếu không tìm kiếm, hiển thị danh sách cuộc trò chuyện gần đây
                ? _conversations.isNotEmpty
                ? ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final conversation = _conversations[index];
                final participants = conversation['participants'] as List<dynamic>;
                final otherUserId = participants.firstWhere(
                      (id) => id != _currentUserId,
                  orElse: () => null,
                );

                // Kiểm tra nếu trường 'lastMessageRead' tồn tại
                final bool hasUnreadMessages = (conversation.data() as Map<String, dynamic>)
                    .containsKey('lastMessageRead')
                    ? !(conversation['lastMessageRead'] ?? true)
                    : false;

                if (otherUserId == null) {
                  return const ListTile(title: Text('No other participant found'));
                }

                return FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('users').doc(otherUserId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(title: Text('Loading...'));
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const ListTile(title: Text('No user data available'));
                    }

                    final otherUser = snapshot.data;
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              otherUser != null &&
                                  (otherUser.data() as Map<String, dynamic>).containsKey('avatarUrl')
                                  ? (otherUser.data() as Map<String, dynamic>)['avatarUrl']
                                  : 'https://via.placeholder.com/150',
                            ),
                          ),
                          if (hasUnreadMessages) // Hiển thị chấm đỏ nếu có tin nhắn chưa đọc
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(otherUser?['name'] ?? 'Unknown'),
                      subtitle: Text(otherUser?['email'] ?? 'No email'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteConversation(conversation.id); // Xóa cuộc trò chuyện và tin nhắn
                        },
                      ),
                      onTap: () {
                        // Tạo ID cuộc trò chuyện
                        String chatId = _getChatId(_currentUserId, otherUserId);

                        // Điều hướng tới ChatPage khi nhấn vào cuộc trò chuyện
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatPage(selectedUserId: otherUserId, chatId: chatId),
                          ),
                        ).then((_) {
                          // Khi quay lại từ ChatPage, đánh dấu tin nhắn là đã đọc
                          _markMessagesAsRead(conversation.id);
                        });
                      },
                    );
                  },
                );
              },
            )
                : const Center(child: Text('Chưa có cuộc trò chuyện gần đây'))
                : _buildSearchResults(), // Nếu có tìm kiếm, hiển thị kết quả tìm kiếm
          ),
        ],
      ),
    );
  }

  // Đánh dấu tin nhắn đã đọc
  void _markMessagesAsRead(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessageRead': true, // Đánh dấu là đã đọc
      });
    } catch (e) {
      _showErrorMessage('Error marking messages as read: $e');
    }
  }

  // Hàm hiển thị kết quả tìm kiếm
  Widget _buildSearchResults() {
    return _userResults.isNotEmpty
        ? ListView.builder(
      itemCount: _userResults.length,
      itemBuilder: (context, index) {
        final user = _userResults[index];
        final userId = user.id;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              user.data() != null &&
                  (user.data() as Map<String, dynamic>).containsKey('avatarUrl')
                  ? (user.data() as Map<String, dynamic>)['avatarUrl']
                  : 'https://via.placeholder.com/150',
            ),
          ),
          title: Text(user['name'] ?? 'Unknown'),
          subtitle: Text(user['email'] ?? 'No email'),
          onTap: () {
            // Tạo ID cuộc trò chuyện
            String chatId = _getChatId(_currentUserId, userId);

            // Điều hướng tới ChatPage với ID của người dùng được chọn
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(selectedUserId: userId, chatId: chatId),
              ),
            );
          },
        );
      },
    )
        : const Center(child: Text('No users found'));
  }

  // Hàm tìm kiếm người dùng theo số điện thoại hoặc email
  void _searchUsers() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    QuerySnapshot result;

    try {
      if (RegExp(r'^\d+$').hasMatch(query)) {
        result = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: query)
            .get();
      } else {
        result = await _firestore
            .collection('users')
            .where('email', isEqualTo: query)
            .get();
      }

      if (mounted) {
        setState(() {
          _userResults = result.docs;
        });
        if (result.docs.isEmpty) {
          _showErrorMessage('No users found matching the query');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error searching users: $e');
      }
    }
  }

  // Hàm hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
