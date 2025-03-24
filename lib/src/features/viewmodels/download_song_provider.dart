import 'dart:io';

import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DownloadSongProvider extends ChangeNotifier {
  MusicProvider? musicProvider;

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

      downloadStatus[videoId] = true;
      notifyListeners();
    } catch (e) {}
  }
}
