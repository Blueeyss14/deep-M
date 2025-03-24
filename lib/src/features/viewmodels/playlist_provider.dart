import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<Map<String, String>>> playlists = {};

  static const String playlistsFileName = 'playlists.json';
  static const String _downloadStatusFileName = 'download_status.json';

  Map<String, bool> downloadStatus = {};

  Future<void> addToPlaylist(
    String playlistName,
    Map<String, String> song,
  ) async {
    if (!playlists.containsKey(playlistName)) {
      playlists[playlistName] = [];
    }
    playlists[playlistName]!.add(song);
    notifyListeners();
  }

  Future<void> savePlaylist() async {
    try {
      final file = await _getJsonFile(playlistsFileName);
      final playlistJson = json.decode(playlists.toString());
      await file.writeAsString(json.encode(playlistJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving playlist: $e');
      }
    }
  }

  Future<File> _getJsonFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> saveDownloadStatus() async {
    try {
      final file = await _getJsonFile(_downloadStatusFileName);
      final downloadStatusJson = json.encode(downloadStatus);
      await file.writeAsString(downloadStatusJson);
    } catch (e) {
      print('Error saving download status: $e');
    }
  }
}
