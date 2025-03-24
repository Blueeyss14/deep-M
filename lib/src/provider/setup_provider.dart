import 'package:deep_m/src/features/viewmodels/bottombar_viemodel.dart';
import 'package:deep_m/src/features/viewmodels/buffering_audio_provider.dart';
import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyAppProvider {
  static MultiProvider setup({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottombarViemodel()),
        ChangeNotifierProvider(create: (_) => SearchSongProvider()),
        ChangeNotifierProvider(create: (context) => MusicProvider(context)),
        ChangeNotifierProvider(create: (context) => BufferingAudio(context)),
        ChangeNotifierProvider(create: (context) => DownloadSongProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ],
      child: child,
    );
  }
}
