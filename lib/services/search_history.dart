import 'dart:async';
import 'dart:isolate';

import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/shared_classes.dart';

class SearchHistoryManager {
  static final SearchHistoryManager _instance = SearchHistoryManager._internal();
  factory SearchHistoryManager() => _instance;

  // Private constructor
  SearchHistoryManager._internal();

  Isolate? _storageIsolate;
  SendPort? _isolateSendPort;
  final ReceivePort _mainReceivePort = ReceivePort();
  Completer<void>? _isolateReadyCompleter;

  // Initialize the Isolate
  Future<void> _initializeIsolate() async {
    if (_isolateReadyCompleter == null) {
      _isolateReadyCompleter = Completer<void>();
      _mainReceivePort.listen((message) {
        if (message is SendPort) {
          _isolateSendPort = message;
          _isolateReadyCompleter?.complete();
        }
      });
      _storageIsolate = await Isolate.spawn(storageIsolateEntry, _mainReceivePort.sendPort);
    }
    return _isolateReadyCompleter!.future;
  }

  // Save search text to history
  Future<void> saveSearchText(String searchText) async {
    if (searchText.trim().isEmpty) return; // Don't save empty strings

    await _initializeIsolate(); // Ensure Isolate is ready

    final Completer<String> completer = Completer<String>();
    final ReceivePort responsePort = ReceivePort();
    responsePort.listen((message) {
      if (message is String) {
        completer.complete(message);
        responsePort.close();
      }
    });

    _isolateSendPort?.send(SearchHistoryArg(
      action: HistroyAction.save,
      searchText: searchText,
      sendPort: responsePort.sendPort,
    ));
    await completer.future; // Wait for the save operation to complete
  }

  // Load search history
  Future<List<String>> loadSearchHistory() async {
    await _initializeIsolate(); // Ensure Isolate is ready

    final Completer<List<String>> completer = Completer<List<String>>();
    final ReceivePort responsePort = ReceivePort();
    responsePort.listen((message) {
      if (message is List) {
        completer.complete(message.cast<String>());
        responsePort.close();
      }
    });

    _isolateSendPort?.send(SearchHistoryArg(
      action: HistroyAction.load,
      sendPort: responsePort.sendPort,
    ));
    return completer.future;
  }

  // Dispose the Isolate when no longer needed (e.g., on app shutdown)
  void dispose() {
    _storageIsolate?.kill(priority: Isolate.immediate);
    _storageIsolate = null;
    _isolateSendPort = null;
    _mainReceivePort.close();
    _isolateReadyCompleter = null;
  }
}

const String searchHistoryKey = 'search_history';
const int maxHistorySize = 5;