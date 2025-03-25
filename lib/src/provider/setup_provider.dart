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

        ChangeNotifierProxyProvider<MusicProvider, BufferingAudio>(
          create: (context) => BufferingAudio(context),
          update: (context, musicProvider, bufferingAudio) {
            return bufferingAudio ?? BufferingAudio(context);
          },
        ),

        ChangeNotifierProxyProvider<MusicProvider, DownloadSongProvider>(
          create: (context) => DownloadSongProvider(),
          update: (context, musicProvider, downloadProvider) {
            final provider = downloadProvider ?? DownloadSongProvider();
            provider.musicProvider = musicProvider;
            return provider;
          },
        ),

        ChangeNotifierProxyProvider<DownloadSongProvider, PlaylistProvider>(
          create: (context) => PlaylistProvider(),
          update: (context, downloadProvider, playlistProvider) {
            final provider = playlistProvider ?? PlaylistProvider();
            provider.downloadSongProvider = downloadProvider;
            Future.microtask(() {
              provider.loadPlaylists();
            });
            return provider;
          },
        ),
      ],
      child: child,
    );
  }
}
