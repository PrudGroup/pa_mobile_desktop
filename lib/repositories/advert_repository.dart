import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:prudapp/apis/advert_api.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:logger/logger.dart';

class AdvertRepository {
  final AdvertApiClient _apiClient;

  AdvertRepository(this._apiClient);

  Future<List<Advert>> getAdverts(String token) async {
    try {
      return await _apiClient.getAdverts(token);
    } on DioException catch (e) {
      Logger().e("Error fetching adverts: ${e.response?.data ?? e.message}");
      throw Exception('Failed to fetch adverts: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error fetching adverts: $e");
      throw Exception('An unexpected error occurred while fetching adverts.');
    }
  }

  Future<Advert> getAdvertById(String id, String token) async {
    try {
      return await _apiClient.getAdvertById(id, token);
    } on DioException catch (e) {
      Logger().e("Error fetching advert by ID: ${e.response?.data ?? e.message}");
      throw Exception('Failed to fetch advert by ID: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error fetching advert by ID: $e");
      throw Exception('An unexpected error occurred while fetching advert by ID.');
    }
  }

  Future<Advert> createAdvert(Advert advert, String token) async {
    try {
      return await _apiClient.createAdvert(advert, token);
    } on DioException catch (e) {
      Logger().e("Error creating advert: ${e.response?.data ?? e.message}");
      throw Exception('Failed to create advert: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error creating advert: $e");
      throw Exception('An unexpected error occurred while creating advert.');
    }
  }

  /// Uploads advert media, using an Isolate to read file bytes for performance.
  Future<String> uploadAdvertMedia(File file, String advertId, String token) async {
    try {
      // Read file bytes in a separate isolate to prevent UI freezes
      final fileBytes = await compute(readFileBytesInIsolate, file.path);
      final filename = ''; // Use path package for basename

      final response = await _apiClient.uploadAdvertMedia(
        fileBytes,
        filename,
        advertId,
        token,
      );

      if (response.response.statusCode == 200) {
        // Assuming your backend returns the media URL upon successful upload
        return response.data['mediaUrl'] as String;
      } else {
        throw Exception('Failed to upload media: ${response.response.statusMessage}');
      }
    } on DioException catch (e) {
      Logger().e("Error uploading advert media: ${e.response?.data ?? e.message}");
      throw Exception('Failed to upload advert media: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error uploading advert media: $e");
      throw Exception('An unexpected error occurred while uploading advert media.');
    }
  }

  Future<Advert> updateAdvert(String id, Advert advert, String token) async {
    try {
      return await _apiClient.updateAdvert(id, advert, token);
    } on DioException catch (e) {
      Logger().e("Error updating advert: ${e.response?.data ?? e.message}");
      throw Exception('Failed to update advert: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error updating advert: $e");
      throw Exception('An unexpected error occurred while updating advert.');
    }
  }

  Future<void> deleteAdvert(String id, String token) async {
    try {
      await _apiClient.deleteAdvert(id, token);
    } on DioException catch (e) {
      Logger().e("Error deleting advert: ${e.response?.data ?? e.message}");
      throw Exception('Failed to delete advert: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error deleting advert: $e");
      throw Exception('An unexpected error occurred while deleting advert.');
    }
  }

  Future<Advert> updateAdvertStatus(String id, AdvertStatus status, String token) async {
    try {
      return await _apiClient.updateAdvertStatus(id, status.name, token);
    } on DioException catch (e) {
      Logger().e("Error updating advert status: ${e.response?.data ?? e.message}");
      throw Exception('Failed to update advert status: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error updating advert status: $e");
      throw Exception('An unexpected error occurred while updating advert status.');
    }
  }

  // New: Method to fetch advert costing options
  Future<List<AdvertCosting>> getAdvertCostings(String token) async {
    try {
      return await _apiClient.getAdvertCostings(token);
    } on DioException catch (e) {
      Logger().e("Error fetching advert costings: ${e.response?.data ?? e.message}");
      throw Exception('Failed to fetch advert costings: ${e.message}');
    } catch (e) {
      Logger().e("Unexpected error fetching advert costings: $e");
      throw Exception('An unexpected error occurred while fetching advert costings.');
    }
  }
}