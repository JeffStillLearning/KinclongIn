import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugChatPage extends StatelessWidget {
  const DebugChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Chat Data'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat Rooms:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text('No chat rooms found');
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${doc.id}'),
                            Text('Customer: ${data['customerName'] ?? 'N/A'}'),
                            Text('Email: ${data['customerEmail'] ?? 'N/A'}'),
                            Text('Last Message: ${data['lastMessage'] ?? 'N/A'}'),
                            Text('Last Sender: ${data['lastMessageSender'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              'Messages:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Text('No messages found');
                }

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${doc.id}'),
                            Text('Chat Room: ${data['chatRoomId'] ?? 'N/A'}'),
                            Text('Sender: ${data['senderName'] ?? 'N/A'} (${data['senderRole'] ?? 'N/A'})'),
                            Text('Message: ${data['message'] ?? 'N/A'}'),
                            Text('Read: ${data['isRead'] ?? false}'),
                            Text('Timestamp: ${data['timestamp']?.toDate() ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
