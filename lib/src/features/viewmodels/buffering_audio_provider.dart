import 'dart:async';

import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BufferingAudio extends ChangeNotifier {
  late MusicProvider musicProvider;
  final Map<String, Duration> preBufferPositions = {};
  final Map<String, Set<Duration>> playedSegments = {};

  BufferingAudio(BuildContext context) {
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
  }

  Timer? _preBufferTimer;

  void startPreBuffering(String videoId) {
    bool isPlaying = musicProvider.isPlaying;
    bool isBuffering = musicProvider.isBuffering;

    // Hentikan timer sebelumnya jika ada
    _preBufferTimer?.cancel();

    // Mulai pre-buffering setiap 15 detik
    _preBufferTimer = Timer.periodic(const Duration(seconds: 15), (
      timer,
    ) async {
      if (isPlaying && !isBuffering) {
        var currentPosition = musicProvider.audioPlayer.position;
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
