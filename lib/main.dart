import 'package:deep_m/src/features/viewmodels/bottombar_viemodel.dart';
import 'package:deep_m/src/features/viewmodels/music_provider.dart';
import 'package:deep_m/src/features/viewmodels/search_song_provider.dart';
import 'package:deep_m/src/features/views/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottombarViemodel()),
        ChangeNotifierProvider(create: (_) => SearchSongProvider()),
        ChangeNotifierProvider(create: (context) => MusicProvider(context)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false),
    );
  }
}
