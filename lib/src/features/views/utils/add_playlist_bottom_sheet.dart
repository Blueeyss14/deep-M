import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

void addPlaylistBottomSheet(BuildContext context, Map<String, String> song) {
  final TextEditingController playlistNameController = TextEditingController();

  showModalBottomSheet(
    clipBehavior: Clip.antiAlias,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 2 + 100,
        ),
        child: Column(
          children: [
            AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: Text(
                "Add Playlist",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: playlistNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Playlist',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final playlistProvider = Provider.of<PlaylistProvider>(
                  context,
                  listen: false,
                );
                String playlistName = playlistNameController.text;
                if (playlistName.isNotEmpty) {
                  playlistProvider.addToPlaylist(playlistName, song);
                  Navigator.pop(context);
                }
              },
              child: Text("Add to Playlist"),
            ),
          ],
        ),
      );
    },
  );
}
