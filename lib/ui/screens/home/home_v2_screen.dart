// // ignore_for_file: depend_on_referenced_packages, unused_import

// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:saver_gallery/saver_gallery.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// // #docregion platform_imports
// // Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// // Import for iOS features.
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// import '../../widgets/widgets.dart';
// import 'widgets/widgets.dart';

// // #enddocregion platform_imports
// class WebViewExample extends StatefulWidget {
//   const WebViewExample({super.key});

//   @override
//   State<WebViewExample> createState() => _WebViewExampleState();
// }

// class _WebViewExampleState extends State<WebViewExample> {
//   late final WebViewController _controller;

//   bool isDownloading = false;

//   @override
//   void initState() {
//     super.initState();

//     // #docregion platform_features
//     late final PlatformWebViewControllerCreationParams params;
//     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
//       params = WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     } else {
//       params = const PlatformWebViewControllerCreationParams();
//     }

//     final WebViewController controller =
//         WebViewController.fromPlatformCreationParams(params);

//     // #enddocregion platform_features

//     controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             debugPrint('WebView is loading (progress : $progress%)');
//           },
//           onPageStarted: (String url) {
//             debugPrint('Page started loading: $url');
//           },
//           onPageFinished: (String url) {
//             debugPrint('Page finished loading: $url');
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('''
// Page resource error:
//   code: ${error.errorCode}
//   description: ${error.description}
//   errorType: ${error.errorType}
//   isForMainFrame: ${error.isForMainFrame}
//           ''');
//           },
//           onNavigationRequest: (NavigationRequest request) async {
//             if (request.url.startsWith('https://cdn.nexusclips.com/newClips')) {
//               debugPrint('blocking navigation to ${request.url}');
//               _downloadFile(request.url,
//                   DateTime.now().millisecondsSinceEpoch.toString());
//               return NavigationDecision.prevent;
//             }
//             debugPrint('allowing navigation to ${request.url}');
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(message.message)),
//           );
//         },
//       )
//       ..loadRequest(
//           Uri.parse('https://nexusclips.com/beta/authentication/login.php'));

//     // #docregion platform_features
//     if (controller.platform is AndroidWebViewController) {
//       AndroidWebViewController.enableDebugging(true);
//       (controller.platform as AndroidWebViewController)
//           .setMediaPlaybackRequiresUserGesture(false);
//     }
//     // #enddocregion platform_features

//     _controller = controller;
//     // #enddocregion webview_controller
//   }

//   // #docregion webview_widget
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//           child: Stack(
//         children: [
//           WebViewWidget(
//             controller: _controller,
//           ),
//           isDownloading
//               ? DownloadViewWidget(
//                   progressValue: _progressPercentValue,
//                   percentValue: _progressValue,
//                 )
//               : Container()
//         ],
//       )),
//     );
//   }

//   // #enddocregion webview_widget
//   _downloadFile(String path, String fileName) async {
//     try {
//       if (isDownloading) {
//         return;
//       }
//       await [Permission.storage, Permission.manageExternalStorage].request();
//       var appPath = Platform.isAndroid
//           ? (await getExternalStorageDirectory() ??
//               await getApplicationSupportDirectory())
//           : await getApplicationDocumentsDirectory();

//       String directoryPath = "${appPath.path}/nexusclips";

//       await Directory(directoryPath).create(recursive: true);
//       String filePath = '$directoryPath/${DateTime.now()}.mp4';
//       if (!mounted) return;
//       setState(() {
//         isDownloading = true;
//       });
//       await Dio().download(path, filePath,
//           onReceiveProgress: (sentBytes, totalBytes) {
//         _progress(sentBytes, totalBytes);
//       });

//       if (!mounted) return;
//       setState(() {
//         isDownloading = false;
//         _progressValue = 0.0;
//         _progressPercentValue = 0;
//       });
//       _onShare(filePath);
//       await SaverGallery.saveFile(filePath);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         isDownloading = false;
//         _progressValue = 0.0;
//         _progressPercentValue = 0;
//       });
//       SnackBarWidget().showError(error: e.toString());
//     }
//   }

//   double _progressValue = 0.0;
//   int _progressPercentValue = 0;

//   void _progress(int sentBytes, int totalBytes) {
//     double __progressValue =
//         Util.remap(sentBytes.toDouble(), 0, totalBytes.toDouble(), 0, 1);

//     __progressValue = double.parse(__progressValue.toStringAsFixed(2));

//     if (__progressValue != _progressValue) if (!mounted) return;
//     setState(() {
//       _progressValue = __progressValue;
//       _progressPercentValue = (_progressValue * 100.0).toInt();
//     });
//   }

//   _onShare(String path) async {
//     final box = context.findRenderObject() as RenderBox?;
//     await Share.shareXFiles(
//       [XFile(path)],
//       subject: '',
//       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
//     );
//   }
// }

// class Util {
//   static double remap(
//       double value,
//       double originalMinValue,
//       double originalMaxValue,
//       double translatedMinValue,
//       double translatedMaxValue) {
//     if (originalMaxValue - originalMinValue == 0) return 0;

//     return (value - originalMinValue) /
//             (originalMaxValue - originalMinValue) *
//             (translatedMaxValue - translatedMinValue) +
//         translatedMinValue;
//   }
// }
