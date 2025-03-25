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
      body:
          playlistProvider.playlists.isEmpty
              ? _buildEmptyPlaylistView()
              : _buildPlaylistGrid(playlistProvider),
    );
  }

  Widget _buildEmptyPlaylistView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Belum ada playlist",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Tambahkan lagu ke playlist dari halaman pencarian",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(PlaylistProvider playlistProvider) {
    final List<String> playlistNames = playlistProvider.playlists.keys.toList();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: playlistNames.length,
        itemBuilder: (context, index) {
          final playlistName = playlistNames[index];
          final songCount = playlistProvider.playlists[playlistName]!.length;

          return GestureDetector(
            onTap: () {
              _navigateToPlaylistSongs(playlistName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 40,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(height: 8),
                  Text(
                    playlistName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "$songCount lagu",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToPlaylistSongs(String playlistName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistSongsPage(playlistName: playlistName),
      ),
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

// Page to display songs in a playlist
class PlaylistSongsPage extends StatelessWidget {
  final String playlistName;

  const PlaylistSongsPage({super.key, required this.playlistName});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadSongProvider = Provider.of<DownloadSongProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final songs = playlistProvider.playlists[playlistName] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(playlistName), elevation: 0),
      body:
          songs.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Playlist ini kosong",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: songs.length,
                itemBuilder: (context, songIndex) {
                  final song = songs[songIndex];
                  final videoId = song['videoId'] ?? '';
                  final downloadStatus =
                      downloadSongProvider.downloadStatus[videoId];
                  final isPlayingThisSong =
                      musicProvider.isPlaying &&
                      musicProvider.currentTitle == song['title'];

                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: GestureDetector(
                      onTap: () {
                        musicProvider.startPlaylist(
                          context,
                          playlistName,
                          songIndex,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    song['thumbnail'] ?? '',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.music_note),
                                      );
                                    },
                                  ),
                                ),
                                if (isPlayingThisSong)
                                  Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.black54,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song['title'] ?? 'Tidak Ada',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isPlayingThisSong
                                              ? Theme.of(context).primaryColor
                                              : null,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    song['channel'] ?? 'Tidak Ada',
                                    style: TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildDownloadStatus(
                                    context,
                                    downloadStatus,
                                    videoId,
                                    song['title'] ?? 'Tidak Ada',
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                playlistProvider.removeSongFromPlaylist(
                                  playlistName,
                                  song,
                                );
                              },
                              icon: Icon(Icons.delete),
                              tooltip: 'Hapus dari playlist',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildDownloadStatus(
    BuildContext context,
    bool? status,
    String videoId,
    String title,
  ) {
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
