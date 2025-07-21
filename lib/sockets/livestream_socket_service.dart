
import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prudapp/models/live_chat.dart';
import 'package:prudapp/singletons/i_cloud.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LivestreamService {
  static const String _serverUrl = '"$apiEndPoint/live_io"';
  IO.Socket? _socket;
  final StreamController<ChatMessage> _messageController = StreamController.broadcast();
  final StreamController<StreamState> _streamController = StreamController.broadcast();
  final StreamController<bool> _connectionController = StreamController.broadcast();
  
  // WebRTC
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  RTCVideoRenderer? _localRenderer;
  
  // Performance optimization
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 2);

  // Getters
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<StreamState> get streamStateStream => _streamController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _socket?.connected ?? false;

  // Initialize WebRTC
  Future<void> _initializeWebRTC() async {
    try {
      _localRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();

      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
      };

      _peerConnection = await createPeerConnection(configuration);
      _setupPeerConnectionListeners();
      
    } catch (e) {
      _emitStreamState(error: 'WebRTC initialization failed: $e');
    }
  }

  void _setupPeerConnectionListeners() {
    _peerConnection?.onIceCandidate = (candidate) {
      _socket?.emit('ice-candidate', {
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection?.onAddStream = (stream) {
      final renderer = RTCVideoRenderer();
      renderer.initialize().then((_) {
        renderer.srcObject = stream;
        _remoteRenderers[stream.id] = renderer;
        _emitStreamState();
      });
    };

    _peerConnection?.onRemoveStream = (stream) {
      _remoteRenderers[stream.id]?.dispose();
      _remoteRenderers.remove(stream.id);
      _emitStreamState();
    };

    _peerConnection?.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _emitStreamState(error: 'WebRTC connection failed');
      }
    };
  }

  // Connect to Socket.IO server
  Future<void> connect({required String userId, required String username}) async {
    try {
      await _initializeWebRTC();
      
      _socket = IO.io(_serverUrl, 
        IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId, 'username': username})
          .setAckTimeout(3000)
          .setReconnectionAttempts(3)
          .setReconnectionDelay(2000)
          .setRememberUpgrade(true)
          .setAuth({"AppCredential": prudApiKey,})
          .disableAutoConnect()
          .setExtraHeaders({"AppCredential": prudApiKey,})
          .setTimeout(5000)
          .build()
      );

      _setupSocketListeners();
      _socket!.connect();
      _startHeartbeat();
      
    } catch (e) {
      _emitStreamState(error: 'Connection failed: $e');
    }
  }

  void _setupSocketListeners() {
    _socket?.on('connect', (_) {
      _connectionController.add(true);
      _reconnectAttempts = 0;
      _emitStreamState();
    });

    _socket?.on('disconnect', (_) {
      _connectionController.add(false);
      _scheduleReconnect();
      _emitStreamState();
    });

    _socket?.on('connect_error', (error) {
      _emitStreamState(error: 'Connection error: $error');
      _scheduleReconnect();
    });

    _socket?.on('message', (data) {
      try {
        final message = ChatMessage.fromJson(data);
        _messageController.add(message);
      } catch (e) {
        Logger().e('Error parsing message: $e');
      }
    });

    _socket?.on('user-joined', (data) {
      _emitStreamState(viewers: List<String>.from(data['viewers'] ?? []));
    });

    _socket?.on('user-left', (data) {
      _emitStreamState(viewers: List<String>.from(data['viewers'] ?? []));
    });

    _socket?.on('offer', (data) async {
      await _handleOffer(data);
    });

    _socket?.on('answer', (data) async {
      await _handleAnswer(data);
    });

    _socket?.on('ice-candidate', (data) async {
      await _handleIceCandidate(data);
    });

    _socket?.on('stream-started', (data) {
      _emitStreamState(isStreaming: true);
    });

    _socket?.on('stream-ended', (data) {
      _emitStreamState(isStreaming: false);
    });
  }

  // WebRTC handlers
  Future<void> _handleOffer(Map<String, dynamic> data) async {
    try {
      final offer = RTCSessionDescription(data['sdp'], data['type']);
      await _peerConnection?.setRemoteDescription(offer);
      
      final answer = await _peerConnection?.createAnswer();
      await _peerConnection?.setLocalDescription(answer!);
      
      _socket?.emit('answer', {
        'sdp': answer!.sdp,
        'type': answer.type,
      });
    } catch (e) {
      _emitStreamState(error: 'Error handling offer: $e');
    }
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    try {
      final answer = RTCSessionDescription(data['sdp'], data['type']);
      await _peerConnection?.setRemoteDescription(answer);
    } catch (e) {
      _emitStreamState(error: 'Error handling answer: $e');
    }
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> data) async {
    try {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      await _peerConnection?.addCandidate(candidate);
    } catch (e) {
      _emitStreamState(error: 'Error handling ICE candidate: $e');
    }
  }

  // Start video streaming
  Future<void> startStreaming() async {
    try {
      // Request permissions
      await Permission.camera.request();
      await Permission.microphone.request();

      // Get user media
      final mediaConstraints = {
        'audio': true,
        'video': {
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        }
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer?.srcObject = _localStream;

      // Add stream to peer connection
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });

      // Create offer
      final offer = await _peerConnection?.createOffer();
      await _peerConnection?.setLocalDescription(offer!);

      // Send offer to server
      _socket?.emit('start-stream', {
        'sdp': offer!.sdp,
        'type': offer.type,
      });

      _emitStreamState(isStreaming: true);
    } catch (e) {
      _emitStreamState(error: 'Failed to start streaming: $e');
    }
  }

  // Stop video streaming
  Future<void> stopStreaming() async {
    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      _localStream?.dispose();
      _localStream = null;

      await _peerConnection?.close();
      _peerConnection = null;

      _socket?.emit('stop-stream');
      _emitStreamState(isStreaming: false);
      
      // Reinitialize for next stream
      await _initializeWebRTC();
    } catch (e) {
      _emitStreamState(error: 'Error stopping stream: $e');
    }
  }

  // Send chat message
  void sendMessage(String message) {
    if (_socket?.connected == true && message.trim().isNotEmpty) {
      _socket?.emit('message', {
        'message': message.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Join room
  void joinRoom(String roomId) {
    _socket?.emit('join-room', {'roomId': roomId});
  }

  // Leave room
  void leaveRoom(String roomId) {
    _socket?.emit('leave-room', {'roomId': roomId});
  }

  // Heartbeat for connection monitoring
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_socket?.connected == true) {
        _socket?.emit('ping');
      }
    });
  }

  // Reconnection logic
  void _scheduleReconnect() {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(_reconnectDelay, () {
        _reconnectAttempts++;
        _socket?.connect();
      });
    }
  }

  // Emit stream state
  void _emitStreamState({
    bool? isStreaming,
    bool? isConnected,
    List<String>? viewers,
    String? error,
  }) {
    final state = StreamState(
      isStreaming: isStreaming ?? false,
      isConnected: isConnected ?? this.isConnected,
      viewers: viewers ?? [],
      remoteRenderers: Map.from(_remoteRenderers),
      localRenderer: _localRenderer,
      error: error,
    );
    _streamController.add(state);
  }

  // Dispose resources
  void dispose() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _socket?.dispose();
    _messageController.close();
    _streamController.close();
    _connectionController.close();
    
    // Dispose WebRTC resources
    _localStream?.dispose();
    _localRenderer?.dispose();
    for (var renderer in _remoteRenderers.values) {
      renderer.dispose();
    }
    _remoteRenderers.clear();
    _peerConnection?.dispose();
  }
}