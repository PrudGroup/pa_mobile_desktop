import 'dart:io';
import 'dart:isolate';

import 'package:buffer/buffer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/backblaze_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:video_player/video_player.dart';

class PrudVideoPicker extends StatefulWidget {
  final Function(SaveVideoResponse) onProgressChanged;
  final Function(String)? onSaveToCloud;
  final Function(PrudVidDuration) onDurationGotten;
  final Function(dynamic)? onError;
  final String destination;
  final bool saveToCloud;
  final bool isShort;
  final bool alreadyUploaded;
  final Function(String)? onVideoPicked;
  final bool hasPartialUpload;
  final String? uploadedFilePath;
  final SaveVideoResponse? savedProgress;

  const PrudVideoPicker({
    super.key, 
    required this.onProgressChanged, 
    required this.destination, 
    required this.onDurationGotten,
    this.isShort = false,
    this.saveToCloud = true,
    this.onSaveToCloud, 
    this.onError,
    this.onVideoPicked,
    this.alreadyUploaded = false,
    this.hasPartialUpload = false,
    this.uploadedFilePath,
    this.savedProgress,
  });

  @override
  PrudVideoPickerState createState() => PrudVideoPickerState();
}

class PrudVideoPickerState extends State<PrudVideoPicker> {
  bool picking = false;
  Uint8List? video;
  int uploadProgress = 0;
  bool allPartsAreSaved = false;
  bool finishing = false;
  final receivePort = ReceivePort();
  bool showProgress = false;
  bool saving = false;
  int durationLimitInMinutes = 300;
  List<String> uploadSha1s = [];
  bool alreadyUploaded = false;
  String filename = "prud.mp4";

  int getChunkSize(int fileSize) => 5 * 1024 * 1024;

