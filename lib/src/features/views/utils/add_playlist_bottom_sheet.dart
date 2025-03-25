import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

void addPlaylistBottomSheet(BuildContext context, Map<String, String> song) {
  final TextEditingController playlistNameController = TextEditingController();

  showModalBottomSheet(
    backgroundColor: Colors.white,
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (context) {
      final playlistProvider = Provider.of<PlaylistProvider>(context);

      // Make sure providers are initialized
      playlistProvider.initDownloadSongProvider(context);

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 2 + 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.amber,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "Tambahkan ke Playlist",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song['title'] ?? 'Tidak ada judul',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song['channel'] ?? 'Tidak ada channel',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Buat Playlist Baru'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextField(
                                        controller: playlistNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Nama Playlist',
                                          hintText: 'Contoh: Favorit Saya',
                                          border: OutlineInputBorder(),
                                        ),
                                        autofocus: true,
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (value) {
                                          if (value.trim().isNotEmpty) {
                                            playlistProvider.addToPlaylist(
                                              value.trim(),
                                              song,
                                              context,
                                            );
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            Navigator.pop(
                                              context,
                                            ); // Close sheet
                                          }
                                        },
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Batal"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            String playlistName =
                                                playlistNameController.text
                                                    .trim();
                                            if (playlistName.isNotEmpty) {
                                              playlistProvider.addToPlaylist(
                                                playlistName,
                                                song,
                                                context,
                                              );
                                              Navigator.pop(
                                                context,
                                              ); // Close dialog
                                              Navigator.pop(
                                                context,
                                              ); // Close bottom sheet
                                            }
                                          },
                                          child: Text("Buat Playlist"),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        color: Colors.transparent,
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            Icon(Icons.playlist_add, size: 26),
                            const SizedBox(width: 10),
                            Text(
                              "Buat Playlist Baru",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (playlistProvider.playlists.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            "Belum ada playlist. Buat playlist pertama Anda!",
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: playlistProvider.playlists.keys.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            String playlistName = playlistProvider
                                .playlists
                                .keys
                                .elementAt(index);
                            return ListTile(
                              leading: Icon(Icons.playlist_play, size: 30),
                              title: Text(playlistName),
                              subtitle: Text(
                                "${playlistProvider.playlists[playlistName]?.length ?? 0} lagu",
                                style: TextStyle(fontSize: 12),
                              ),
                              onTap: () {
                                playlistProvider.addToPlaylist(
                                  playlistName,
                                  song,
                                  context,
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
