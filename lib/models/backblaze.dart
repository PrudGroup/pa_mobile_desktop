import 'dart:isolate';

import 'package:flutter/foundation.dart';

class StartLargeFileResponse{
  String accountId;
  String action; // upload, hide, folder, start
  String bucketId;
  int contentLength;
  String? contentSha1;
  String? contentMd5;
  String contentType;
  String fileId;
  Map<String, dynamic> fileInfo;
  String fileName;
  dynamic legalHold;
  dynamic fileRetention;
  String? replicationStatus;
  dynamic serverSideEncryption;
  int uploadTimestamp;

  StartLargeFileResponse({
    required this.accountId,
    required this.action,
    required this.bucketId,
    required this.contentLength,
    required this.contentSha1,
    required this.contentType,
    required this.fileId,
    required this.fileInfo,
    required this.fileName,
    this.legalHold,
    this.contentMd5,
    this.fileRetention,
    this.replicationStatus,
    this.serverSideEncryption,
    required this.uploadTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'action': action,
      'bucketId': bucketId,
      'contentLength': contentLength,
      'contentSha1': contentSha1,
      'contentMd5': contentMd5,
      'contentType': contentType,
      'fileId': fileId,
      'fileInfo': fileInfo,
      'fileName': fileName,
      'legalHold': legalHold,
      'fileRetention': fileRetention,
      'replicationStatus': replicationStatus,
      'serverSideEncryption': serverSideEncryption,
      'uploadTimestamp': uploadTimestamp,
    };
  }

  factory StartLargeFileResponse.fromJson(Map<String, dynamic> json) {
    return StartLargeFileResponse(
      accountId: json['accountId'],
      action: json['action'],
      bucketId: json['bucketId'],
      contentLength: json['contentLength'],
      contentSha1: json['contentSha1'],
      contentMd5: json['contentMd5'],
      contentType: json['contentType'],
      fileId: json['fileId'],
      fileInfo: json['fileInfo'],
      fileName: json['fileName'],
      legalHold: json['legalHold'],
      fileRetention: json['fileRetention'],
      replicationStatus: json['replicationStatus'],
      serverSideEncryption: json['serverSideEncryption'],
      uploadTimestamp: json['uploadTimestamp'],
    );
  }
}

class UploadUrlForLargeFile{
  String fileId;
  String uploadUrl;
  String authorizationToken;

  UploadUrlForLargeFile({
    required this.fileId,
    required this.uploadUrl,
    required this.authorizationToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'uploadUrl': uploadUrl,
      'authorizationToken': authorizationToken,
    };
  }

  factory UploadUrlForLargeFile.fromJson(Map<String, dynamic> json) {
    return UploadUrlForLargeFile(
      fileId: json['fileId'],
      uploadUrl: json['uploadUrl'],
      authorizationToken: json['authorizationToken'],
    );
  }
}

class UploadPartResponse{
  String fileId;
  int partNumber;
  int contentLength;
  String contentSha1;
  String? contentMd5;
  int uploadTimestamp;

  UploadPartResponse({
    required this.fileId,
    required this.partNumber,
    required this.contentLength,
    required this.contentSha1,
    required this.uploadTimestamp,
    this.contentMd5,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'partNumber': partNumber,
      'contentLength': contentLength,
      'contentSha1': contentSha1,
      if(contentMd5 != null) 'contentMd5': contentMd5,
      'uploadTimestamp': uploadTimestamp,
    };
  }

  factory UploadPartResponse.fromJson(Map<String, dynamic> json) {
    return UploadPartResponse(
      fileId: json['fileId'],
      partNumber: json['partNumber'],
      contentLength: json['contentLength'],
      contentSha1: json['contentSha1'],
      uploadTimestamp: json['uploadTimestamp'],
      contentMd5: json['contentMd5'],
    );
  }
}

class LargeFileFinishedResponse{
  String fileId;
  String accountId;
  String action; // watch out for "upload"
  String bucketId;
  int contentLength;
  String contentSha1;
  String? contentMd5;
  String contentType;
  dynamic fileInfo;
  String fileName;
  Map<String, dynamic>? fileRetention;
  Map<String, dynamic>? legalHold;
  String? replicationStatus;
  int uploadTimestamp;

