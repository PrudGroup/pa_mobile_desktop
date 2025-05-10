import 'dart:isolate';

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:dio/dio.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/components/conditional_widget.dart';
import 'package:prudapp/components/point_divider.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/conditions/video_download.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/prudVid/tabs/views/video_detail.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class DownloadVideoComponent extends StatefulWidget {
  final DownloadedVideo details;
  final VidChannel? channel;
  final ChannelVideo? video;
  final Orientation screenOrientation;
  
  const DownloadVideoComponent({super.key, required this.details, this.channel, this.video, required this.screenOrientation,});

  @override
  DownloadVideoComponentState createState() => DownloadVideoComponentState();
}

class DownloadVideoComponentState extends State<DownloadVideoComponent> {
  final ValueNotifier<double> _valueNotifier = ValueNotifier(0);
  bool loading = false;
  bool downloading = false;
  bool saving = false;
  bool finishing = false;
  VidChannel? channel;
  ChannelVideo? video;
  bool channelIsLive = false;
  late DownloadedVideo details;
  String authorizedVidUrl = "";
  String authorizedImgUrl = "";
  Dio dio = Dio();
  final int eachChunkSize = 5 * 1024 * 1024;
  ReceivePort downloadPort = ReceivePort();
  List<int> downloadableChunckIndexes = [];
  double downloadPercentage = 0;
  ReceivePort imgPort = ReceivePort();
  ReceivePort vidPort = ReceivePort();
  ReceivePort chaPort = ReceivePort();
  ReceivePort mergePort = ReceivePort();
  Isolate? downloadIsolate;
  Isolate? imgIsolate;
  Isolate? vidIsolate;
  Isolate? chaIsolate;
  Isolate? mergeIsolate;
  Capability dwIsoCap = Capability();
  List<ConditionalWidgetItem> widgets = [];
  int fileSize = 0;
  bool showPause = true;
  int placeholderSize = 0;
  PrudCredential cred = PrudCredential(key: prudApiKey, token: iCloud.affAuthToken!);

