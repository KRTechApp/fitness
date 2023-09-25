import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';
import '../utils/color_code.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/utils_methods.dart';

class WebViewAttachment extends StatefulWidget {
  final String attachment;

  const WebViewAttachment(this.attachment, {super.key});

  @override
  WebViewAttachmentState createState() => WebViewAttachmentState();
}

class WebViewAttachmentState extends State<WebViewAttachment> {
  WebViewController? _webViewController;
  late ShowProgressDialog progressDialog;
  double pageWidth = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

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
        ..loadRequest(Uri.parse(_getAttachmentUrlWebView(widget.attachment, pageWidth * 0.95)));
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    pageWidth = width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 48,
        leading: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(50),
          ),
          splashColor: ColorCode.linearProgressBar,
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.attachment),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: getFileNameFromFirebaseURL(widget.attachment).endsWith(".txt") ? ColorCode.white : ColorCode.tabBarBackground,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(35.0),
            topLeft: Radius.circular(35.0),
          ),
        ),
        child: getFileNameFromFirebaseURL(widget.attachment).endsWith(".pdf")
            ? SfPdfViewer.network(
          widget.attachment,
          key: UniqueKey(),
        )
            : Padding(
          padding: getFileNameFromFirebaseURL(widget.attachment).endsWith(".txt") ? const EdgeInsets.only(top: 25.0) : EdgeInsets.zero,
          child: _webViewController != null ? WebViewWidget(
            key: UniqueKey(),
            controller: _webViewController!,
          ) : const SizedBox(
          ),
        ),
      ),
    );
  }

  ///for get url for display attachment in web-view
  String _getAttachmentUrlWebView(String attachment, double width) {
    if (attachment.endsWith(".ppt") ||
        attachment.endsWith(".pptx") ||
        attachment.endsWith(".xls") ||
        attachment.endsWith(".doc") ||
        attachment.endsWith(".docx")) {
      //attachment = "https://drive.google.com/viewerng/viewer?embedded=true&url=" + attachment;
      attachment = "https://view.officeapps.live.com/op/view.aspx?src=$attachment";
      // attachment = "https://docs.google.com/gview?embedded=true&url=" + attachment;
    } else if (attachment.endsWith(".jpg") || attachment.endsWith(".jpeg") || attachment.endsWith(".png")) {
      String data =
          "<html><head><title>Example</title><meta name=\"viewport\"\"content=\"width=$width, initial-scale=0.65 \" /></head>";
      attachment = "$data<body><center><img width=\"$width\" src=\"$attachment\" /></center></body></html>";
      attachment = Uri.dataFromString(attachment, mimeType: 'text/html').toString();
    }
    return attachment;
  }

  ///for download file
  void downloadFile() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      var permissionRequest = await Permission.storage.request();
      if (!permissionRequest.isGranted) {
        return;
      }
    }
    // the downloads folder path
    if (context.mounted) {
      ShowProgressDialog progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);

      progressDialog.show(message: "File Downloading");

      HttpClient httpClient = HttpClient();
      File file;
      String filePath = '';
      String url = widget.attachment;
      String fileName = widget.attachment.substring(widget.attachment.lastIndexOf("/") + 1);
      Directory? tempDir;
      try {
        if (Platform.isAndroid) {
          tempDir = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          tempDir = await getApplicationDocumentsDirectory();
        }

        String dir = tempDir!.path;
        debugPrint("File Path : $dir");
        var request = await httpClient.getUrl(
          Uri.parse(url),
        );
        var response = await request.close();
        if (response.statusCode == 200) {
          var bytes = await consolidateHttpClientResponseBytes(response);
          filePath = '$dir/$fileName';
          file = File(filePath);
          await file.writeAsBytes(bytes);

          progressDialog.hide();
          if (context.mounted) {
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.file_downloaded_successfully,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 3,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          progressDialog.hide();
          debugPrint('$filePath Error code: ${response.statusCode}');
          Fluttertoast.showToast(
              msg: response.statusCode.toString(),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } catch (ex) {
        progressDialog.hide();
        debugPrint('$filePath Error code: $ex');
        Fluttertoast.showToast(
            msg: ex.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
