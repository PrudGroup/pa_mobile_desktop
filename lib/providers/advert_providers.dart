import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/apis/advert_api.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/repositories/advert_repository.dart';
import 'package:prudapp/services/advert_socket_service.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';

part 'advert_providers.g.dart';

/// Provider for Dio instance (for Retrofit)
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio();
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }
  return dio;
}

/// Provider for AdvertApiClient (Retrofit)
@Riverpod(keepAlive: true)
AdvertApiClient advertApiClient(Ref ref) {
  return AdvertApiClient(ref.read(dioProvider));
}

/// Provider for AdvertRepository
@Riverpod(keepAlive: true)
AdvertRepository advertRepository(Ref ref) {
  return AdvertRepository(ref.read(advertApiClientProvider));
}

/// Provider for AdvertSocketService
@Riverpod(keepAlive: true)
AdvertSocketService advertSocketService(Ref ref) {
  final service = AdvertSocketService();
  ref.onDispose(() => service.disconnect());
  return service;
}


/// Provider to fetch and manage a list of available AdvertCosting options.
@Riverpod(keepAlive: true)
Future<List<AdvertCosting>> advertCostings(Ref ref) async {
  try {
    final repo = ref.read(advertRepositoryProvider);
    final token = iCloud.affAuthToken;
    if (token == null) {
      throw Exception('Authentication token not available.');
    }
    return await repo.getAdvertCostings(token);
  } catch (e) {
    debugPrint("Error loading advert costings in provider: $e");
    rethrow;
  }
}