  int getDownloadedSize(){
    int totalSize = 0;
    for (var u in details.mergedChunk) {
      totalSize += u.elementSizeInBytes;
    }
    return totalSize;
  }

  
  @override
  void initState(){
    if(mounted){
      setState(() {
        details = widget.details;
        widgets = getDownloadConditions(widget.screenOrientation);
         _valueNotifier.value = details.downloadedPercent;
        if(!details.downloadingComplete) {
          authorizedImgUrl = iCloud.authorizeDownloadUrl(details.placeholderUrl);
          authorizedVidUrl = iCloud.authorizeDownloadUrl(details.videoUrl);
        }
      });
    }
    Future.delayed(Duration.zero, () async {
      bool connected = await iCloud.checkNetwork();
      if(mounted) setState(() => loading = true);
      if(details.totalChunkSize <= 0 || details.chunkCount <= 0){
        Future.wait([getVideoFileSize(), getPlaceholderFileSize()]);
        if(mounted) {
          setState(() {
            details.totalChunkSize = fileSize;
            details.chunkCount = (fileSize / eachChunkSize).ceil();
            
          });
        }
      }
      if(mounted){
        setState(() {
          if(details.downloadingComplete == false && details.chucksRemaining.isNotEmpty){
            downloadableChunckIndexes = details.chucksRemaining;
          }else{
            downloadableChunckIndexes = [for (var i = 0; i < details.chunkCount; i++) i]; 
            details.chucksRemaining = downloadableChunckIndexes;
          }
          if(details.downloadingComplete == false){
            downloadPercentage = details.downloadedPercent;
          }
        });
      }
      if(
        details.downloadingComplete && 
        details.chucksRemaining.isEmpty && 
        details.chunkCount == details.mergedChunk.length &&
        details.placeholder != null
      ){
        Future.wait([if(details.finishedFile == null) mergeLocalVidData(), getChannel(), getVideo()]);
        if(mounted) setState(() => loading = false);
      }else{
        if(mounted) setState(() => loading = false);
        bool shouldDownload = false;
        if(details.chucksDownloaded.length != details.chunkCount || details.chucksRemaining.isNotEmpty || details.downloadingComplete == false){
          shouldDownload = true;
        }
        Future.wait([
          if(shouldDownload) downloadVideo(), 
          if(shouldDownload) downloadPlaceholder(),
          /* getChannel(), */ if(connected) getVideo(),
        ]);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    downloadPort.close();
    imgPort.close();
    vidPort.close();
    chaPort.close();
    mergePort.close();
    downloadIsolate?.kill(priority: Isolate.immediate);
    chaIsolate?.kill(priority: Isolate.immediate);
    mergeIsolate?.kill(priority: Isolate.immediate);
    vidIsolate?.kill(priority: Isolate.immediate);
    imgIsolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  Future<void> mergeLocalVidData() async {
    if(details.finishedFile == null && details.mergedChunk.isNotEmpty && details.chucksDownloaded.isEmpty){
      mergeIsolate = await Isolate.spawn(mergeBytesData, MergeBytesArg(
        actualBytes: details.mergedChunk,
        actualBytesIndexes: details.chucksDownloaded,
        arrangedIndex: [for (var i = 0; i < details.chunkCount; i++) i],
        port: mergePort.sendPort,
      ), onError: mergePort.sendPort, onExit: mergePort.sendPort);
      mergePort.listen((resp) {
        if(resp is Uint8List){
          if(mounted) {
            setState(() {
              details.finishedFile = resp;
              details.downloadingComplete = true;
              details.mergedChunk = [];
              details.chucksRemaining = [];
              downloading = false;
              showPause = false;
            });
          }
          Future.wait([prudVidNotifier.addToLocalVideoLibrary(details)]);
        }
      });
    }
  }


  Future<void> getVideoFileSize() async {
    int res = await tryAsync("getFileSize", () async {
      var response = await dio.head(authorizedVidUrl);
      return int.parse(response.headers.value('content-length') ?? '0');
    }, error: () {
      debugPrint("Error Occurred!");
      return 0;
    });
    if(mounted && res > 0) {
      setState((){
        fileSize = res;
        details.totalChunkSize = res;
      });
    }
  } 

  Future<void> getPlaceholderFileSize() async {
    int res =  await tryAsync("getFileSize", () async {
      var response = await dio.head(authorizedImgUrl);
      return int.parse(response.headers.value('content-length') ?? '0');
    }, error: () {
      debugPrint("Error Occurred!");
      return 0;
    });
    if(mounted && res > 0) {
      setState((){
        placeholderSize = res;
        details.placeholderSize = res;
      });
    }
  } 

  Future<void> getChannel() async {
    if(widget.video != null && widget.video!.channel == null){
      if(mounted) setState(() => channel = widget.video!.channel);
    }else{
      if(mounted) setState(() => loading = true);
      chaIsolate = await Isolate.spawn(
        getChannelFromCloud, 
        CommonArg(id: details.channelId, sendPort: chaPort.sendPort, cred: cred),
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

  Future<void> getVideo() async {
    if(widget.video != null) {
      if(mounted) setState(() => video = widget.video);
    } else {
      if(mounted) setState(() => loading = true);
      vidIsolate = await Isolate.spawn(
        getVideoFromCloud, 
        CommonArg(id: details.videoId, sendPort: vidPort.sendPort, cred: cred),
        onError: vidPort.sendPort, onExit: vidPort.sendPort
      );
      vidPort.listen((resp){
        if(mounted) {
          setState(() {
            video = resp != null? ChannelVideo.fromJson(resp) : null;
            loading = false;
          });
        }
      });
    }
  }

  Future<void> downloadPlaceholder() async {
    if(details.placeholder != null) return;
    imgIsolate = await Isolate.spawn(
      downloadSmallFileInBytes, 
      DownloadSmallFileArg(
        port: imgPort.sendPort,
        url: details.placeholderUrl,
        filename: tabData.getFilenameFromUrl(details.placeholderUrl),
        fileSize: details.placeholderSize,
      ), 
      onError: imgPort.sendPort, 
      onExit: imgPort.sendPort
    );
    imgPort.listen((resp){
      if(resp is Uint8List){
        if(mounted){
          setState((){
            details.placeholder = resp;
          });
        }
      }
    });
  }

  void togglePause(){
    tryOnly("togglePause", (){
      if(downloadIsolate != null){
        if(showPause){
          Capability cap = downloadIsolate!.pause();
          if(mounted) {
            setState((){
              dwIsoCap = cap;
              showPause = false;
            });
          }
        }else{
          downloadIsolate!.resume(dwIsoCap);
          if(mounted) setState(() => showPause = true);
        }
      }
    });
  }

  Future<void> downloadVideo() async {
    if(eachChunkSize == 0 || details.totalChunkSize == 0 || downloadableChunckIndexes.isEmpty) return;
    if(details.mergedChunk.isEmpty && mounted) setState(() => details.startedAt = DateTime.now());
    downloadIsolate = await Isolate.spawn(
      downloadChunks, 
      DownloadChunksArg(
        chunkIndexs: downloadableChunckIndexes, 
        port: downloadPort.sendPort, 
        url: details.videoUrl,
        filename: details.filename,
        eachChunkSize: eachChunkSize,
        fileSize: details.totalChunkSize
      ),
      onError: downloadPort.sendPort, onExit: downloadPort.sendPort
    );
    if(mounted) {
      setState(() {
        downloading = true;
        showPause = true;
      });
    }
    downloadPort.listen((resp){
      if(resp is DownloadChunkResponse) {
        if(mounted && resp.finished) {
          setState((){
            details.mergedChunk.add(resp.downloadedBytes);
            details.chucksDownloaded.add(resp.chunkIndex);
            details.chucksRemaining.removeWhere((ind) => ind == resp.chunkIndex);
            downloadPercentage = (details.chucksDownloaded.length * 100)/details.chunkCount;
            details.downloadedPercent = downloadPercentage;
            details.downloadedSize = getDownloadedSize();
          });
          Future.wait([prudVidNotifier.addToLocalVideoLibrary(details)]);
        }
        if(details.chucksRemaining.isEmpty && details.chucksDownloaded.length == details.chunkCount){
          if(mounted){
            setState((){
              details.ended = DateTime.now();
            });
            Future.wait([mergeLocalVidData()]);
          }
        }
      }
    });
  }

  void openLocalVideo(){
    if(details.finishedFile != null && details.placeholder != null){
      iCloud.goto(context, VideoDetail(
        video: video, channel: channel, localVid: details, isOwner: false, 
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: openLocalVideo,
          child: Container(
            margin: const EdgeInsets.all(5),
            constraints: BoxConstraints(
              minHeight: 100,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                spacing: 15,
                children: [
                  ConditionalWidget(
                    decisions: widgets,
                    condition: {
                      "downloading": downloading,
                      "imgDownloaded": details.placeholder != null,
                      "vidDownloaded": details.finishedFile != null,
                    },
                  ),
                  Expanded(
                    child: loading? Column(
                      children: [
                        FadeShimmer(
                          height: 7,
                          width: double.infinity,
                          radius: 10,
                          highlightColor: prudColorTheme.bgF,
                          baseColor: prudColorTheme.bgD,
                        ),
                        FadeShimmer(
                          height: 7,
                          width: double.infinity,
                          radius: 10,
                          highlightColor: prudColorTheme.bgF,
                          baseColor: prudColorTheme.bgD,
                        ),
                        FadeShimmer(
                          height: 7,
                          width: double.infinity,
                          radius: 10,
                          highlightColor: prudColorTheme.bgF,
                          baseColor: prudColorTheme.bgD,
                        ),
                      ],
                    ) : Column(
                      children: [
                        SizedBox(
                          child: Text(
                            details.videoTitle,
                            style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: prudColorTheme.bgA,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: [
                            Text(
                              details.channelName,
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                            ),
                            PointDivider(),
                            if(details.ended != null) Translate(
                              text: myStorage.ago(dDate: details.ended!, isShort: false),
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                              align: TextAlign.left,
                            ),
                            if(details.ended != null) PointDivider(),
                            if(video != null) Translate(
                              text: "${tabData.getFormattedNumber(video!.nonMemberViews + video!.memberViews)} Views",
                              style: prudWidgetStyle.hintStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.lineC,
                              ),
                              align: TextAlign.left,
                            ),
                          ],
                        ),
                        Text(
                          details.videoDuration,
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.lineC,
                          ),
                        ),
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
        ),
        if(!loading && (downloading || details.downloadingComplete == false)) Padding(
          padding: const EdgeInsets.only(top: 60, left: 60),
          child: InkWell(
            onTap: togglePause,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 60.0,
                maxWidth: 60.0
              ),
              child: DashedCircularProgressBar.aspectRatio(
                aspectRatio: 1, // width ÷ height
                valueNotifier: _valueNotifier,
                progress: downloadPercentage,
                sweepAngle: 270,
                backgroundColor: prudColorTheme.lineC,
                foregroundStrokeWidth: 4,
                backgroundStrokeWidth: 4,
                animation: true,
                seekSize: 6,
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: _valueNotifier,
                    builder: (_, double value, __) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showPause? Icons.pause : Icons.stop, 
                          color: Colors.blue, size: 30,
                        ),
                        Text(
                          '${value.toInt()}%',
                          style: TextStyle(
                            color: prudColorTheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 25
                          ),
                        ),
                      ],
                    )
                  ),
                ),
              ),
            )
          ),
        )
      ],
    );
  }
}