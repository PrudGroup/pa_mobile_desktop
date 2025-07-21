import 'package:logger/logger.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/providers/advert_providers.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'advert_notifier.g.dart';


@Riverpod(keepAlive: true)
class AdvertListNotifier extends _$AdvertListNotifier {
  late String token;
  @override
  Future<List<Advert>> build() async {
    try {
      token = iCloud.affAuthToken?? '';
      final repo = ref.read(advertRepositoryProvider);
      return await repo.getAdverts(token);
    } catch (e) {
      Logger().e("Error building advert list: $e");
      return [];
    }
  }

  /// Adds a new advert to the list.
  Future<void> addAdvert(Advert advert) async {
    state = await AsyncValue.guard(() async {
      try {
        final repo = ref.read(advertRepositoryProvider);
        final newAdvert = await repo.createAdvert(advert, token);
        return [...state.value ?? [], newAdvert];
      } catch (e) {
        Logger().e("Error adding advert: $e");
        rethrow;
      }
    });
  }

  /// Updates an existing advert in the list.
  Future<void> updateAdvert(Advert advert) async {
    state = await AsyncValue.guard(() async {
      try {
        final repo = ref.read(advertRepositoryProvider);
        final updated = await repo.updateAdvert(advert.id!, advert, token);
        return [
          for (final adv in state.value ?? [])
            if (adv.id == updated.id) updated else adv,
        ];
      } catch (e) {
        Logger().e("Error updating advert: $e");
        rethrow;
      }
    });
  }

  /// Removes an advert from the list.
  Future<void> deleteAdvert(String id) async {
    state = await AsyncValue.guard(() async {
      try {
        final repo = ref.read(advertRepositoryProvider);
        await repo.deleteAdvert(id, token);
        return [
          for (final adv in state.value ?? [])
            if (adv.id != id) adv,
        ];
      } catch (e) {
        Logger().e("Error deleting advert: $e");
        rethrow;
      }
    });
  }

  /// Updates an advert's status.
  Future<void> updateAdvertStatus(String id, AdvertStatus status) async {
    state = await AsyncValue.guard(() async {
      try {
        final repo = ref.read(advertRepositoryProvider);
        final updated = await repo.updateAdvertStatus(id, status, token);
        return [
          for (final adv in state.value ?? [])
            if (adv.id == updated.id) updated else adv,
        ];
      } catch (e) {
        Logger().e("Error updating advert status: $e");
        rethrow;
      }
    });
  }

  /// Called by the socket service to update an advert in the list.
  void updateAdvertInList(Advert updatedAdvert) {
    state.whenData((adverts) {
      final index = adverts.indexWhere((adv) => adv.id == updatedAdvert.id);
      if (index != -1) {
        final newList = List<Advert>.from(adverts);
        newList[index] = updatedAdvert;
        state = AsyncValue.data(newList);
      } else {
        // If advert is new and received via socket (e.g., from another user creating it)
        state = AsyncValue.data([...adverts, updatedAdvert]);
      }
    });
  }

  /// Called by the socket service to remove an advert from the list.
  void removeAdvertFromList(String advertId) {
    state.whenData((adverts) {
      final newList = adverts.where((adv) => adv.id != advertId).toList();
      state = AsyncValue.data(newList);
    });
  }
}