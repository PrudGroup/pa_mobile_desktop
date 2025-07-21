import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/providers/livestream_providers.dart';
import 'package:prudapp/screens/livestream_chat_screen.dart';
import 'package:prudapp/screens/livestream_video_screen.dart';

class LiveStreamPage extends ConsumerWidget {
  const LiveStreamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamState = ref.watch(streamStateProvider);
    // final connectionState = ref.watch(connectionStateProvider);
    final chatMessages = ref.watch(chatMessagesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        actions: [
          StreamBuilder<bool>(
            stream: ref.read(livestreamServiceProvider).connectionStream,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;
              return Icon(
                isConnected ? Icons.wifi : Icons.wifi_off,
                color: isConnected ? Colors.green : Colors.red,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video section
          Expanded(
            flex: 3,
            child: streamState.when(
              data: (state) => VideoSection(state: state),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
          // Chat section
          Expanded(
            flex: 2,
            child: chatMessages.when(
              data: (messages) => ChatSection(messages: messages),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

