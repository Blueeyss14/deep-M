import 'package:deep_m/src/features/viewmodels/download_song_provider.dart';
import 'package:deep_m/src/shared/style/custom_color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget isDownloaded(BuildContext context, String videoId) {
  final downloadSongProvider = Provider.of<DownloadSongProvider>(context);

  if (downloadSongProvider.downloadStatus[videoId] == true) {
    return Icon(Icons.check_circle, size: 16, color: Colors.green);
  } else {
    return SizedBox(
      width: 10,
      height: 10,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: CustomColor.white1,
      ),
    );
  }
}
