import 'dart:typed_data';
import 'dart:io';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

part 'file_socket_service.g.dart';


@Riverpod(keepAlive: true)
class FileSocketService extends _$FileSocketService {
  Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  @override
  FutureOr<FileSocketService> build() async {
    try{
      await _connect();
    }catch(ex){
      debugPrint("Error: $ex");
    }
    return this;
  }

  Future<void> _connect() async { 
    _socket = io("$apiEndPoint/file_io",
    OptionBuilder()
      .setAckTimeout(3000)
      .setReconnectionAttempts(3)
      .setReconnectionDelay(2000)
      .setRememberUpgrade(true)
      .setTransports(['websocket'])
      .setAuth({"AppCredential": prudApiKey,})
      .disableAutoConnect()
      .setExtraHeaders({"AppCredential": prudApiKey,})
      .build());


    final connectionCompleter = Completer<void>();

    if (_socket != null && !_socket!.connected) {
      _socket?.connect();
    }

    _socket?.onConnect((data) {
      Logger().d(['Connected to file socket', data]);
      if (!connectionCompleter.isCompleted) {
        connectionCompleter.complete();
      }
    });

    _socket?.onDisconnect((data) {
      Logger().d(['Disconnected from file socket', data]);
    });

    _socket?.off('error');
    _socket?.on('error', (data) {
      ('Socket error: $data');
    });

    // Listen for upload responses
    _socket?.off('upload_single_file_response');
    _socket?.on('upload_single_file_response', (data) {
      handleUploadResponse(data);
    });

    _socket?.off('upload_multiple_files_response');
    _socket?.on('upload_multiple_files_response', (data) {
      handleMultipleUploadResponse(data);
    });

    _socket?.off('upload_large_file_part_response');
    _socket?.on('upload_large_file_part_response', (data) {
      handleLargeFilePartResponse(data);
    });

    _socket?.off('start_large_file_upload_response');
    _socket?.on('start_large_file_upload_response', (data) {
      handleStartLargeFileResponse(data);
    });

    _socket?.off('finish_large_file_upload_response');
    _socket?.on('finish_large_file_upload_response', (data) {
      handleFinishLargeFileResponse(data);
    });

    _socket?.off('upload_large_chunks_once_response');
    _socket?.on('upload_large_chunks_once_response', (data) {
      handleLargeChunksResponse(data);
    });

    _socket?.off('get_download_url_response');
    _socket?.on('get_download_url_response', (data) {
      handleDownloadUrlResponse(data);
    });

    _socket?.off('get_download_token_response');
    _socket?.on('get_download_token_response', (data) {
      handleDownloadTokenResponse(data);
    });

    _socket?.off('delete_file_response');
    _socket?.on('delete_file_response', (data) {
      handleDeleteFileResponse(data);
    });

    _socket?.off('upload_progress');
    _socket?.on('upload_progress', (data) {
      handleUploadProgress(data);
    });

    await connectionCompleter.future;
  }

  // Upload single file
  Future<void> uploadSingleFile({
    required Uint8List fileData,
    required String filename,
    required String destination,
    String? contentType,
    int useBucket = 2,
  }) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    final data = {
      'file_data': fileData.toList(), // Convert Uint8List to List<int>
      'filename': filename,
      'destination': destination,
      'content_type': contentType,
      'use_bucket': useBucket,
    };

