import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';

void addPlaylistBottomSheet(BuildContext context, Map<String, String> song) {
  final TextEditingController playlistNameController = TextEditingController();

  showModalBottomSheet(
    useRootNavigator: false,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    isScrollControlled: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (context) {
      final playlistProvider = Provider.of<PlaylistProvider>(context);

      // init
      playlistProvider.initDownloadSongProvider(context);

      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 2 + 100,
        ),
        decoration: BoxDecoration(color: const Color(0xFF12161A)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///Dialog dragger yang putih putih itu
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: CustomColor.white3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: song['thumbnail'] ?? '',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song['title'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: CustomColor.white1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song['channel'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: CustomColor.white2,
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
            Divider(thickness: 0.2, color: CustomColor.musicBar3),
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
                            Icon(
                              Icons.add_circle_outline,
                              size: 26,
                              color: CustomColor.white2,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Create New Playlist",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: CustomColor.white2,
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
                            "No playlist. Create your first playlist!",
                            style: TextStyle(color: CustomColor.white3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Playlist",
                              style: TextStyle(
                                color: CustomColor.white2,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount:
                                    playlistProvider.playlists.keys.length,
                                itemBuilder: (context, index) {
                                  String playlistName = playlistProvider
                                      .playlists
                                      .keys
                                      .elementAt(index);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        playlistProvider.addToPlaylist(
                                          playlistName,
                                          song,
                                          context,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 15,
                                        ),
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.playlist_play,
                                              color: CustomColor.white2,
                                              size: 30,
                                            ),
                                            const SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  playlistName,
                                                  style: TextStyle(
                                                    color: CustomColor.white2,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  "${playlistProvider.playlists[playlistName]?.length ?? 0} songs",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: CustomColor.white3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                  // ListTile(
                                  //   minVerticalPadding: 0,
                                  //   contentPadding: EdgeInsets.zero,
                                  //   leading: Icon(
                                  //     Icons.playlist_play,
                                  //     color: CustomColor.white2,
                                  //     size: 30,
                                  //   ),
                                  //   title: Text(
                                  //     playlistName,
                                  //     style: TextStyle(
                                  //       color: CustomColor.white2,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  //   subtitle: Text(
                                  //     "${playlistProvider.playlists[playlistName]?.length ?? 0} songs",
                                  //     style: TextStyle(
                                  //       fontSize: 12,
                                  //       color: CustomColor.white3,
                                  //     ),
                                  //   ),

                                  // );
                                },
                              ),
                            ),
                          ],
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
