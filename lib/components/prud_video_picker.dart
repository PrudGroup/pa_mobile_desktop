import 'dart:isolate';

import 'package:buffer/buffer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/backblaze_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class PrudVideoPicker extends StatefulWidget {
  final Function(SaveVideoResponse) onProgressChanged;
  final Function(String)? onSaveToCloud;
  final Function(dynamic)? onError;
  final String destination;
  final bool saveToCloud;
  final bool reset;

  const PrudVideoPicker({
    super.key, 
    required this.onProgressChanged, 
    required this.destination, 
    this.saveToCloud = true, 
    this.reset = false, 
    this.onSaveToCloud, 
    this.onError,
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

  int getChunkSize(int fileSize){
    int chunkSize = (fileSize/100).toInt();
    if(fileSize < 500000000 && fileSize > 5000000){
      int checkFactor = (fileSize/5000000).toInt();
      chunkSize = (fileSize/checkFactor).toInt();
    }
    return chunkSize;
  }

  Future<void> finishUp(String fileId, List<String> sha1s) async {
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
      res = await backblazeNotifier.finishLargeFileUpload(fileId, sha1s);
      res ??= await backblazeNotifier.checkIfFileUploaded(fileId);
    }
    if(res != null){
      String? downloadUrl = await iCloud.getFileDownloadUrl(res.fileName);
      if(downloadUrl != null){
        widget.onSaveToCloud?.call(downloadUrl);
        receivePort.close();
      }else{
        widget.onError?.call('Failed to get downloadUrl');
      }
    }else{
      widget.onError?.call('Failed to finish upload');
    }
    if(mounted) setState(() => finishing = false);
  }

  Future<void> save(Stream<Uint8List> stream, String contentType) async {
    if(mounted) {
      setState(() {
        picking = false;
        saving = true;
      });
    }
    StartLargeFileResponse? res = await backblazeNotifier.startLargeFileCreation(widget.destination, contentType);
    if(res != null) {
      UploadVideoStreamArg arg = UploadVideoStreamArg(
        sendPort: receivePort.sendPort,
        stream: stream,
        contentType: contentType,
        fileDestination: widget.destination,
        createdFile: res
      );
      SaveVideoResponse progress = SaveVideoResponse(
        totalChunkCount: await stream.length,
        uploadedChunkCount: 0,
        percentageUploaded: 0,
        startedLargeFile: res,
        uploadedParts: [],
        remainingChunks: []
      );
      FlutterIsolate.spawn(uploadVideoStream, arg);
      receivePort.listen((resp) async {
        if(resp != null){
          UploadPartResponse partRes = UploadPartResponse.fromMap(resp);
          if(partRes.fileId == res.fileId){
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
              List<String> uploadSha1s = progress.uploadedParts.map((pat) => pat.contentSha1).toList();
              await finishUp(res.fileId, uploadSha1s);
            }
          }
        }
      });
    }else{
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Translate(text: "Unable To Start Video Upload"),
        ));
        setState(() => saving = false);
      }
    }
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
  void dispose(){
    receivePort.close();
    FlutterIsolate.killAll();
    super.dispose();
  }

  Future<void> pickVideo() async {
    try{
      if(mounted) setState(() => picking = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.video,
        dialogTitle: "Upload Video",
        compressionQuality: 50,
        withReadStream: true,
        // allowedExtensions: ['mov', 'mp4', 'mpeg4', 'avi', "wmv", "mpegps", "flv", "3gpp", "webm", "hevc", "dnxhr", "prores", "cineform", "dnx", "mpg", "fmp4", "matroska"],
      );
      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        if(file.size > 0 && file.size <= 10000000000){
          String? filePath = file.path;
          int chunkSize = getChunkSize(file.size);
          if(filePath != null){
            VideoData? videoInfo = await FlutterVideoInfo().getVideoInfo(filePath);
            if(videoInfo != null && videoInfo.duration != null){
              if(Duration(milliseconds: videoInfo.duration!.toInt()).inMinutes <= 300){
                String? mimeType = lookupMimeType(filePath);
                MediaType? contentType = mimeType != null? MediaType.parse(mimeType) : null;
                Stream<List<int>>?  fileReadStream = file.readStream;
                if (fileReadStream != null && contentType != null) {
                  Stream<Uint8List> chunkedStream = sliceStream(fileReadStream, chunkSize);
                  await save(chunkedStream, contentType.mimeType);
                }else{
                  if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Translate(text: "Failed to read file"),
                    ));
                    setState(() => picking = false);
                  }
                  return;
                }
              }else{
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Translate(text: "Video duration exceeds 5 hours"),
                  ));
                  setState(() => picking = false);
                }
                return;
              }
            }else{
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Translate(text: "Failed to get video metadata"),
                ));
                setState(() => picking = false);
              }
              return;
            }
          }else{
            if(mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Translate(text: "Failed to read file"),
              ));
              setState(() => picking = false);
            }
            return;
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
          Center(
            child: Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if(saving) SizedBox(
                  width: 130,
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        value: (uploadProgress/100).toDouble(),
                        color: prudColorTheme.buttonB,
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
                                  isShimmer: true,
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
                  width: 130,
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        color: prudColorTheme.buttonB,
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
                                  isShimmer: true,
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
                  size: 40,
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