    _socket?.emit('upload_single_file', data);
  }

  // Upload multiple files
  Future<void> uploadMultipleFiles({
    required List<FileData> files,
    required String destination,
  }) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    final filesData = files.map((file) => {
      'file_data': file.data.toList(), // Convert Uint8List to List<int>
      'filename': file.filename,
      'content_type': file.contentType,
    }).toList();

    final data = {
      'files': filesData,
      'destination': destination,
    };

    _socket?.emit('upload_multiple_files', data);
  }

  // Start large file upload
  Future<void> startLargeFileUpload({
    required String filename,
    required String authToken,
    String? contentType,
    Map<String, String>? fileInfo,
  }) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    final data = {
      'auth_token': authToken,
      'filename': filename,
      'contentType': contentType,
      'fileInfo': fileInfo ?? {},
    };

    _socket?.emit('start_large_file_upload', data);
  }

  // Upload large file part
  Future<void> uploadLargeFilePart({
    required String authToken,
    required int driveToUse,
    required String fileId,
    required int partNumber,
    required Uint8List part,
  }) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    final data = {
      'auth_token': authToken,
      'driveToUse': driveToUse,
      'fileId': fileId,
      'partNumber': partNumber,
      'part': part.toList(), // Convert Uint8List to List<int>
    };

    _socket?.emit('upload_large_file_part', data);
  }

  // Upload large file in chunks at once
  Future<void> uploadLargeChunksOnce({
    required String authToken,
    required String filename,
    required List<Uint8List> chunks,
  }) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    final uploadsData = chunks.map((chunk) => chunk.toList()).toList();

    final data = {
      'auth_token': authToken,
      'filename': filename,
      'uploads': uploadsData,
    };

    _socket?.emit('upload_large_chunks_once', data);
  }

  // Finish large file upload
  Future<void> finishLargeFileUpload({
    required String authToken,
    required int driveToUse,
    required String fileId,
    List<String>? parts,
  }) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    final data = {
      'auth_token': authToken,
      'driveToUse': driveToUse,
      'fileId': fileId,
      'parts': parts,
    };

    _socket?.emit('finish_large_file_upload', data);
  }

  // Get download URL
  Future<void> getDownloadUrl(String filename) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    _socket?.emit('get_download_url', {'file_name': filename});
  }

  // Get download token
  Future<void> getDownloadToken() async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    _socket?.emit('get_download_token', {});
  }

  // Delete file
  Future<void> deleteFile(String filename) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    _socket?.emit('delete_file', {'filename': filename});
  }

  // Subscribe to upload progress
  Future<void> subscribeToUploadProgress(String uploadId) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    _socket?.emit('subscribe_to_upload_progress', {'upload_id': uploadId});
  }

  // Unsubscribe from upload progress
  Future<void> unsubscribeFromUploadProgress(String uploadId) async {
    if (!isConnected) {
      Logger().d('Socket not connected');
      return;
    }

    _socket?.emit('unsubscribe_from_upload_progress', {'upload_id': uploadId});
  }

  // Helper method to pick and upload file
  Future<void> pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      
      if (file.bytes != null) {
        await uploadSingleFile(
          fileData: file.bytes!,
          filename: file.name,
          destination: 'uploads',
          contentType: _getContentType(file.extension),
        );
      } else if (file.path != null) {
        // For mobile platforms, read file from path
        File fileObj = File(file.path!);
        Uint8List fileBytes = await fileObj.readAsBytes();
        
        await uploadSingleFile(
          fileData: fileBytes,
          filename: file.name,
          destination: 'uploads',
          contentType: _getContentType(file.extension),
        );
      }
    }
  }

  // Helper method to chunk large file
  List<Uint8List> chunkFile(Uint8List fileData, int chunkSize) {
    List<Uint8List> chunks = [];
    int offset = 0;
    
    while (offset < fileData.length) {
      int end = (offset + chunkSize < fileData.length) 
          ? offset + chunkSize 
          : fileData.length;
      
      chunks.add(fileData.sublist(offset, end));
      offset += chunkSize;
    }
    
    return chunks;
  }

  // Helper method to upload large file with progress
  Future<void> uploadLargeFileWithProgress({
    required Uint8List fileData,
    required String filename,
    required String authToken,
    int chunkSize = 1024 * 1024 * 5, // 5MB chunks
  }) async {
    // Start large file upload
    await startLargeFileUpload(
      filename: filename,
      authToken: authToken,
      contentType: _getContentType(filename.split('.').last),
    );

    // Chunk the file
    List<Uint8List> chunks = chunkFile(fileData, chunkSize);

    // Upload chunks at once
    await uploadLargeChunksOnce(
      authToken: authToken,
      filename: filename,
      chunks: chunks,
    );
  }

  String? _getContentType(String? extension) {
    if (extension == null) return null;
    
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      case 'txt':
        return 'text/plain';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // Response handlers
  void handleUploadResponse(dynamic data) {
    Logger().d('Single file upload response: $data');
    if (data['success']) {
      Logger().d('File uploaded successfully: ${data['data']}');
    }
  }

  void handleMultipleUploadResponse(dynamic data) {
    Logger().d('Multiple files upload response: $data');
    if (data['success']) {
      Logger().d('Files uploaded successfully: ${data['data']}');
    }
  }

  void handleLargeFilePartResponse(dynamic data) {
    Logger().d('Large file part upload response: $data');
  }

  void handleStartLargeFileResponse(dynamic data) {
    Logger().d('Start large file upload response: $data');
  }

  void handleFinishLargeFileResponse(dynamic data) {
    Logger().d('Finish large file upload response: $data');
  }

  void handleLargeChunksResponse(dynamic data) {
    Logger().d('Large chunks upload response: $data');
  }

  void handleDownloadUrlResponse(dynamic data) {
    Logger().d('Download URL response: $data');
  }

  void handleDownloadTokenResponse(dynamic data) {
    Logger().d('Download token response: $data');
  }

  void handleDeleteFileResponse(dynamic data) {
    Logger().d('Delete file response: $data');
  }

  void handleUploadProgress(dynamic data) {
    Logger().d('Upload progress: $data');
    // Update UI with progress data
  }

  void dispose() {
    _socket?.dispose();
  }
}

// Data class for file information
class FileData {
  final Uint8List data;
  final String filename;
  final String? contentType;

  FileData({
    required this.data,
    required this.filename,
    this.contentType,
  });
}

