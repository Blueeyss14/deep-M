import 'package:deep_m/src/features/views/home/home_page.dart';
import 'package:deep_m/src/provider/setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyAppProvider.setup(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ModalRoute.of(context)?.isCurrent == true) {
          FocusScope.of(context).unfocus();
        }
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(
        // title: 'DeepM - Music Player',
        // theme: ThemeData(
        //   primarySwatch: Colors.amber,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        //   // useMaterial3: true,
        //   appBarTheme: AppBarTheme(
        //     backgroundColor: Colors.amber,
        //     foregroundColor: Colors.black,
        //     centerTitle: true,
        //   ),
        // ),
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
