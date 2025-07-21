import 'package:flutter_webrtc/flutter_webrtc.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String username;
  final String message;
  final DateTime timestamp;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
    };
  }
}

enum MessageType { text, image, video, system }

class StreamState {
  final bool isStreaming;
  final bool isConnected;
  final List<String> viewers;
  final Map<String, RTCVideoRenderer> remoteRenderers;
  final RTCVideoRenderer? localRenderer;
  final String? error;

  StreamState({
    required this.isStreaming,
    required this.isConnected,
    required this.viewers,
    required this.remoteRenderers,
    this.localRenderer,
    this.error,
  });

  StreamState copyWith({
    bool? isStreaming,
    bool? isConnected,
    List<String>? viewers,
    Map<String, RTCVideoRenderer>? remoteRenderers,
    RTCVideoRenderer? localRenderer,
    String? error,
  }) {
    return StreamState(
      isStreaming: isStreaming ?? this.isStreaming,
      isConnected: isConnected ?? this.isConnected,
      viewers: viewers ?? this.viewers,
      remoteRenderers: remoteRenderers ?? this.remoteRenderers,
      localRenderer: localRenderer ?? this.localRenderer,
      error: error,
    );
  }
}