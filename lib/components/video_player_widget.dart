import 'dart:async';
import 'dart:isolate';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/components/channel_logo.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/utils.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoThriller video;
  final VidChannel? channel;
  final String title;
  final String channelId;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final List<String>? tags;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.title,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    required this.channelId,
    this.tags,
    this.channel,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isPlaying = false;
  bool _showControls = true;
  VidChannel? channel;
  bool loading = false;
  ReceivePort chaPort = ReceivePort();
  Isolate? chaIsolate;
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );
  bool channelIsLive = false;

  Future<void> getChannel() async {
    if(widget.channel != null){
      if(mounted) setState(() => channel = widget.channel);
    }else{
      if(mounted) setState(() => loading = true);
      chaIsolate = await Isolate.spawn(
        getChannelFromCloud, 
        CommonArg(id: widget.channelId, sendPort: chaPort.sendPort, cred: cred),
        onError: chaPort.sendPort, onExit: chaPort.sendPort
      );
      chaPort.listen((resp){
        if(mounted) {
          setState(() {
            channel = resp != null? VidChannel.fromJson(resp) : null;
            channelIsLive = channel?.presentlyLive?? false;
            loading = false;
          });
        }
      });
    }
  }


  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.video.videoUrl,
    );
    
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        autoPlay: true,
        looping: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
          enableFullscreen: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
    
    _betterPlayerController?.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        setState(() {
          _isPlaying = true;
        });
      } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _betterPlayerController?.pause();
    } else {
      _betterPlayerController?.play();
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video player
          if (_betterPlayerController != null)
            Positioned.fill(
              child: BetterPlayer(
                controller: _betterPlayerController!,
              ),
            ),
          
          // Tap to play/pause
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _togglePlayPause();
                setState(() {
                  _showControls = !_showControls;
                });
                
                // Hide controls after 3 seconds
                Timer(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showControls = false;
                    });
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                child: _showControls && !_isPlaying
                    ? Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 80,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          
          // Right side actions
          Positioned(
            right: 12,
            bottom: 80,
            child: Column(
              children: [
                // Like button
                GestureDetector(
                  onTap: widget.onLike,
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatNumber(widget.video.likes),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Dislike button
                GestureDetector(
                  onTap: widget.onDislike,
                  child: Column(
                    children: [
                      Icon(
                        Icons.thumb_down,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatNumber(widget.video.dislikes),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Comment button
                GestureDetector(
                  onTap: widget.onComment,
                  child: Column(
                    children: [
                      Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 35,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatNumber(widget.video.commentCount!),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Share button
                GestureDetector(
                  onTap: () {
                    // Implement share functionality
                    HapticFeedback.lightImpact();
                  },
                  child: Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom info
          Positioned(
            left: 12,
            right: 80,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Views count
                Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${_formatNumber(widget.video.impressions)} views',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Author
                Row(
                  children: [
                    if(channel != null) ChannelLogo(
                      channel: channel!, isLive: channelIsLive,
                      context: context, isOwner: false,
                    ),
                    spacer.width,
                    Column(
                      children: [
                        Wrap(
                          children: [
                            Text(
                              widget.title,
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            Text(
                              '@${channel?.channelName}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            PointDivider(),
                            Text(
                              convertTagsToString(widget.tags?? []),
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.iconC,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            
                          ],
                        ),
                      ]
                    )

                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }
}