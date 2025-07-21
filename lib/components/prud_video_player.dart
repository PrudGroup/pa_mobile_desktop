import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/components/video_loading.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prudio_client.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class PrudVideoPlayer extends StatefulWidget {
  final dynamic vid;
  final BetterPlayerDataSourceType vidSource;
  final bool isPortrait;
  final bool isLive;
  final Duration? startAt;
  final bool loop;
  final dynamic thumbnail;
  final String? channelName;
  final String? vidTitle;
  final int startPlaylistAt;
  final Widget? finishedWidget;
  final List<BetterPlayerSubtitlesSource>? subtitles;

  const PrudVideoPlayer({
    super.key, 
    required this.vid, 
    required this.thumbnail,
    this.vidSource = BetterPlayerDataSourceType.network, 
    this.isPortrait = true,
    this.isLive = false,
    this.loop = false,
    this.startAt, this.channelName, this.vidTitle,
    this.startPlaylistAt = 0,
    this.subtitles,
    this.finishedWidget,
  });

  @override
  PrudVideoPlayerState createState() => PrudVideoPlayerState();
}

class PrudVideoPlayerState extends State<PrudVideoPlayer> {
  late BetterPlayerController _bpCtrl;
  late BetterPlayerDataSource _bpSource;
  GlobalKey bpKey = GlobalKey();
  bool finished = false;
  Duration? lastPosition;
  // bool deviceCanPip = false;


  void addWatchMinutesOrLastDuration(){
    Future.delayed(Duration.zero, () async {
      Duration? current = await _bpCtrl.videoPlayerController?.position;
      if(current != null && lastPosition != null){
        int minutesWatched = current.inMinutes - lastPosition!.inMinutes;
        if(minutesWatched >= 1 && prudSocket.connected){
          prudSocket.emit("increment_video_watch_minutes", {"minutes": minutesWatched});
        }
        if(mounted) setState(() => lastPosition = current);
      }

    });
  }
  

  @override
  void initState(){
    /* Future.delayed(Duration.zero, () async {
      if(mounted){
        bool canPip = await _bpCtrl.isPictureInPictureSupported();
        setState(()  => deviceCanPip = canPip);
      }
    }); */
    String authorizedThumbnail = iCloud.authorizeDownloadUrl(widget.thumbnail);
    BetterPlayerConfiguration bpConfig = BetterPlayerConfiguration(
      fit: BoxFit.fill,
      translations: [
        BetterPlayerTranslations.spanish(),
        BetterPlayerTranslations.polish(),
        BetterPlayerTranslations.arabic(),
        BetterPlayerTranslations.chinese(),
        BetterPlayerTranslations.hindi(),
        BetterPlayerTranslations.turkish(),
        BetterPlayerTranslations.vietnamese()
      ],
      subtitlesConfiguration: BetterPlayerSubtitlesConfiguration(
        fontColor: prudColorTheme.bgD
      ),
      controlsConfiguration: BetterPlayerControlsConfiguration(
        pauseIcon: Icons.pause_sharp,
        playIcon: Icons.play_arrow_sharp,
        muteIcon: Icons.volume_mute_sharp,
        unMuteIcon: Icons.volume_up_sharp,
        fullscreenEnableIcon: Icons.fullscreen_sharp,
        fullscreenDisableIcon: Icons.fullscreen_exit_sharp,
        skipBackIcon: Icons.replay_10_sharp,
        skipForwardIcon: Icons.forward_10_sharp,
        overflowMenuIcon: Icons.more_vert_sharp,
        pipMenuIcon: Icons.picture_in_picture_sharp,
        playbackSpeedIcon: Icons.shutter_speed_sharp,
        qualitiesIcon: Icons.hd_sharp,
        subtitlesIcon: Icons.closed_caption_sharp,
        audioTracksIcon: Icons.audiotrack_sharp,
        loadingWidget:  VideoLoading(),
        controlsHideTime: const Duration(seconds: 10),
        progressBarPlayedColor: prudColorTheme.primary,
        progressBarHandleColor: prudColorTheme.primary,
        progressBarBackgroundColor: prudColorTheme.bgA,
        progressBarBufferedColor: prudColorTheme.bgD
      ),
      eventListener: (BetterPlayerEvent event){
        switch(event.betterPlayerEventType){
          case BetterPlayerEventType.finished: {
            if(mounted) setState(() => finished = true);
            Future.delayed(Duration(seconds: 10), (){
              if(mounted) setState(() => finished = false);
            });
          }
          case BetterPlayerEventType.progress: {
            addWatchMinutesOrLastDuration();
          }
          case BetterPlayerEventType.bufferingUpdate:{
            addWatchMinutesOrLastDuration();
          }
          case BetterPlayerEventType.exception: {

          }
          default: {}
        }
      },
      autoDetectFullscreenAspectRatio: true,
      autoDetectFullscreenDeviceOrientation: true,
      errorBuilder: (context, err){
        return Center(
          child: tabData.getNotFoundWidget(
            title: "Oops!", 
            desc: "$err",
            isRow: true
          )
        );
      },
      autoPlay: true,
      looping: widget.loop,
      placeholder: PrudNetworkImage(url: widget.thumbnail, authorizeUrl: true,),
      showPlaceholderUntilPlay: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
    );
    _bpSource = BetterPlayerDataSource(
      widget.vidSource,
      widget.vidSource == BetterPlayerDataSourceType.network? iCloud.authorizeDownloadUrl(widget.vid) : "",
      liveStream: widget.isLive,
      bytes: widget.vidSource == BetterPlayerDataSourceType.network? null : widget.vid.toList(),
      subtitles: widget.subtitles,
      placeholder:  widget.vidSource == BetterPlayerDataSourceType.network? PrudNetworkImage(url: widget.thumbnail, authorizeUrl: true,) : Image.memory(widget.thumbnail, fit: BoxFit.cover,),
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheFileSize: 10*1024*1024*1024,
        maxCacheSize: 10*1024*1024*1024,
        preCacheSize: 1*1024*1024,
      ),
      bufferingConfiguration: BetterPlayerBufferingConfiguration(
        minBufferMs: 50000,
        maxBufferMs: 13107200,
        bufferForPlaybackMs: 2500,
        bufferForPlaybackAfterRebufferMs: 5000,
      ),
      drmConfiguration: BetterPlayerDrmConfiguration(

      ),
      notificationConfiguration: BetterPlayerNotificationConfiguration(
        showNotification: true,
        imageUrl: widget.vidSource == BetterPlayerDataSourceType.network? authorizedThumbnail : "",
        author: widget.channelName,
        title: widget.vidTitle,
        notificationChannelName: "PrudVid",
      ),
    );
    _bpCtrl = BetterPlayerController(
      bpConfig, 
      betterPlayerPlaylistConfiguration: BetterPlayerPlaylistConfiguration(
        initialStartIndex: widget.startPlaylistAt
      ),
    );
    _bpCtrl.setupDataSource(_bpSource);
    super.initState();
    prudSocket.on("", (dynamic resp){});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _bpCtrl, key: bpKey,),
        ),
        if(widget.finishedWidget != null && finished) widget.finishedWidget!,
      ],
    );
  }
}