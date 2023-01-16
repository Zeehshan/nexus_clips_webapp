import 'dart:async';
import 'dart:io';
// import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/widgets.dart';
import 'widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();
  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  // late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  InAppWebViewController? _webViewController;
  final CookieManager _cookieManager = CookieManager.instance();

  String url = "https://nexusclips.com/beta/authentication/login.php";
  double progress = 0;

  bool isDownloading = false;

  @override
  initState() {
    super.initState();
  }

  // Future<void> initDeepLinks() async {
  //   _appLinks = AppLinks();

  //   // Check initial link if app was in cold state (terminated)
  //   final appLink = await _appLinks.getInitialAppLink();
  //   if (appLink != null) {
  //     print('getInitialAppLink after login: $appLink');
  //     openAppLink(appLink);
  //   }

  //   // Handle link when app is in warm state (front or background)
  //   _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
  //     print('onAppLink: $uri');
  //     openAppLink(uri);
  //   });
  // }

  // void openAppLink(Uri uri) async {
  //   await Future.delayed(const Duration(seconds: 2));
  //   await _downloadFile(
  //       uri.toString(), DateTime.now().millisecondsSinceEpoch.toString());
  // }

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
                    // useOnLoadResource: false,
                  ),
                  android: AndroidInAppWebViewOptions(
                    forceDark: AndroidForceDark.FORCE_DARK_AUTO,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) async {
                  _webViewController = controller;
                  // _webViewController!.loadUrl(
                  //     urlRequest: URLRequest(
                  //         url: Uri.parse(
                  //             'https://nexusclips.com/beta/editor/?&m=edit&moments=d95418d88cef4e8bacaef0bca76a53ce&os=0&co=25&cg=REACTIONS&preset=15071')));
                  // initDeepLinks();
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
                onLoadResource: (controller, resource) {
                  print(resource.url);
                },
                onDownloadStartRequest:
                    (controller, DownloadStartRequest url) async {
                  List<Cookie> cookies =
                      await _cookieManager.getCookies(url: url.url);

                  await _downloadFile(
                      url.url.toString(),
                      url.suggestedFilename ??
                          DateTime.now().millisecondsSinceEpoch.toString());
                },
              ),
              isDownloading
                  ? DownloadViewWidget(
                      progressValue: _progressPercentValue,
                      percentValue: _progressValue,
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }

  _downloadFile(String path, String fileName) async {
    try {
      await [Permission.storage, Permission.manageExternalStorage].request();
      var appPath = Platform.isAndroid
          ? (await getExternalStorageDirectory() ??
              await getApplicationSupportDirectory())
          : await getApplicationDocumentsDirectory();

      String directoryPath = "${appPath.path}/nexusclips";

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

      if (!mounted) return;
      setState(() {
        isDownloading = false;
        _progressValue = 0.0;
        _progressPercentValue = 0;
      });
      _onShare(filePath);
      await SaverGallery.saveFile(filePath);
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

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}
