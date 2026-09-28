import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({Key? key, required this.url}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final _key = UniqueKey();
  int _page = 1;
  doneLoading() {
    setState(() => _page = 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Now"),
        centerTitle: true,
      ),
      body: IndexedStack(index: _page, children: <Widget>[
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
          key: _key,
          onLoadStop: (InAppWebViewController controller, WebUri? url) {
            doneLoading();
          },
        ),
        Container(
          color: Colors.white,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ]),
    );
  }
}