  Future<void> continueUpload() async {
    if(widget.uploadedFilePath != null && widget.savedProgress != null){
      await tryAsync("continueUpload", () async {
        if(mounted){
          setState(() {
            uploadProgress = widget.savedProgress!.percentageUploaded;
            showProgress = true;
            saving = true;
          });
        }
        final file = File(widget.uploadedFilePath!);
        if(await file.exists()){
          PlatformFile fileP = PlatformFile(
            path: file.path, name: widget.savedProgress!.startedLargeFile.fileName, 
            size: file.lengthSync()
          );
          Stream<List<int>>?  fileReadStream = fileP.readStream;
          if (fileReadStream != null) {
            if(mounted) setState(() => filename = tabData.removeSpace(fileP.name));
            StartLargeFileResponse? res = widget.savedProgress?.startedLargeFile;
            if(res != null) { 
              int countPart = 0; 
              int chunkSize = getChunkSize(fileP.size);
              Stream<Uint8List> chunkedStream = sliceStream(fileReadStream, chunkSize).asBroadcastStream();          
              if(await chunkedStream.length == widget.savedProgress!.totalChunkCount){
                await for(Uint8List part in chunkedStream){
                  countPart += 1;
                  if(widget.savedProgress!.remainingChunks.contains(countPart)){
                    String sha1 = "${backblazeNotifier.generateSha1(part)}";
                    uploadSha1s.add(sha1);
                    UploadVideoServiceArg arg = UploadVideoServiceArg(
                      fileId: res.fileId,
                      part: countPart,
                      partVideo: part,
                      sendPort: receivePort.sendPort,
                      cred: B2Credential(
                        b2DownloadToken: b2DownloadToken!, 
                        b2AccToken: b2AccToken!, 
                        b2AuthKey: b2AuthKey!, 
                        b2ApiUrl: b2ApiUrl!
                      ),
                      sha1: sha1
                    );
                    await Isolate.spawn(uploadVideoService, arg, onError: receivePort.sendPort, onExit: receivePort.sendPort);
                  }
                }
                await save(
                  res, countPart, 
                  uploadChunkCount: widget.savedProgress!.uploadedChunkCount,
                  percentageUploaded: widget.savedProgress!.percentageUploaded,
                  uploadedParts: widget.savedProgress!.uploadedParts,
                  remainingChunks: widget.savedProgress!.remainingChunks,
                );
              }else{
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Translate(text: "Unable assert chunks."),
                  ));
                  setState(() => saving = false);
                }
              }
            }else{
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Translate(text: "Unable To Save Video"),
                ));
                setState(() => saving = false);
              }
            }
          }else{
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Translate(text: "Failed to read file"),
              ));
              setState(() => picking = false);
            }
          }
        }else{
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Translate(text: "File no longer Exist."),
            ));
            setState(() => saving = false);
            if(widget.onError != null) widget.onError!("The Video has been deleted");
          }
        }
      }, error: (){
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Translate(text: "Unable To Continue Saving Video"),
          ));
          setState(() => saving = false);
          if(widget.onError != null) widget.onError!("Unknown Error.");
        }
      });
    }
  }
  
  Future<void> finishUp(String fileId) async {
    if(mounted) {
      setState(() {
        saving = false;
        finishing = true;
      });
    }
    LargeFileFinishedResponse? res;
    int tryTimes = 0;
    while(res == null && tryTimes < 5){
      tryTimes++;
      res = await backblazeNotifier.finishLargeFileUpload(fileId, uploadSha1s);
      res ??= await backblazeNotifier.checkIfFileUploaded(fileId);
    }
    if(res != null){
      String? downloadUrl = await iCloud.getFileDownloadUrl(res.fileName);
      if(downloadUrl != null){
        debugPrint("download_url: $downloadUrl");
        widget.onSaveToCloud?.call(downloadUrl);
        if(mounted) setState(() => alreadyUploaded = true);
      }else{
        widget.onError?.call('Failed to get downloadUrl');
      }
    }else{
      widget.onError?.call('Failed to finish upload');
    }
    if(mounted) setState(() => finishing = false);
  }

  Future<void> save(StartLargeFileResponse startedFile, int chunkCount, {
    int uploadChunkCount = 0,
    int percentageUploaded = 0,
    List<UploadPartResponse>? uploadedParts,
    List<int>? remainingChunks,
  }) async {
    SaveVideoResponse progress = SaveVideoResponse(
      totalChunkCount: chunkCount,
      uploadedChunkCount: uploadChunkCount,
      percentageUploaded: percentageUploaded,
      startedLargeFile: startedFile,
      uploadedParts: uploadedParts?? [],
      remainingChunks: remainingChunks?? []
    ); 
    debugPrint("All chunks: $chunkCount");
    receivePort.listen((resp) async {
      if(resp != null){
        UploadPartResponse partRes = UploadPartResponse.fromJson(resp);
        if(partRes.fileId == startedFile.fileId){
          progress.uploadedParts.add(partRes);
          progress.uploadedChunkCount += 1;
          progress.percentageUploaded =  ((progress.uploadedChunkCount * 100)/progress.totalChunkCount).toInt();
          Set chunks = Set.from(List<int>.generate(progress.totalChunkCount, (i) => i + 1));
          Set uploadedChunks = Set.from(progress.uploadedParts.map((ite) => ite.partNumber).toList());
          progress.remainingChunks = List.from(chunks.difference(uploadedChunks));
          widget.onProgressChanged(progress);
          if(mounted){
            setState(() {
              uploadProgress = progress.percentageUploaded;
              allPartsAreSaved = progress.totalChunkCount == progress.uploadedChunkCount? true : false;
            });
          }
          if(allPartsAreSaved) {
            await finishUp(startedFile.fileId);
          }
        }
      }
    }, onError: (err){
      debugPrint('Error in save: $err');
    });
    
  }

  void cancel() {
    receivePort.close();
    if(mounted){
      setState(() {
        picking = false;
        finishing = false;
        showProgress = false;
        saving = false;
      });
    }
  }

  @override
  void initState(){
    if(mounted) {
      setState(() {
        alreadyUploaded = widget.alreadyUploaded;
        durationLimitInMinutes = widget.isShort? 3 : 300;
      });
    }
    Future.delayed(Duration.zero, () async {
      if(widget.hasPartialUpload) await continueUpload();
    });
    super.initState();
  }

  @override
  void dispose(){
    receivePort.close();
    FlutterIsolate.killAll();
    super.dispose();
  }

  Future<List<Stream<List<int>>>> putFileInChunks(File file) async { 
    final chunkSize = 5 * 1024 * 1024; // 5 MB 
    final totalChunks = (file.lengthSync() / chunkSize).ceil(); 
    List<Stream<List<int>>> chunks = [];
    for (var i = 0; i < totalChunks; i++) { 
      final start = i * chunkSize; 
      final end = (i + 1) * chunkSize; 
      Stream<List<int>> fileChunk = file.openRead(start, end); 
      chunks.add(fileChunk); 
    }
    return chunks;
  }

  Future<void> pickVideo() async {
    try{
      if(mounted) setState(() => picking = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.video,
        dialogTitle: "Upload Video",
        withData: false,
        compressionQuality: 50,
        withReadStream: true,
        // allowedExtensions: ['mov', 'mp4', 'mpeg4', 'avi', "wmv", "mpegps", "flv", "3gpp", "webm", "hevc", "dnxhr", "prores", "cineform", "dnx", "mpg", "fmp4", "matroska"],
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        debugPrint("Got here: $file.size");
        if(file.size > 0 && file.size <= 10000000000){
          String? filePath = file.path;
          int chunkSize = getChunkSize(file.size);
          if(filePath != null){
            if(widget.onVideoPicked != null) widget.onVideoPicked!(filePath);
            VideoPlayerController controller = VideoPlayerController.file(File(filePath));
            await controller.initialize();
            Duration duration = controller.value.duration;
            if(duration.inMinutes <= durationLimitInMinutes){
              List<String> durationList = duration.toString().split(":");
              if(durationList.length >= 3){
                PrudVidDuration dur = PrudVidDuration(
                  hours: durationList[0],
                  minutes: durationList[1],
                  seconds: durationList[2].split(".")[0],
                );
                widget.onDurationGotten(dur);
              }
              String? mimeType = lookupMimeType(filePath);
              MediaType? contentType = mimeType != null? MediaType.parse(mimeType) : null;
              Stream<List<int>>?  fileReadStream = file.readStream;
              if (fileReadStream != null && contentType != null) {
                if(mounted) {
                  setState(() {
                    filename = tabData.removeSpace(file.name);
                    picking = false;
                    saving = true;
                  });
                }
                StartLargeFileResponse? res = await backblazeNotifier.startLargeFileCreation("${widget.destination}/$filename", contentType.mimeType);
                if(res != null) { 
                  int countPart = 0; 
                  Stream<Uint8List> chunkedStream = sliceStream(fileReadStream, chunkSize).asBroadcastStream();          
                  await for(Uint8List part in chunkedStream){
                    countPart += 1;
                    String sha1 = "${backblazeNotifier.generateSha1(part)}";
                    uploadSha1s.add(sha1);
                    UploadVideoServiceArg arg = UploadVideoServiceArg(
                      fileId: res.fileId,
                      part: countPart,
                      partVideo: part,
                      sendPort: receivePort.sendPort,
                      cred: B2Credential(
                        b2DownloadToken: b2DownloadToken!, 
                        b2AccToken: b2AccToken!, 
                        b2AuthKey: b2AuthKey!, 
                        b2ApiUrl: b2ApiUrl!
                      ),
                      sha1: sha1
                    );
                    await Isolate.spawn(uploadVideoService, arg, onError: receivePort.sendPort, onExit: receivePort.sendPort);
                  }
                  await save(res, countPart);
                }else{
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Translate(text: "Unable To Save Video"),
                    ));
                    setState(() => saving = false);
                  }
                }
              }else{
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Translate(text: "Failed to read file"),
                  ));
                  setState(() => picking = false);
                }
              }
            }else{
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Translate(text: "Video duration exceeds 5 hours"),
                ));
                setState(() => picking = false);
              }
            }
          }else{
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Translate(text: "Failed to read file"),
              ));
              setState(() => picking = false);
            }
          }
        }else{
          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Translate(text: "Filesize exceeds 5GB"),
            ));
            setState(() => picking = false);
          }
        }
      } else {
        if(mounted) setState(() => picking = false);
      }
    }catch(ex){
      if(mounted) setState(() => picking = false);
      debugPrint("Picker Error: $ex");
      if(widget.onError != null) widget.onError!(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PrudContainer(
      hasTitle: true,
      title: "Select Video",
      child: Column(
        children: [
          mediumSpacer.height,
          SizedBox(
            child: alreadyUploaded? Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    value: 1.0,
                    color: prudColorTheme.buttonB,
                    minHeight: 3,
                    backgroundColor: prudColorTheme.lineC,
                    valueColor: AlwaysStoppedAnimation<Color>(prudColorTheme.buttonB),
                  ),
                ),
                Translate(
                  text: "Uploaded 100%",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: prudColorTheme.textB,
                  ),
                  align: TextAlign.right,
                )
              ],
            ) : Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(saving) SizedBox(
                  width: 200,
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        value: (uploadProgress/100).toDouble(),
                        // color: prudColorTheme.buttonB,
                        minHeight: 3,
                        backgroundColor: prudColorTheme.lineC,
                        valueColor: AlwaysStoppedAnimation<Color>(prudColorTheme.buttonB),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Translate(
                                  text: "Saving",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: prudColorTheme.textB,
                                  ),
                                  align: TextAlign.left,
                                ),
                                LoadingComponent(
                                  size: 5,
                                  isShimmer: false,
                                  defaultSpinnerType: false,
                                  spinnerColor: prudColorTheme.textB,
                                )
                              ],
                            ),
                            Text(
                              "$uploadProgress%",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.iconB,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if(finishing) SizedBox(
                  width: 200,
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        // color: prudColorTheme.buttonB,
                        minHeight: 3,
                        backgroundColor: prudColorTheme.lineC,
                        valueColor: AlwaysStoppedAnimation<Color>(prudColorTheme.buttonB),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Translate(
                                  text: "Finishing",
                                  style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: prudColorTheme.buttonA,
                                  ),
                                  align: TextAlign.left,
                                ),
                                LoadingComponent(
                                  size: 5,
                                  isShimmer: false,
                                  defaultSpinnerType: false,
                                  spinnerColor: prudColorTheme.buttonA,
                                )
                              ],
                            ),
                            Text(
                              "Saved",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.iconB,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                picking? LoadingComponent(
                  size: 20,
                  isShimmer: false,
                  defaultSpinnerType: false,
                  spinnerColor: prudColorTheme.primary,
                ) : getTextButton(
                    title: saving || finishing? "Cancel" : "Click To Upload",
                    onPressed: saving || finishing? cancel : pickVideo,
                    color: prudColorTheme.primary
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}
