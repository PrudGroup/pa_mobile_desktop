import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:prudapp/models/live_chat.dart';
import 'package:prudapp/providers/livestream_providers.dart';

class VideoSection extends ConsumerWidget {
  final StreamState state;
  
  const VideoSection({required this.state, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(livestreamServiceProvider);
    
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Main video
          if (state.localRenderer != null)
            RTCVideoView(state.localRenderer!)
          else
            const Center(
              child: Text('No video', style: TextStyle(color: Colors.white)),
            ),
          
          // Remote videos (picture-in-picture)
          ...state.remoteRenderers.entries.map((entry) {
            return Positioned(
              top: 20,
              right: 20,
              width: 120,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RTCVideoView(entry.value),
                ),
              ),
            );
          }),
          
          // Controls
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: state.isStreaming 
                    ? () => service.stopStreaming()
                    : () => service.startStreaming(),
                  backgroundColor: state.isStreaming ? Colors.red : Colors.green,
                  child: Icon(state.isStreaming ? Icons.stop : Icons.play_arrow),
                ),
                Text(
                  '${state.viewers.length} viewers',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Error overlay
          if (state.error != null)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}