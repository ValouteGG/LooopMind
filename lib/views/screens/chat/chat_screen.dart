import 'package:flutter/material.dart';
import '../../../services/groq_service.dart';

enum MessageType { user, bot }

class Message {
  final String text;
  final MessageType type;

  Message({required this.text, required this.type});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [
    Message(
        text:
            "Hey!! Im here to help you generate weekly summaries based on your completed tasks. Try asking me for a summary of your week! Just tell me to generate and i will!📝",
        type: MessageType.bot),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text.trim().toLowerCase();

    setState(() {
      _messages
          .add(Message(text: _controller.text.trim(), type: MessageType.user));
    });

    _controller.clear();
    _scrollToBottom();

    String response;
    if (message.contains('summary')) {
      // AI loading
      setState(() {
        _messages.add(Message(
            text: 'Generating your weekly summary💪!', type: MessageType.bot));
      });
      _scrollToBottom();

      if (!mounted) return;

      response = await _generateWeeklySummary(_controller.text.trim());
      setState(() {
        _messages
            .removeWhere((m) => m.text == 'Generating your weekly summary💪!');
      });
    } else {
      response =
          "I only generate weekly summaries. Try mentioning 'summary' in your prompt! 📝";
    }

    if (mounted) {
      _messages.add(Message(text: response, type: MessageType.bot));
      _scrollToBottom();
    }
  }

  Future<String> _generateWeeklySummary(String prompt) async {
    return GroqService().generateWeeklySummary(prompt);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Acitivy Summarizer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.type == MessageType.user;

                  if (isUser) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  } else {
                    // Bot message with avatar
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.smart_toy,
                              color: Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message for the summarizer...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