  LargeFileFinishedResponse({
    required this.accountId,
    required this.action,
    required this.bucketId,
    required this.contentLength,
    required this.contentSha1,
    required this.contentType,
    required this.fileId,
    required this.fileInfo,
    required this.fileName,
    required this.uploadTimestamp,
    this.contentMd5,
    this.fileRetention,
    this.legalHold,
    this.replicationStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'action': action,
      'bucketId': bucketId,
      'contentLength': contentLength,
      'contentSha1': contentSha1,
      'contentType': contentType,
      'fileInfo': fileInfo,
      'fileName': fileName,
      'uploadTimestamp': uploadTimestamp,
      "fileId": fileId,
      if(contentMd5 != null) 'contentMd5': contentMd5,
      if(fileRetention != null) 'fileRetention': fileRetention,
      if(legalHold != null) 'legalHold': legalHold,
      if(replicationStatus != null) 'replicationStatus': replicationStatus,
    };
  }

  factory LargeFileFinishedResponse.fromJson(Map<String, dynamic> json) {
    return LargeFileFinishedResponse(
      accountId: json['accountId'],
      action: json['action'],
      bucketId: json['bucketId'],
      contentLength: json['contentLength'],
      contentSha1: json['contentSha1'],
      contentType: json['contentType'],
      fileId: json['fileId'],
      fileInfo: json['fileInfo'],
      fileName: json['fileName'],
      uploadTimestamp: json['uploadTimestamp'],
      contentMd5: json['contentMd5'],
      fileRetention: json['fileRetention'],
      legalHold: json['legalHold'],
      replicationStatus: json['replicationStatus'],
    );
  }
}

class B2Credential{
  String b2DownloadToken;
  String b2AccToken;
  String b2AuthKey;
  String b2ApiUrl;

  B2Credential({
    required this.b2DownloadToken,
    required this.b2AccToken,
    required this.b2AuthKey,
    required this.b2ApiUrl,
  });
}

class UploadVideoStreamArg{
  SendPort sendPort;
  Stream<Uint8List> stream; 
  String contentType;
  String fileDestination;
  StartLargeFileResponse createdFile;
  B2Credential cred;
  String sha1;

  UploadVideoStreamArg({
    required this.sendPort,
    required this.stream,
    required this.contentType,
    required this.fileDestination,
    required this.createdFile,
    required this.cred,
    required this.sha1
  });
}

class UploadVideoServiceArg{
  SendPort sendPort;
  String fileId;
  Uint8List partVideo;
  int part;
  B2Credential cred;
  String sha1;

  UploadVideoServiceArg({
    required this.sendPort,
    required this.fileId,
    required this.partVideo,
    required this.part,
    required this.cred,
    required this.sha1
  });

}

class SaveVideoResponse{
  int totalChunkCount;
  int uploadedChunkCount;
  int percentageUploaded;
  StartLargeFileResponse startedLargeFile;
  List<UploadPartResponse> uploadedParts;
  List<int> remainingChunks;

  SaveVideoResponse({
    required this.totalChunkCount,
    required this.uploadedChunkCount,
    required this.percentageUploaded,
    required this.startedLargeFile,
    required this.uploadedParts,
    required this.remainingChunks,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalChunkCount': totalChunkCount,
      'uploadedChunkCount': uploadedChunkCount,
      'percentageUploaded': percentageUploaded,
      'startedLargeFile': startedLargeFile.toJson(),
      'uploadedParts': uploadedParts.map((part) => part.toJson()).toList(),
     'remainingChunks': remainingChunks,
    };
  }

  factory SaveVideoResponse.fromJson(Map<String, dynamic> json) {
    return SaveVideoResponse(
      totalChunkCount: json['totalChunkCount'],
      uploadedChunkCount: json['uploadedChunkCount'],
      percentageUploaded: json['percentageUploaded'],
      startedLargeFile: StartLargeFileResponse.fromJson(json['startedLargeFile']),
      uploadedParts: json['uploadedParts'].map<UploadPartResponse>((part) => UploadPartResponse.fromJson(part)).toList(),
      remainingChunks:  json['remainingChunks'].map<int>((ct) => int.parse(ct.toString())).toList(),
    );
  }
}
