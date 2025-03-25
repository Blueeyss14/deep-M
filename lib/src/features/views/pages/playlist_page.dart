import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  Future<void> _initializeProviders() async {
    if (_isInitialized) return;

    final playlistProvider = Provider.of<PlaylistProvider>(
      context,
      listen: false,
    );
    final downloadSongProvider = Provider.of<DownloadSongProvider>(
      context,
      listen: false,
    );

    // Init providers
    playlistProvider.initDownloadSongProvider(context);
    await downloadSongProvider.loadDownloadStatus();

    // Start downloading any pending songs
    await playlistProvider.downloadAllPendingSongs(context);

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadSongProvider = Provider.of<DownloadSongProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,

      // appBar: AppBar(
      //   title: Text("Playlist Offline"),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.refresh),
      //       onPressed: () async {
      //         await _initializeProviders();
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text("Menyegarkan playlist..."),
      //             duration: Duration(seconds: 1),
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(4, (index) {
                return Container(color: Colors.green, height: 100, width: 120);
              }),
            ),
          ],
        ),
      ),

      /*
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            playlistProvider.playlists.isNotEmpty
                ? ListView.builder(
                  itemCount: playlistProvider.playlists.length,
                  itemBuilder: (context, index) {
                    String playlistName = playlistProvider.playlists.keys
                        .elementAt(index);
                    List<Map<String, String>> songs =
                        playlistProvider.playlists[playlistName]!;

                    return Card(
                      elevation: 2,
                      child: ExpansionTile(
                        title: Text(
                          playlistName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("${songs.length} lagu"),
                        children:
                            songs.asMap().entries.map((entry) {
                              int songIndex = entry.key;
                              Map<String, String> song = entry.value;

                              final videoId = song['videoId'] ?? '';
                              final downloadStatus =
                                  downloadSongProvider.downloadStatus[videoId];
                              final isPlayingThisSong =
                                  musicProvider.isPlaying &&
                                  musicProvider.currentTitle == song['title'];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    musicProvider.startPlaylist(
                                      context,
                                      playlistName,
                                      songIndex,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            child: Image.network(
                                              song['thumbnail'] ?? '',
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  width: 48,
                                                  height: 48,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.music_note),
                                                );
                                              },
                                            ),
                                          ),
                                          if (isPlayingThisSong)
                                            Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.black54,
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    song['title'] ??
                                                        'Tidak Ada',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          isPlayingThisSong
                                                              ? Theme.of(
                                                                context,
                                                              ).primaryColor
                                                              : null,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    song['channel'] ??
                                                        'Tidak Ada',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  _buildDownloadStatus(
                                                    downloadStatus,
                                                    videoId,
                                                    song['title'] ??
                                                        'Tidak Ada',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                if (downloadStatus != true)
                                                  IconButton(
                                                    onPressed: () {
                                                      downloadSongProvider
                                                          .forceRedownload(
                                                            videoId,
                                                            song['title'] ??
                                                                'Tidak Ada',
                                                            context,
                                                          );
                                                    },
                                                    icon: Icon(Icons.download),
                                                    tooltip:
                                                        'Paksa download ulang',
                                                  ),
                                                IconButton(
                                                  onPressed: () {
                                                    playlistProvider
                                                        .removeSongFromPlaylist(
                                                          playlistName,
                                                          song,
                                                        );
                                                  },
                                                  icon: Icon(Icons.delete),
                                                  tooltip:
                                                      'Hapus dari playlist',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    );
                  },
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.playlist_add, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada playlist",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Tambahkan lagu ke playlist dari halaman pencarian",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
      ),
      */
    );
  }

  Widget _buildDownloadStatus(bool? status, String videoId, String title) {
    if (status == true) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            "Terdownload",
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      );
    } else if (status == false) {
      return Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 4),
          Text("Sedang mendownload...", style: TextStyle(fontSize: 12)),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.cloud_download, size: 14, color: Colors.orange),
          SizedBox(width: 4),
          Text(
            "Menunggu download",
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ],
      );
    }
  }
}
