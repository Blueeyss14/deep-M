import 'dart:ui';

import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePlaylistDialog extends StatelessWidget {
  final Map<String, String> song;
  const CreatePlaylistDialog({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final TextEditingController playlistNameController =
        TextEditingController();
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    // init
    playlistProvider.initDownloadSongProvider(context);

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      actionsPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: CustomColor.white3, width: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      content: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 8),

        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CustomColor.musicBar1.withAlpha(50),
                CustomColor.musicBar2.withAlpha(70),
                CustomColor.musicBar3.withAlpha(80),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.transparent),
                        borderRadius: BorderRadius.circular(6),
                        color: CustomColor.white1,
                      ),
                      child: TextField(
                        scrollPadding: EdgeInsets.zero,
                        controller: playlistNameController,
                        cursorColor: CustomColor.blackSheet,
                        decoration: InputDecoration(
                          hintText: "Playlist Name",
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
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
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close sheet
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: CustomColor.white1),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.white1,
                        ),
                        onPressed: () {
                          String playlistName =
                              playlistNameController.text.trim();
                          if (playlistName.isNotEmpty) {
                            playlistProvider.addToPlaylist(
                              playlistName,
                              song,
                              context,
                            );
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close bottom sheet
                          }
                        },
                        child: Text(
                          "Create",
                          style: TextStyle(color: CustomColor.blackSheet),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
