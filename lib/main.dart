import 'package:deep_m/src/features/views/home/home_page.dart';
import 'package:deep_m/src/provider/setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => MyAppProvider.setup(child: const MyApp()),
    ),
  );
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
        home: HomePage(),
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        builder: DevicePreview.appBuilder,
      ),
    );
  }
}
