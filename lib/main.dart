import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ui/screens/screens.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.storage.request();
  if (Platform.isAndroid) {
    // await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(
    const MaterialApp(
      title: "HJH VTC Online",
      home: HomeScreen(),
    ),
  );
}
