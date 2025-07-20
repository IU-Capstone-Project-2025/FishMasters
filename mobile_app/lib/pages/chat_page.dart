import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/l10n/app_localizations.dart';
import 'package:mobile_app/models/models.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.discussionId});

  final int discussionId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late List<MessageModel> _discussion;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (!Hive.isBoxOpen('settings')) {
      debugPrint('Settings box is not open');
      return;
    }
    final box = Hive.box('settings');
    final email = box.get('email');
    final response = await http.post(
      Uri.parse(
        'https://capstone.aquaf1na.fun/api/discussion/messages/createMessage',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        CreateMessageRequestModel(
          discussionId: widget.discussionId,
          content: text,
          fisherEmail: email,
        ).toJson(),
      ),
    );

    if (response.statusCode == 200) {
      final message = MessageModel.fromJson(json.decode(response.body));
      setState(() {
        _discussion.insert(0, message);
        _controller.clear();
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      debugPrint('Failed to send message: ${response.statusCode}');
    }
  }

  void _fetchMessages() async {
    _discussion = await http
        .get(
          Uri.parse(
            'https://capstone.aquaf1na.fun/api/discussion/messages/${widget.discussionId}',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            debugPrint('Discussion data: $jsonData');
            return (jsonData as List)
                .map((item) => MessageModel.fromJson(item))
                .toList()
                .reversed
                .toList();
          } else {
            throw Exception(
              'Failed to load discussion: ${response.statusCode}, ${response.body}',
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(localizations!.chatText)),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: Future.microtask(_fetchMessages),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  debugPrint('Error: ${snapshot.error}');
                  return Center(child: Text('Failed to load messages'));
                } else if (_discussion.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                } else {
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    itemCount: _discussion.length,
                    itemBuilder: (context, index) {
                      final message = _discussion[index];
                      final isMe =
                          message.fisherEmail ==
                          Hive.box('settings').get('email');
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorScheme.primaryContainer
                                : colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMe
                                  ? const Radius.circular(16)
                                  : const Radius.circular(0),
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: isMe
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSecondaryContainer,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: localizations.messagePlaceholder,
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
