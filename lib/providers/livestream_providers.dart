import 'package:prudapp/models/live_chat.dart';
import 'package:prudapp/sockets/livestream_socket_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final livestreamServiceProvider = Provider<LivestreamService>((ref) {
  final service = LivestreamService();
  ref.onDispose(() => service.dispose());
  return service;
});

final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final service = ref.watch(livestreamServiceProvider);
  final messages = <ChatMessage>[];
  
  return service.messageStream.map((message) {
    messages.add(message);
    // Keep only last 100 messages for performance
    if (messages.length > 100) {
      messages.removeRange(0, messages.length - 100);
    }
    return List.unmodifiable(messages);
  });
});

final streamStateProvider = StreamProvider<StreamState>((ref) {
  final service = ref.watch(livestreamServiceProvider);
  return service.streamStateStream;
});

final connectionStateProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(livestreamServiceProvider);
  return service.connectionStream;
});