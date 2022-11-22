import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenBrowserView extends StatefulWidget {
  String openUrl;
  String title;
  OpenBrowserView(this.openUrl, this.title, {super.key});

  @override
  State<OpenBrowserView> createState() => _OpenBrowserViewState(this.openUrl, this.title);
}

class _OpenBrowserViewState extends State<OpenBrowserView> {
  String openUrl;
  String title;
  _OpenBrowserViewState(this.openUrl, this.title);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebView(
        initialUrl: openUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
