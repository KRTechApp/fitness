// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class ShowProgressDialog {
  /// Value to indicate if dialog is open
  bool isOpen = false;

  /// String to set the message on the dialog
  String? _message = '';

  /// StateSetter to make available the function to update message text inside an opened dialog

  /// Context to render the dialog
  BuildContext? context;

  /// Bool value to indicate the barrierDismisable of the dialog
  final bool? barrierDismissible;

  /// Duration for animation
  final Duration? duration;

  /// Widget indicator when custom is selected
  // Widget? _customLoadingIndicator;

  /// Color value to set the indicator color
  Color? _indicatorColor;

  ShowProgressDialog(
      {this.context, this.barrierDismissible = false, this.duration = const Duration(milliseconds: 1000)});

  void show(
      {String message = "Loading",
        double height = 100,
        double width = 120,
        double radius = 5.0,
        double elevation = 5.0,
        Color backgroundColor = Colors.white,
        Color? indicatorColor,
        bool horizontal = false,
        double separation = 10.0,
        TextStyle textStyle = const TextStyle(fontSize: 14),
        bool hideText = false,
        Widget? loadingIndicator}) {
    if(isOpen){
      return;
    }
    assert(context != null, 'Context must not be null');
    _indicatorColor = indicatorColor ?? Colors.blue[600];
    isOpen = true;
    _message = message;

    double height = 100;
    double width = 120;
    bool horizontal = false;
    double separation = 10.0;
    TextStyle textStyle = const TextStyle(fontSize: 14);
    bool hideText = false;

    showDialog(
        context: context!,
        barrierDismissible: barrierDismissible!,
        useSafeArea: true,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => Future.value(barrierDismissible!),
            child: Dialog(
              backgroundColor: Colors.black45,
              insetPadding: const EdgeInsets.all(0.0),
              child: StatefulBuilder(builder: (BuildContext _, StateSetter setState) {
                // _setState = setState;
                return Center(
                  child: SizedBox(
                      height: height,
                      width: width,
                      /*decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius:
                            BorderRadius.all(Radius.circular(radius))),*/
                      child: /*!horizontal
                            ? */
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: _getChildren(_message, horizontal, separation, textStyle, hideText),
                      ) /* : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: _getChildren(_message, horizontal,
                              separation, textStyle, hideText),
                        ),*/
                  ),
                );
              }),
            ),
          );
        });
  }

  void hide() {
    if (isOpen) {
      // Navigator.of(context!).pop();
      Navigator.of(context!, rootNavigator: true).pop(context);
      isOpen = false;
    }
  }

  static List<Widget> _getChildren(
      String? message, bool horizontal, double separation, TextStyle textStyle, bool hideText) {
    return [
      /*RotateIcon(
        duration: Duration(milliseconds: 1000),
        child: Icon(
          Icons.ac_unit_rounded,
          color: Colors.blue[600],
          size: 40.0,
        ),
      ),*/
      Image.asset('assets/images/gym_progress_logo.gif', width: 80, height: 80),
      !horizontal
          ? SizedBox(
        height: separation,
      )
          : SizedBox(
        width: separation,
      ),

      /*
      if (hideText)
      Text(
        message!,
        style: textStyle,
      )*/
    ];
  }

  static Widget showProgressDialog(
      {@required String? message,
        double height = 100,
        double width = 120,
        double radius = 5.0,
        double elevation = 5.0,
        Color backgroundColor = Colors.white,
        Color? indicatorColor,
        bool horizontal = false,
        double separation = 10.0,
        TextStyle textStyle = const TextStyle(fontSize: 14),
        bool hideText = false,
        Widget? loadingIndicator}) {
    return Dialog(
      child: Center(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.all(Radius.circular(radius))),
          child: !horizontal
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: _getChildren(message, horizontal, separation, textStyle, hideText),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: _getChildren(message, horizontal, separation, textStyle, hideText),
          ),
        ),
      ),
    );
  }
}
