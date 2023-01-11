import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InAppWebViewController? _webViewController;
  final CookieManager _cookieManager = CookieManager.instance();

  String url = "https://nexusclips.com/beta/authentication/login.php";
  double progress = 0;

  bool isDownloading = false;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      home: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(url)),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    useShouldOverrideUrlLoading: true,
                    useOnDownloadStart: true,
                    // userAgent:
                    //     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36",
                    clearCache: false,
                    cacheEnabled: true,
                    //useOnLoadResource: true,
                  ),
                  android: AndroidInAppWebViewOptions(
                    forceDark: AndroidForceDark.FORCE_DARK_AUTO,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async {
                  return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED);
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                androidOnReceivedLoginRequest:
                    (controller, LoginRequest loginRequest) {
                  print("how you are calling");
                  print(loginRequest.args);
                },
                onDownloadStartRequest:
                    (controller, DownloadStartRequest url) async {
                  List<Cookie> cookies =
                      await _cookieManager.getCookies(url: url.url);

                  await _downloadFile(
                      url.url.toString(),
                      url.suggestedFilename ??
                          DateTime.now().millisecondsSinceEpoch.toString());

                  // final taskId = await FlutterDownloader.enqueue(
                  //   url: url.url.toString(),
                  //   savedDir: appPath!.path,
                  //   // headers: {
                  //   //   "Cookie":
                  //   //       "${cookies[0].name}=${cookies[0].value}; ${cookies[1].name}=${cookies[1].value}"
                  //   // },
                  //   showNotification: true,
                  //   openFileFromNotification:
                  //       true, // click on notification to open downloaded file (for Android)
                  // );
                },
              ),
              if (isDownloading)
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(100)),
                    child: Center(
                      child: CircularPercentIndicator(
                        radius: 40.0,
                        lineWidth: 5.0,
                        percent: _progressValue,
                        progressColor: Colors.green,
                        center: SizedBox(
                          width: 50,
                          child: Center(
                            child: Text(
                              '$_progressPercentValue %',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  _downloadFile(String path, String fileName) async {
    try {
      await (Platform.isAndroid ? Permission.storage : Permission.photosAddOnly)
          .request()
          .isGranted;
      var appPath = await getTemporaryDirectory();

      String directoryPath = appPath.path + "/nexusclips";

      await Directory(directoryPath).create(recursive: true);
      String filePath = '$directoryPath/${DateTime.now()}.mp4';
      if (!mounted) return;
      setState(() {
        isDownloading = true;
      });
      await Dio().download(path, filePath,
          onReceiveProgress: (sentBytes, totalBytes) {
        _progress(sentBytes, totalBytes);
      });
      await SaverGallery.saveFile(filePath);
      if (!mounted) return;
      setState(() {
        isDownloading = false;
        _progressValue = 0.0;
        _progressPercentValue = 0;
      });
      _onShare(filePath);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isDownloading = false;
        _progressValue = 0.0;
        _progressPercentValue = 0;
      });
      SnackBarWidget().showError(error: e.toString());
    }
  }

  double _progressValue = 0.0;
  int _progressPercentValue = 0;

  void _progress(int sentBytes, int totalBytes) {
    double __progressValue =
        Util.remap(sentBytes.toDouble(), 0, totalBytes.toDouble(), 0, 1);

    __progressValue = double.parse(__progressValue.toStringAsFixed(2));

    if (__progressValue != _progressValue) if (!mounted) return;
    setState(() {
      _progressValue = __progressValue;
      _progressPercentValue = (_progressValue * 100.0).toInt();
    });
  }

  _onShare(String path) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareXFiles(
      [XFile(path)],
      subject: '',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}

class Util {
  static double remap(
      double value,
      double originalMinValue,
      double originalMaxValue,
      double translatedMinValue,
      double translatedMaxValue) {
    if (originalMaxValue - originalMinValue == 0) return 0;

    return (value - originalMinValue) /
            (originalMaxValue - originalMinValue) *
            (translatedMaxValue - translatedMinValue) +
        translatedMinValue;
  }
}
