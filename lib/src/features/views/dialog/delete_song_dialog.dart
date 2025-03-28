import 'package:deep_m/src/features/viewmodels/playlist_provider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';

void deleteSongDialog(
  BuildContext context,
  String playlistName,
  Map<String, String> song,
  PlaylistProvider playlistProvider,
) {
  showDialog(
    barrierColor: const Color(0x5F000000),
    context: context,
    builder:
        (context) => AlertDialog(
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

          content: Container(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure delete this song?",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: CustomColor.white1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColor.white1,
                        ),
                        onPressed: () {
                          playlistProvider.removeSongFromPlaylist(
                            playlistName,
                            song,
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Delete",
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
  );
}
