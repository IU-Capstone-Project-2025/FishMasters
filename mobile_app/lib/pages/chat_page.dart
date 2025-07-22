import 'dart:async';
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
  late List<MessageModel> _discussion = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  bool _isSending = false;
  bool _isInitialLoad = true;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    if (!Hive.isBoxOpen('settings')) {
      debugPrint('Settings box is not open');
      setState(() {
        _isSending = false;
      });
      return;
    }
    final box = Hive.box('settings');
    final email = box.get('email');

    // Clear the text field immediately for better UX
    final messageText = text;
    _controller.clear();

    final response = await http.post(
      Uri.parse(
        'https://capstone.aquaf1na.fun/api/discussion/messages/createMessage',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        CreateMessageRequestModel(
          discussionId: widget.discussionId,
          content: messageText,
          fisherEmail: email,
        ).toJson(),
      ),
    );

    if (response.statusCode == 200) {
      // Refresh messages smoothly
      await _fetchMessages();
      if (mounted) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else {
      debugPrint('Failed to send message: ${response.statusCode}');
      // Restore the text if sending failed
      if (mounted) {
        _controller.text = messageText;
      }
    }

    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://capstone.aquaf1na.fun/api/discussion/messages/${widget.discussionId}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('Discussion data: $jsonData');
        final newMessages = (jsonData as List)
            .map((item) => MessageModel.fromJson(item))
            .toList()
            .reversed
            .toList();

        // Check if widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _discussion = newMessages;
          });
        }
      } else {
        throw Exception(
          'Failed to load discussion: ${response.statusCode}, ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMessages().then((_) {
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
      }
    });
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isSending && !_isInitialLoad) {
        debugPrint('Auto-refreshing messages...');
        _fetchMessages();
      }
    });
  }

  Widget _buildMessageList(ColorScheme colorScheme) {
    if (_discussion.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noMessages));
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: _discussion.length,
      itemBuilder: (context, index) {
        final message = _discussion[index];
        final isMe = message.fisherEmail == Hive.box('settings').get('email');
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe
                // TODO: Choose proper colors
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primaryContainer,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var localizations = AppLocalizations.of(context);
    var colorScheme = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: colorScheme.secondary,
        automaticallyImplyLeading: true,
        title: Text(
          localizations!.chatText,
          style: textTheme.displayMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isInitialLoad
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(colorScheme),
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
                      enabled: !_isSending,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: localizations.messagePlaceholder,
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      style: textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    onPressed: _isSending ? null : _sendMessage,
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
