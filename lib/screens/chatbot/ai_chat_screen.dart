import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/user_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/chat_provider.dart';
import '../../utils/theme.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final cycleProvider = context.watch<CycleProvider>();
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () => chatProvider.clearMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Questions
          if (chatProvider.messages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Questions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chatProvider.getQuickQuestions(userProvider.currentMode).map((q) {
                      return ActionChip(
                        label: Text(q, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppTheme.primaryPink.withOpacity(0.1),
                        onPressed: () => _sendMessage(q, userProvider, cycleProvider, chatProvider),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatProvider.messages.length && chatProvider.isLoading) {
                  return _buildLoadingBubble();
                }
                final message = chatProvider.messages[index];
                return _buildMessageBubble(message.content, message.isUser);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (text) => _sendMessage(text, userProvider, cycleProvider, chatProvider),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Iconsax.send_1, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text, userProvider, cycleProvider, chatProvider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text, UserProvider userProvider, CycleProvider cycleProvider, ChatProvider chatProvider) {
    if (text.trim().isEmpty) return;
    
    chatProvider.addUserMessage(text);
    _controller.clear();
    
    chatProvider.generateAIResponse(
      text,
      mode: userProvider.currentMode,
      cycleDay: cycleProvider.currentCycleDay,
      fertilityScore: cycleProvider.todaysFertilityScore,
      pregnancyWeek: userProvider.user?.currentPregnancyWeek,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          gradient: isUser ? AppTheme.primaryGradient : null,
          color: isUser ? null : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black87)),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPink)),
            const SizedBox(width: 12),
            const Text('Thinking...'),
          ],
        ),
      ),
    );
  }
}
