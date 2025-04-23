import 'dart:isolate';
import 'dart:math' as math;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prudapp/models/prud_vid.dart';

class PushNotificationMessage {
  String? title;
  String? body;
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;


    String value = newValue.text;
    if((value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) || (value.contains(",") &&
        value.substring(value.indexOf(",") + 1).length > decimalRange)){
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if(value == "." || value == ","){
      truncated = "0.";
      int minimum = math.min(truncated.length, truncated.length + 1);
      newSelection = newValue.selection.copyWith(
        baseOffset: minimum,
        extentOffset: minimum
      );
    }
    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty
    );
  }
}


enum PaymentType{
  payIn,
  payOut,
  walletPayIn,
  walletPayOut,
}

enum PaymentStatus{
  succeeded,
  failed,
  confirmed,
  processing,
  pending
}


class Location{
  double? longitude;
  double? latitude;
  String? address;
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum TransactionType{
  debit,
  credit,
}

class PushMessage{
  final Map<String, dynamic> msg;
  RemoteNotification? notice;

  PushMessage(this.msg, this.notice);
}

class PrudSpacer{
  final SizedBox height;
  final SizedBox width;

  const PrudSpacer({required this.height, required this.width});
}

class PrudCredential{
  String key;
  String token;

  PrudCredential({
    required this.key,
    required this.token,
  });
}

enum Audience{adult, youth, teenage, kids, general}

enum VideoSearchType{
  promoted,
  category,
  titleTags,
  promotedCountry,
  categoryTitleTags,
  audienceTitleTags,
  categoryAnalytics,
  categoryAudienceTitleTags,
}

class VideoSearch{
  VideoSearchType searchType;
  String? country;
  String? searchText;
  String? category;
  Audience? audience;
  int limit;
  int offset;

  VideoSearch({
    required this.searchType,
    this.country,
    this.searchText,
    this.category,
    this.audience,
    this.limit = 100,
    this.offset = 0,
  }) : assert(searchType == VideoSearchType.category? category != null 
    : (searchType == VideoSearchType.categoryAnalytics? category != null 
    : (searchType == VideoSearchType.audienceTitleTags? audience != null && searchText != null 
    : (searchType == VideoSearchType.categoryAudienceTitleTags? audience != null && searchText != null && category != null 
    : (searchType == VideoSearchType.categoryTitleTags? category != null && searchText != null 
    : (searchType == VideoSearchType.promotedCountry? country != null 
    : (searchType == VideoSearchType.titleTags? searchText != null : true)))))));

  /// searchType 0 = only category,
  ///  1 = category, title, tags
  ///  2 = title, tags
  ///  3 = category, audience, title, tags
  ///  4 = audience, title, tags
  ///  5 = promoted, country
  ///  6 = only promoted
  ///  7 = category, analytics
  int toInt(){
    switch(searchType){
      case VideoSearchType.promoted: return 6;
      case VideoSearchType.category: return 0;
      case VideoSearchType.titleTags: return 2;
      case VideoSearchType.promotedCountry: return 5;
      case VideoSearchType.categoryTitleTags: return 1;
      case VideoSearchType.audienceTitleTags: return 4;
      case VideoSearchType.categoryAnalytics: return 7;
      case VideoSearchType.categoryAudienceTitleTags: return 3;
    }
  }
}

class VideoSearchServiceArg extends VideoSearch{
  SendPort sendPort;
  PrudCredential cred;

  VideoSearchServiceArg({
    required this.sendPort,
    required this.cred, 
    required super.searchType,
    super.audience,
    super.country,
    super.searchText,
    super.category,
    super.limit,
    super.offset,
  });
}

class VideoSuggestionServiceArg{
  SendPort sendPort;
  PrudCredential cred;
  VideoSearchServiceArg videoCateria;
  String broadcastSearchText;
  VideoSearchType promotedType;
  List<String> unwantedChannels;
  List<String> unwantedVideos;
  List<String> unwantedBroadcasts;

  VideoSuggestionServiceArg({
    required this.sendPort,
    required this.cred,
    required this.videoCateria,
    required this.broadcastSearchText,
    required this.promotedType,
    required this.unwantedChannels,
    required this.unwantedVideos,
    required this.unwantedBroadcasts,
  });
}


class BroadcastSearchServiceArg{
  SendPort sendPort;
  PrudCredential cred;
  String broadcastSearchText;

