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
                "Add to Playlist",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
                                title: Text('Create New Playlist'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextField(
                                        controller: playlistNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Playlist Name',
                                          border: OutlineInputBorder(),
                                        ),
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
                                          child: Text("Cancel"),
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

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Ditambahkan ke playlist: $playlistName",
                                                  ),
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text("Create Playlist"),
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
                            Text(
                              "Create New Playlist",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.add_rounded),
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
                            "No playlists yet. Create your first playlist!",
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
                              title: Text(playlistName),
                              subtitle: Text(
                                "${playlistProvider.playlists[playlistName]?.length ?? 0} songs",
                                style: TextStyle(fontSize: 12),
                              ),
                              onTap: () {
                                playlistProvider.addToPlaylist(
                                  playlistName,
                                  song,
                                  context,
                                );
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Ditambahkan ke playlist: $playlistName",
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
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
