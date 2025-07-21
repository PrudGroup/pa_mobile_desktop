import 'package:flutter/foundation.dart';
import 'package:prudapp/models/advert/advert.dart';
import 'package:prudapp/notifiers/advert_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'advert_socket_service.g.dart';

@Riverpod(keepAlive: true)
class AdvertSocketService extends _$AdvertSocketService {
  late IO.Socket _socket;

  @override
  AdvertSocketService build(String? advertId) {
    try{
      _initSocket(advertId);
    }catch(ex){
      debugPrint("Error: $ex");
    }
    return this;
  }

  void _initSocket(String? currentAdvertId) {
    _socket = IO.io('http://your_socket_io_server_url.com',
      IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter, use websockets
        .disableAutoConnect() // disable auto-connection
        .setExtraHeaders({'foo': 'bar'}) // optional
        .build());

    _socket.connect();

    _socket.onConnect((_) {
      debugPrint('Socket connected');
    });

    _socket.on('advert_updated', (data) {
      debugPrint('Advert updated via socket: $data');
      try {
        final updatedAdvert = Advert.fromJson(data);
        // Notify advert list provider about the update
        ref.read(advertListNotifierProvider.notifier).updateAdvertInList(updatedAdvert);
      } catch (e) {
        debugPrint('Error parsing advert_updated data: $e');
        // Handle parsing error for socket data
      }
    });

    _socket.on('advert_deleted', (data) {
      debugPrint('Advert deleted via socket: $data');
      if (data is Map && data.containsKey('id')) {
        final String advertId = data['id'];
        ref.read(advertListNotifierProvider.notifier).removeAdvertFromList(advertId);
      } else {
        debugPrint('Error: Advert ID not found in socket delete data.');
      }
    });

    _socket.onDisconnect((_) => debugPrint('Socket disconnected'));
    _socket.onConnectError((err) => debugPrint('Socket Connect Error: $err'));
    _socket.onError((err) => debugPrint('Socket Error: $err'));
  }

  void disconnect() {
    _socket.disconnect();
  }

  // You can add methods to emit events if your backend requires it,
  // e.g., for reporting advert impressions/clicks in real-time.
  void emitAdvertEvent(String advertId, String eventType, {int count = 1, int? watchMinutes}) {
    try {
      _socket.emit('advert_event', {
        'advertId': advertId,
        'eventType': eventType, // e.g., 'impression', 'click', 'watch'
        'count': count,
        if (watchMinutes != null) 'watchMinutes': watchMinutes,
      });
    } catch (e) {
      debugPrint('Error emitting socket event: $e');
    }
  }
}