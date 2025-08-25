import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chatscreen extends StatefulWidget {
  final String currentUserId;   // logged-in user (devotee)
  final String templeAdminId;   // temple (admin)

  const Chatscreen({
    Key? key,
    required this.currentUserId,
    required this.templeAdminId,
  }) : super(key: key);

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _templeName;

  // Generate consistent chat ID (sorted so both sides get same id)
  String get chatId {
    List<String> ids = [widget.currentUserId, widget.templeAdminId];
    ids.sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  void initState() {
    super.initState();
    _fetchTempleName();
  }

  Future<void> _fetchTempleName() async {
    try {
      final doc =
      await _firestore.collection('temples').doc(widget.templeAdminId).get();
      if (doc.exists) {
        setState(() {
          _templeName = doc['name'] ?? 'Temple';
        });
      }
    } catch (e) {
      print('❌ Error fetching temple name: $e');
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      print("📩 [User] Sending message: $message");
      print("ChatId: $chatId");
      print("Sender: ${widget.currentUserId} → Receiver: ${widget.templeAdminId}");

      // Create or update chat document
      await _firestore.collection('chats').doc(chatId).set({
        'participants': [widget.currentUserId, widget.templeAdminId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Chat doc updated with lastMessage: $message");

      // Add message to messages subcollection
      final msgRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': widget.currentUserId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("✅ Message saved under chats/$chatId/messages/${msgRef.id}");

      _messageController.clear();
    } catch (e) {
      print('❌ Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_templeName ?? 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final data = message.data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.currentUserId;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['text'] ?? "",
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
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
