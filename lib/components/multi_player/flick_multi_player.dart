import 'package:prudapp/components/multi_player/portrait_controls.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';

import './flick_multi_manager.dart';
import 'package:flick_video_player/flick_video_player.dart';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:video_player/video_player.dart';

class FlickMultiPlayer extends StatefulWidget {

  final String url;
  final String? image;
  final FlickMultiManager flickMultiManager;
  final bool watched;
  final String thrillerId;

  const FlickMultiPlayer({
    super.key, required this.url, required this.thrillerId,
    required this.flickMultiManager, this.image,
    this.watched = false
  });


  @override
  FlickMultiPlayerState createState() => FlickMultiPlayerState();
}

class FlickMultiPlayerState extends State<FlickMultiPlayer> {
  late FlickManager flickManager;

  @override
  void initState() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(widget.url))/* ..setLooping(true) */,
      autoPlay: false,
      onVideoEnd: () => prudStudioNotifier.addToWatchedThrillers(widget.thrillerId),
    );
    widget.flickMultiManager.init(flickManager);
    if(widget.watched) {
      widget.flickMultiManager.pause();
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.flickMultiManager.remove(flickManager);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visiblityInfo) {
        if (visiblityInfo.visibleFraction > 0.9) {
          widget.flickMultiManager.play(flickManager);
        }
      },
      // ignore: avoid_unnecessary_containers
      child: Container(
        child: FlickVideoPlayer(
          flickManager: flickManager,
          flickVideoWithControls: FlickVideoWithControls(
            playerLoadingFallback: Positioned.fill(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: PrudNetworkImage(url: widget.image, authorizeUrl: true,),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        backgroundColor: prudColorTheme.lineC,
                        strokeWidth: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            controls: FeedPlayerPortraitControls(
              flickMultiManager: widget.flickMultiManager,
              flickManager: flickManager,
            ),
          ),
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            playerLoadingFallback: Center(
              child: PrudNetworkImage(
                url: widget.image, 
                authorizeUrl: true,
                fit: BoxFit.fitWidth,
              ),
            ),
            controls: FlickLandscapeControls(),
            iconThemeData: IconThemeData(
              size: 40,
              color: Colors.white,
            ),
            textStyle: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
