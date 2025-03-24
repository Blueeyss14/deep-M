import 'dart:convert';
import 'dart:io';

import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DownloadSongProvider extends ChangeNotifier {
  MusicProvider? musicProvider;
  static const String _downloadStatusFileName = 'download_status.json';

  void initMusicProvider(BuildContext context) {
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
  }

  Map<String, bool> downloadStatus = {};

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getAudioFile(String videoId) async {
    final path = await _localPath;
    return File('$path/$videoId.mp3');
  }

  Future<void> downloadAudio(String videoId, String title) async {
    if (downloadStatus[videoId] == true) return;

    downloadStatus[videoId] = false;
    notifyListeners();

    try {
      final manifest = await musicProvider?.youtube.videos.streamsClient
          .getManifest(videoId);
      final audioStreams = manifest?.audioOnly.toList();
      audioStreams?.sort((a, b) => a.bitrate.compareTo(b.bitrate));

      final audioStream = audioStreams!.isNotEmpty ? audioStreams[0] : null;

      if (audioStream == null) {
        throw Exception('No Audio Stream Found');
      }

      final file = await getAudioFile(videoId);
      final fileStream = file.openWrite();
      final len = audioStream.size.totalBytes;
      var count = 0;

      await for (final data in musicProvider!.youtube.videos.streamsClient.get(
        audioStream,
      )) {
        count += data.length;
        fileStream.add(data);

        final progress = (count / len * 100).toStringAsFixed(0);
        downloadStatus[videoId] = false;
        notifyListeners();
      }

      await fileStream.flush();
      await fileStream.close();

      downloadStatus[videoId] = true;
      notifyListeners();

      await saveDownloadStatus();
      print("berhasil donglot");
    } catch (e) {
      downloadStatus[videoId] = false;
      notifyListeners();
    }
  }

  Future<void> saveDownloadStatus() async {
    try {
      final file = await getJsonFile(_downloadStatusFileName);
      final downloadStatusJson = json.encode(downloadStatus);
      await file.writeAsString(downloadStatusJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving download status: $e');
      }
    }
  }

  Future<File> getJsonFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<void> loadDownloadStatus() async {
    try {
      final file = await getJsonFile(_downloadStatusFileName);
      if (await file.exists()) {
        final downloadStatusJson = await file.readAsString();
        final Map<String, dynamic> decoded = json.decode(downloadStatusJson);
        downloadStatus = Map<String, bool>.from(
          decoded.map((key, value) => MapEntry(key, value as bool)),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading download status: $e');
    }
  }
}
