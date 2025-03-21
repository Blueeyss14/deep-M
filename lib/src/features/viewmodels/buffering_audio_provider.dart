import 'dart:async';

import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BufferingAudio extends ChangeNotifier {
  late MusicProvider musicProvider;

  BufferingAudio(BuildContext context) {
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
  }

  // Kelas ini sekarang kosong karena fungsionalitasnya sudah dipindahkan ke MusicProvider
}
