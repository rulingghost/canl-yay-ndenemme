// Dart imports:

import 'package:flutter/material.dart';
// Package imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'login_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ZegoUIKit().initLog().then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zego Live & Audio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0C20),
        primaryColor: const Color(0xFFFF2E93),
      ),
      home: const LoginPage(),
      navigatorKey: navigatorKey,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            child!,

            /// support minimizing
            ZegoUIKitPrebuiltLiveStreamingMiniOverlayPage(
              contextQuery: () {
                return navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
    );
  }
}
