import 'package:crossfit_gym_trainer/Utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/gym_style.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminRequestScreen extends StatefulWidget {
  const AdminRequestScreen({super.key});

  @override
  State<AdminRequestScreen> createState() => _AdminRequestScreenState();
}

class _AdminRequestScreenState extends State<AdminRequestScreen> {
  WebViewController? _webViewController;
  late ShowProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    progressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(ColorCode.tabBarBackground)
        ..enableZoom(true)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint("progress : $progress");
              if (progress < 80) {
                if (!progressDialog.isOpen) {
                  progressDialog.show();
                }
              } else if (progressDialog.isOpen) {
                progressDialog.hide();
              }
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {
              /*_webViewController?.runJavaScript(
                  "javascript:(function() {document.querySelector('[class=\"ndfHFb-c4YZDc-Wrql6b\"]').remove();},)()");*/
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint("onWebResourceError ${error.errorCode}");
              debugPrint("onWebResourceError ${error.description}");
              Fluttertoast.showToast(
                  msg: getErrorMessage(errorType: error.description),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('https://zc.vg/eOnQ7'));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height  = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/appLogo/gym_logo.png',
                    height: 135, width: 135),
              ),
              const SizedBox(
                height: 30,
              ),
              Text('Crossfit – Your Personal Trainer App',textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: getFontSize(24),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: ColorCode.mainColor)),
              const SizedBox(
                height: 20,
              ),
              _webViewController != null
                  ? SizedBox(
                height: height * 0.48,
                    child: WebViewWidget(
                        controller: _webViewController!,
                      ),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
