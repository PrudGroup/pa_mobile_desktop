
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/constants.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:crypto/crypto.dart';

class BackblazeNotifier extends ChangeNotifier {
  static final BackblazeNotifier _backblazeNotifier = BackblazeNotifier._internal();
  static get backblazeNotifier => _backblazeNotifier;
  

  factory BackblazeNotifier(){
    return _backblazeNotifier;
  }

  Future<StartLargeFileResponse?> startLargeFileCreation(String fileName, String contentType) async {
    return await tryAsync("startLargeFileCreation", () async {
      Map<String, dynamic> data = {
        "bucketId": b2Key,
        "fileName": fileName,
        "contentType": contentType,
        "fileInfo": {"started_at": DateTime.now().toIso8601String()},
      };
      String path = "b2api/v3/b2_start_large_file";
      dynamic res = await makeRequest(path: path, isGet: false, data: data);
      return res != null? StartLargeFileResponse.fromJson(res) : null;
    }, error: (){
      return null;
    });
  }

  Future<UploadUrlForLargeFile?> getUrlToUploadLargeFile(String fileId, B2Credential? cred) async {
    return await tryAsync("getUrlToUploadLargeFile", () async {
      String path = "b2api/v3/b2_get_upload_part_url";
      dynamic res = await makeRequest(path: path, isGet: true, qParam: {"fileId": fileId}, cred: cred);
      return res != null? UploadUrlForLargeFile.fromJson(res) : null;
    }, error: (){
      return null;
    });
  } 

  Future<UploadPartResponse?> uploadPartOfLargeFile(
    UploadUrlForLargeFile uploadLF, int partNumber, 
    Uint8List data, B2Credential? cred, String sha1
  ) async {
    return await tryAsync("uploadPartOfLargeFile", () async {
      String path = uploadLF.uploadUrl;
      Map<String, dynamic> headers = {
        "Content-Type": "b2/x-auto",
        "Content-Length": data.lengthInBytes,
        "X-Bz-Part-Number": partNumber,
        "X-Bz-Content-Sha1": sha1,
        "Authorization": uploadLF.authorizationToken,
      };
      dynamic res = await makeRequest(
        path: path, isGet: false, 
        useDefaultHeaders: false, headers: headers,
        data: data, cred: cred, urlIsFull: true
      );
      return res != null? UploadPartResponse.fromJson(res) : null;
    }, error: (){
      return null;
    });
  } 

  Future<LargeFileFinishedResponse?> finishLargeFileUpload(
    String fileId, List<String> partSha1s
  ) async {
    return await tryAsync("finishLargeFileUpload", () async {
      String path = "b2api/v3/b2_finish_large_file";
      dynamic res = await makeRequest(
        path: path, isGet: false, data: {
          "fileId": fileId,
          "partSha1Array": partSha1s,
        }
      );
      return res != null? LargeFileFinishedResponse.fromJson(res) : null;
    }, error: (){
      return null;
    });
  } 

  Future<LargeFileFinishedResponse?> checkIfFileUploaded(String fileId) async {
    return await tryAsync("checkIfFileUploaded", () async {
      String path = "b2api/v3/b2_get_file_info";
      dynamic res = await makeRequest(
        path: path, qParam: {
          "fileId": fileId,
        }
      );
      return res != null && res["fileId"] != null? LargeFileFinishedResponse.fromJson(res) : null;
    }, error: (){
      return null;
    });
  } 

  Digest generateSha1(Uint8List data) => sha1.convert(data);

  void setDioHeaders(B2Credential? cred) {
    String? token = cred != null? cred.b2AccToken : b2AccToken;
    b2Dio.options.headers.addAll({
      "Content-Type": "application/json",
      "Authorization": "$token",
    });
  }

  Future<dynamic> makeRequest({
    required String path, bool isGet = true, bool urlIsFull = false, bool useDefaultHeaders = true, 
    Map<String, dynamic>? headers, dynamic data, Map<String, dynamic>? qParam,
    B2Credential? cred 
  }) async {
    if(cred != null){
      b2AccToken = cred.b2AccToken;
      b2ApiUrl = cred.b2ApiUrl;
    }
    if (b2AccToken != null && b2ApiUrl != null) {
      b2Dio.options.headers.clear();
      if(useDefaultHeaders == true){
        setDioHeaders(cred);
      }else{
        if(headers != null) b2Dio.options.headers.addAll(headers);
      }
      String url = urlIsFull? path : "$b2ApiUrl/$path";
      Response res = isGet? await b2Dio.get(url, queryParameters: qParam) : await b2Dio.post(url, data: data);
      debugPrint("b2 Request: $res");
      return res.data;
    } else {
      return null;
    }
  }

  BackblazeNotifier._internal();
}



Dio b2Dio = Dio(BaseOptions(
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 60), // 60 seconds
    receiveTimeout: const Duration(seconds: 60),
    validateStatus: (statusCode) {
      if (statusCode != null) {
        if (statusCode == 422) {
          return true;
        }
        if (statusCode >= 200 && statusCode <= 300) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    }
  )
);
final backblazeNotifier = BackblazeNotifier();
const String b2Key = Constants.b2Key;
