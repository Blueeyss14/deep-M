import 'dart:async';
import 'dart:io';

import 'package:deep_m/src/features/viewmodels/buffering_audio_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Enum untuk mode looping
enum RepeatMode { none, playlist, single }

class MusicProvider extends ChangeNotifier {
  String currentTitle = '';
  String currentThumbnail = '';
  String currentChannel = '';
  String currentDescription = '';
  String currentVideoId = '';
  bool isBuffering = false;
  bool isPlaying = false;
  bool isPlayingOffline = false;

  String currentPlaylistName = '';
  List<Map<String, String>> currentPlaylistSongs = [];
  int currentSongIndex = -1;

  // loooop
  RepeatMode repeatMode = RepeatMode.none;

  final AudioPlayer audioPlayer = AudioPlayer();
  final YoutubeExplode youtube = YoutubeExplode();

  final Map<String, String> _audioStreamUrl = {};

  PlaylistProvider? _playlistProvider;

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

  Future<bool> isAudioDownloaded(String videoId) async {
    try {
      final file = await getAudioFile(videoId);
      final exists = await file.exists();

      if (!exists) return false;

      final fileSize = await file.length();
      return fileSize > 10 * 1024; // Minimal 10KB
    } catch (e) {
      print("Error memeriksa file audio: $e");
      return false;
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('youtube.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print("Error memeriksa koneksi: $e");
      return false;
    }
  }

  //Initialization of Bufering Audio
  BufferingAudio? bufferingAudio;

  MusicProvider(BuildContext context) {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying = state.playing;
      if (state.playing && isBuffering) {
        isBuffering = false;
        notifyListeners();
      }
    });

    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onSongCompleted(context);
      }
    });

    // Set mode first loop
    audioPlayer.setLoopMode(LoopMode.off);
  }

  // Inisialisasi playlist provider
  void initPlaylistProvider(BuildContext context) {
    _playlistProvider ??= Provider.of<PlaylistProvider>(context, listen: false);
  }

  void initBufferingAudio(BuildContext context) {
    bufferingAudio ??= Provider.of<BufferingAudio>(context, listen: false);
  }

  // Change the loop
  void toggleLoopMode() {
    switch (repeatMode) {
      case RepeatMode.none:
        repeatMode = RepeatMode.playlist;
        audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.playlist:
        repeatMode = RepeatMode.single;
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.single:
        repeatMode = RepeatMode.none;
        audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    notifyListeners();
  }

  // Handler song
  void _onSongCompleted(BuildContext context) {
    if (repeatMode == RepeatMode.playlist && currentPlaylistSongs.isNotEmpty) {
      _playNextSong(context);
    } else if (repeatMode == RepeatMode.none) {
      isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> _playNextSong(BuildContext context) async {
    if (currentPlaylistSongs.isEmpty || currentSongIndex < 0) return;

    final nextIndex = (currentSongIndex + 1) % currentPlaylistSongs.length;
    final nextSong = currentPlaylistSongs[nextIndex];

    await playAudio(
      context,
      nextSong['videoId'] ?? '',
      nextSong['title'] ?? 'Tidak Ada',
      nextSong['thumbnail'] ?? '',
      nextSong['channel'] ?? 'Tidak Ada',
      nextSong['description'] ?? 'Tidak Ada',
      playlistName: currentPlaylistName,
      playlistIndex: nextIndex,
    );
  }

  Future<void> playPreviousSong(BuildContext context) async {
    if (currentPlaylistSongs.isEmpty || currentSongIndex < 0) return;

    if (audioPlayer.position.inSeconds > 3) {
      audioPlayer.seek(Duration.zero);
      return;
    }

    final prevIndex =
        currentSongIndex > 0
            ? currentSongIndex - 1
            : currentPlaylistSongs.length - 1;
    final prevSong = currentPlaylistSongs[prevIndex];

    await playAudio(
      context,
      prevSong['videoId'] ?? '',
      prevSong['title'] ?? 'Tidak Ada',
      prevSong['thumbnail'] ?? '',
      prevSong['channel'] ?? 'Tidak Ada',
      prevSong['description'] ?? 'Tidak Ada',
      playlistName: currentPlaylistName,
      playlistIndex: prevIndex,
    );
  }

  Future<void> playNextSong(BuildContext context) async {
    await _playNextSong(context);
  }

  Future<void> startPlaylist(
    BuildContext context,
    String playlistName,
    int songIndex,
  ) async {
    initPlaylistProvider(context);

    if (_playlistProvider == null ||
        !_playlistProvider!.playlists.containsKey(playlistName)) {
      return;
    }

    final songs = _playlistProvider!.playlists[playlistName]!;
    if (songIndex >= songs.length) return;

    currentPlaylistName = playlistName;
    currentPlaylistSongs = List.from(songs);
    currentSongIndex = songIndex;

    final song = songs[songIndex];
    await playAudio(
      context,
      song['videoId'] ?? '',
      song['title'] ?? 'Tidak Ada',
      song['thumbnail'] ?? '',
      song['channel'] ?? 'Tidak Ada',
      song['description'] ?? 'Tidak Ada',
      playlistName: playlistName,
      playlistIndex: songIndex,
    );
  }

  Future<void> playAudio(
    BuildContext context,
    String videoId,
    String title,
    String thumbnail,
    String channel,
    String description, {
    String playlistName = '',
    int playlistIndex = -1,
  }) async {
    if (videoId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID Video kosong')));
      return;
    }

    initBufferingAudio(context);

    if (playlistName.isNotEmpty && playlistIndex >= 0) {
      initPlaylistProvider(context);

      if (_playlistProvider != null &&
          _playlistProvider!.playlists.containsKey(playlistName)) {
        currentPlaylistName = playlistName;
        currentPlaylistSongs = List.from(
          _playlistProvider!.playlists[playlistName]!,
        );
        currentSongIndex = playlistIndex;
      }
    }

    isBuffering = true;
    currentTitle = title;
    currentThumbnail = thumbnail;
    currentChannel = channel;
    currentDescription = description;
    currentVideoId = videoId;
    notifyListeners();

    try {
      final file = await getAudioFile(videoId);
      final isDownloaded = await isAudioDownloaded(videoId);

      if (isDownloaded) {
        try {
          await audioPlayer.setFilePath(file.path);
          isPlayingOffline = true;
        } catch (e) {
          print("Error playing song: $e");
          isPlayingOffline = false;

          final hasInternet = await hasInternetConnection();
          if (!hasInternet) {
            throw Exception('No Internet Connection');
          }

          await _playFromStream(videoId);
        }
      } else {
        final hasInternet = await hasInternetConnection();
        if (!hasInternet) {
          throw Exception('No internet connection');
        }

        isPlayingOffline = false;
        await _playFromStream(videoId);
      }

      await audioPlayer.seek(Duration.zero);
      bufferingAudio?.startPreBuffering(videoId);
      await audioPlayer.play();

      if (repeatMode == RepeatMode.single) {
        audioPlayer.setLoopMode(LoopMode.one);
      } else {
        audioPlayer.setLoopMode(LoopMode.off);
      }

      isPlaying = true;
      isBuffering = false;
      notifyListeners();

      audioPlayer.positionStream.listen((position) {
        final playedSegments = bufferingAudio?.playedSegments;
        if (playedSegments != null) {
          if (playedSegments.containsKey(videoId)) {
            playedSegments[videoId]!.add(position);
          } else {
            playedSegments[videoId] = {position};
          }
        }
      });
    } catch (e) {
      isBuffering = false;
      notifyListeners();

      Future.microtask(() {
        try {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal memutar audio: ${e.toString()}'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } catch (uiError) {
          debugPrint('Error UI: $uiError');
        }
      });

      audioPlayer.stop();
    }
  }

  Future<void> _playFromStream(String videoId) async {
    String? audioUrl = _audioStreamUrl[videoId];

    if (audioUrl == null) {
      try {
        print("Mencoba stream dari YouTube untuk: $videoId");
        var manifest = await youtube.videos.streamsClient.getManifest(videoId);
        var audioStreams = manifest.audioOnly.toList();
        audioStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));

        var audioStream = audioStreams.isNotEmpty ? audioStreams[0] : null;

        if (audioStream == null) {
          throw Exception('Audio tidak ditemukan');
        }

        audioUrl = audioStream.url.toString();
        _audioStreamUrl[videoId] = audioUrl;
        print("Streaming dari: ${audioStream.bitrate.kiloBitsPerSecond} kbps");
      } catch (e) {
        if (e.toString().contains('Socket') ||
            e.toString().contains('Connection')) {
          throw Exception(
            'Tidak ada koneksi internet. Download lagu ini dulu.',
          );
        }
        rethrow;
      }
    }

    await audioPlayer.setUrl(audioUrl);
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    isPlaying = false;
    notifyListeners();
  }

  bool get isPlayingFromPlaylist {
    return currentPlaylistName.isNotEmpty &&
        currentPlaylistSongs.isNotEmpty &&
        currentSongIndex >= 0;
  }
}