  BroadcastSearchServiceArg({
    required this.sendPort,
    required this.cred,
    required this.broadcastSearchText
  });
}


class ServiceArg{
  SendPort sendPort;
  PrudCredential cred;
  String itemId;

  ServiceArg({
    required this.sendPort,
    required this.cred,
    required this.itemId,
  });
}


class MinuteServiceArg extends ServiceArg {
  int minutes;

  MinuteServiceArg({
    required super.sendPort,
    required super.cred,
    required super.itemId,
    required this.minutes
  });
}

class ListItemSearchArg{
  SendPort sendPort;
  List<dynamic> searchList;
  dynamic searchItem;
  List<String>? searchFields;
  List<dynamic>? searchValues;

  ListItemSearchArg({
    required this.sendPort,
    required this.searchList,
    this.searchItem,
    this.searchFields,
    this.searchValues,
  }):assert(
    searchItem == null? searchFields != null && 
    searchValues != null &&  
    searchValues.length == searchFields.length 
      : searchFields == null && searchValues == null
    );
}

class DownloadChunkResponse{
  int chunkIndex;
  Uint8List downloadedBytes;
  bool finished;

  DownloadChunkResponse({
    required this.chunkIndex,
    required this.downloadedBytes,
    this.finished = false,
  });

  Map<String, dynamic> toJson(){
    return {
      "chunkIndex": chunkIndex,
      "finished": finished,
      "downloadedBytes": downloadedBytes
    };
  }
}

class DownloadChunkArg{
  SendPort port;
  int chunkIndex;
  int start;
  int end;
  String url;
  String filename;

  DownloadChunkArg({
    required this.port,
    required this.chunkIndex,
    required this.start,
    required this.end,
    required this.url,
    required this.filename,
  });
}

class DownloadChunksArg{
  SendPort port;
  List<int> chunkIndexs;
  String url;
  String filename;
  int eachChunkSize;
  int fileSize;

  DownloadChunksArg({
    required this.port,
    required this.chunkIndexs,
    required this.url,
    required this.filename,
    required this.eachChunkSize,
    required this.fileSize
  });
}

class DownloadSmallFileArg{
  SendPort port;
  String url;
  String filename;
  int fileSize;

  DownloadSmallFileArg({
    required this.port,
    required this.url,
    required this.filename,
    required this.fileSize
  });
}


class MergeBytesArg{
  SendPort port;
  List<Uint8List> actualBytes;
  List<int> actualBytesIndexes;
  List<int> arrangedIndex;

  MergeBytesArg({
    required this.port,
    required this.actualBytes,
    required this.actualBytesIndexes,
    required this.arrangedIndex
  });
}

enum ActionType {
  video, channelBroadcast, 
  channelBroadcastComment, thriller, 
  thrillerComment, videoComment, 
  streamBroadcast, streamBroadcastComment
}

enum CommentType {
  channelBroadcastComment,
  thrillerComment, videoComment, 
  streamBroadcastComment
}

class LikeDislikeActionArg{
  SendPort sendPort;
  LikeDislikeAction action;
  ActionType actionType;
  List<LikeDislikeAction> existingActions;
  PrudCredential cred;

  LikeDislikeActionArg({
    required this.sendPort,
    required this.action,
    required this.actionType,
    required this.existingActions,
    required this.cred,
  });
}

class CommonArg{
  String id;
  PrudCredential cred;
  SendPort sendPort;

  CommonArg({
    required this.id,
    required this.cred,
    required this.sendPort,
  });
}

class ConditionalWidgetItem{
  dynamic value;
  Widget widget;

  ConditionalWidgetItem({
    required this.value,
    required this.widget,
  });
}

class CountSchema{
  String countBy;
  int total;

  CountSchema({
    required this.countBy,
    required this.total
  });

  factory CountSchema.fromJson(Map<String, dynamic> json){
    return CountSchema(countBy: json["countBy"], total: json["total"]);
  }
}

class CommentPutSchema{
  String message;

  CommentPutSchema({required this.message});

  Map<String, dynamic> toJson(){
    return {"message": message};
  }
}