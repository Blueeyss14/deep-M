import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicProvider extends ChangeNotifier {
  String currentTitle = '';
  bool isBuffering = false;
  bool isPlaying = false;

  final AudioPlayer audioPlayer = AudioPlayer();
  final YoutubeExplode youtube = YoutubeExplode();

  final Map<String, String> _audioStreamUrl = {};
  final Map<String, Set<Duration>> playedSegments = {};

  //Get Local Path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //Get Audio File
  Future<File> getAudioFile(String videoId) async {
    final path = await _localPath;
    return File('$path/$videoId.mp3');
  }

  MusicProvider(BuildContext context) {}

  Future<void> playAudio(
    BuildContext context,
    String videoId,
    String title,
  ) async {
    if (videoId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Video is empty')));
      return;
    }

    isBuffering = true;
    currentTitle = title;
    notifyListeners();

    try {
      final file = await getAudioFile(videoId);

      if (await file.exists()) {
        await audioPlayer.setFilePath(file.path);
      } else {
        String? audioUrl = _audioStreamUrl[videoId];

        if (audioUrl == null) {
          try {
            var manifest = await youtube.videos.streamsClient.getManifest(
              videoId,
            );
            var audioStreams = manifest.audioOnly.toList();
            audioStreams.sort((a, b) => a.bitrate.compareTo(b.bitrate));

            var audioStream = audioStreams.isNotEmpty ? audioStreams[0] : null;

            if (audioStream == null) {
              throw Exception('Audio Stream Not Found');
            }

            audioUrl = audioStream.url.toString();
            _audioStreamUrl[videoId] = audioUrl;
          } catch (e) {
            if (e.toString().contains('Socket') ||
                e.toString().contains('Connection')) {
              throw Exception('No Internet');
            }
            rethrow;
          }
        }
        await audioPlayer.setUrl(audioUrl);
      }
      await audioPlayer.seek(Duration.zero);
      startPreBuffering(videoId);
      await audioPlayer.play();

      isPlaying = true;
      notifyListeners();

      await audioPlayer.setLoopMode(LoopMode.off);
      audioPlayer.positionStream.listen((position) {
        if (playedSegments.containsKey(videoId)) {
          playedSegments[videoId]!.add(position);
        } else {
          playedSegments[videoId] = {position};
        }
      });
    } catch (e) {}
  }

  Timer? _preBufferTimer;
  final Map<String, Duration> preBufferPositions = {};

  void startPreBuffering(String videoId) {
    // Hentikan timer sebelumnya jika ada
    _preBufferTimer?.cancel();

    // Mulai pre-buffering setiap 15 detik
    _preBufferTimer = Timer.periodic(const Duration(seconds: 15), (
      timer,
    ) async {
      if (isPlaying && !isBuffering) {
        var currentPosition = audioPlayer.position;
        preBufferPositions[videoId] = currentPosition;

        try {
          // Cek apakah posisi ini sudah pernah di-buffer
          if (playedSegments.containsKey(videoId) &&
              playedSegments[videoId]!.contains(currentPosition)) {
            return; // Skip buffering jika posisi sudah pernah di-buffer
          }

          // Tambahkan posisi yang sudah di-buffer ke dalam set
          if (playedSegments.containsKey(videoId)) {
            playedSegments[videoId]!.add(currentPosition);
          } else {
            playedSegments[videoId] = {currentPosition};
          }
        } catch (e) {
          print('Pre-buffering gagal: $e');
          // Coba lagi setelah beberapa detik
          await Future.delayed(Duration(seconds: 2));
        }
      }
    });
  }
}
