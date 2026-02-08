import 'dart:async';
import 'package:watcher/watcher.dart';
import 'dart:io';

class AutoRefreshService {
  static final AutoRefreshService instance = AutoRefreshService._();
  AutoRefreshService._();
  
  StreamController<void>? _refreshController;
  DirectoryWatcher? _watcher;
  
  Stream<void> get refreshStream => _refreshController!.stream;
  
  Future<void> startWatching(String directoryPath) async {
    _refreshController = StreamController<void>.broadcast();
    
    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) return;
      
      _watcher = DirectoryWatcher(directoryPath);
      _watcher!.events.listen((event) {
        // New status added
        _refreshController!.add(null);
      });
    } catch (e) {
      print('Error starting watcher: $e');
    }
  }
  
  void dispose() {
    _refreshController?.close();
  }
}