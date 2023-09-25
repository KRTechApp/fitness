import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/services.dart';

class StaticData {
  static bool showPaymentGateway = true;  // Temporary hide all payment gateway related screen for appstore show = true and Hide = false
  static bool canEditField = true;  // True for Package and False for Release on play store
  static bool codeExist = true; // True for show payment gateway code false for hide payment gateway code
  static const version = "1.0";
  static const appName = "CrossFit";
  static const fileName = "GYM_Trainer";
  static String currentDateFormat = "dd/MM/yyyy";
  static String currentCurrency = "\$";
  static String currentTrainerCurrency = "\$";
  static String currentCurrencyName = "USD";
  static String currentTrainerCurrencyName = "USD";
  static String currentCurrencyCountry = "US";
  static String currentTrainerCurrencyCountry = "US";
  static String defaultPlaceHolder = "assets/images/ic_App_Logo.png";
  static bool adminNotification = true;
  static bool adminEmailNotification = true;
  static bool adminVirtualClass = true;
  static String weight = 'kg';
  static String height = 'cm';
  static String chest = 'cm';
  static String waist = 'cm';
  static String thigh = 'cm';
  static String arms = 'cm';
  static String orderBy = "new_first";
  static String planBy = "all";
  static String invoicePrefix = 'INV';
  static String memberIdPrefix = 'MBR';
  static String firebaseKey =
      "AAAAT7DgcbA:APA91bHtv03lX5_cqg8FaI9xLT4hix9FZQF_5bCJDrjaJ5FmR2NvE10Y8ncjOebZVIBrcvFy3a2q8mJWG11gsf2NzUozJpseZC5Lw6Z3OFvORDs3WDwCaRiQsTLPOkXlPP3LsLW9XHfs";
  static String paymentType = paymentTypeCash;
  static String paymentTrainerType = paymentTypeCash;

  //Admin Payment keys
  static String stripeMerchantKey = "merchant.crossfit.personaltrainer.gymtrainer.fitness";
  static String stripeSecretKey =
      "sk_test_51L0j3XSCQIDASK9Q29xDwOCnIQb5ZIZJvJkSiXkDzonVHjMHS3NABec0aoWgDcpjIfn7XRVK4WawZUJXmgHENkPQ00ODRGLtuS";
  static String stripePublishableKey =
      "pk_test_51L0j3XSCQIDASK9QmTpzX1BqpxxdFNgmZsDDU6PfAoYvF1Eq9ZVsPjkxc7bYOu5jOAau5f4gQPDrXoRZzT6UM4hA004Sj2XAhM";
  static String paypalSecretKey =
      "EA6n3LU0VDU35eXZwlnEDkjC53qisvqfzBAG3hg72enDX1lDV7D4gZgYqQ_RC4sUaHtJTnWIu2202M7Y";
  static String paypalClientId =
      "AacGnXjkiXPlIpt4ePvOVbMsSXNzRfPNfo3Uw5LSm0VEJskSaORGk3qgI-p7tvyK7_FxYvaj9ETKAagU";

  //Trainer Payment keys
  static String stripeTrainerSecretKey =
      "sk_test_51L0j3XSCQIDASK9Q29xDwOCnIQb5ZIZJvJkSiXkDzonVHjMHS3NABec0aoWgDcpjIfn7XRVK4WawZUJXmgHENkPQ00ODRGLtuS";
  static String stripeTrainerPublishableKey =
      "pk_test_51L0j3XSCQIDASK9QmTpzX1BqpxxdFNgmZsDDU6PfAoYvF1Eq9ZVsPjkxc7bYOu5jOAau5f4gQPDrXoRZzT6UM4hA004Sj2XAhM";
  static String paypalTrainerSecretKey =
      "EA6n3LU0VDU35eXZwlnEDkjC53qisvqfzBAG3hg72enDX1lDV7D4gZgYqQ_RC4sUaHtJTnWIu2202M7Y";
  static String paypalTrainerClientId =
      "AacGnXjkiXPlIpt4ePvOVbMsSXNzRfPNfo3Uw5LSm0VEJskSaORGk3qgI-p7tvyK7_FxYvaj9ETKAagU";

  // SendinBlue Detail
  /// ************************************ Sendinblue Setup ************************************************/

  static String sendinblueEmailFrom = '';
  static String sendinblueDomain = 'sendinblue.com';
  static String sendinblueEmailName = '';
  static String sendinblueSMTPServer = '';
  static String sendinblueSMTPServerPort = "";

  static String sendinblueEmail = '';
  static String sendinblueSMTPPassword = '';

//for display greeting message
  static String greetingMessage(BuildContext context) {
    var timeNow = DateTime.now().hour;
    if (timeNow < 12) {
      return AppLocalizations.of(context)!.good_morning;
    } else if ((timeNow > 11) && (timeNow <= 16)) {
      return AppLocalizations.of(context)!.good_afternoon;
    } else {
      return AppLocalizations.of(context)!.good_evening;
    }
  }

  static const List<String> attachmentExtensionList = [
    '.jpg',
    '.jpeg',
    '.png',
    '.pdf',
    '.csv',
    '.doc',
    '.docx',
    '.txt',
    '.ppt',
    '.pptm',
    '.pptx',
    '.xls',
    '.xlsx'
  ];

  static bool isAttachmentValid(String fileName, List<String> extensionList) {
    for (int i = 0; i < extensionList.length; i++) {
      if (fileName.endsWith(extensionList[i])) {
        return true;
      }
    }
    return false;
  }

  /// Get Attachment url for launch in web view.
  static String getAttachmentUrl(String attachment) {
    if (attachment.endsWith(".ppt") ||
        attachment.endsWith(".pptx") ||
        attachment.endsWith(".xls") ||
        attachment.endsWith(".xlsx") ||
        attachment.endsWith(".doc") ||
        attachment.endsWith(".docx")) {
      // attachment = "https://drive.google.com/viewerng/viewer?embedded=true&url=" + attachment;
      // attachment = "https://docs.google.com/gview?embedded=true&url=" + attachment;
      attachment = "https://view.officeapps.live.com/op/view.aspx?src=$attachment";
    }
    return attachment;
  }

  static dynamic loadAssetsToJson(String assetsPath) async {
    String jsonString = await rootBundle.loadString(assetsPath);
    return json.decode(jsonString);
  }

  static final colorList = [
    ColorCode.workoutList5,
    ColorCode.workoutPremiumMembership,
    ColorCode.lightGreen,
    ColorCode.workoutList4,
    // ColorCode.adminProfileLogoutColor,
  ];

  static final workoutColorList = [
    ColorCode.workoutList2,
    ColorCode.workoutList3,
    ColorCode.workoutList4,
    ColorCode.workoutList5,
    ColorCode.adminProfileLogoutColor,
  ];

  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
          apiKey: "AIzaSyBps4gtdqli03id8pbfvHirK6MaKdGI-as",
          authDomain: "gym---trainer-app.firebaseapp.com",
          projectId: "gym---trainer-app",
          storageBucket: "gym---trainer-app.appspot.com",
          messagingSenderId: "342269915568",
          appId: "1:342269915568:web:3a2e4a23f136587a392675",
          measurementId: "G-3SVP8SFWL2");
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
          apiKey: "AIzaSyBps4gtdqli03id8pbfvHirK6MaKdGI-as",
          authDomain: "gym---trainer-app.firebaseapp.com",
          projectId: "gym---trainer-app",
          storageBucket: "gym---trainer-app.appspot.com",
          messagingSenderId: "342269915568",
          appId: "1:342269915568:ios:b67b294837e8ba11392675",
          measurementId: "G-3SVP8SFWL2",
          iosBundleId: 'crossfit.personaltrainer.gymtrainer.fitness',
          iosClientId: '342269915568-uiinnbdmtv4vqpvbjv4j9n14ti9bikle.apps.googleusercontent.com');
    } else {
      // Android
      return const FirebaseOptions(
          apiKey: "AIzaSyC8Y-7tIwCUEH_V38Bd3WpM0C9pvKH47XA",
          authDomain: "gym---trainer-app.firebaseapp.com",
          projectId: "gym---trainer-app",
          storageBucket: "gym---trainer-app.appspot.com",
          messagingSenderId: "342269915568",
          appId: "1:342269915568:android:3d21565bc5806c0a392675",
          measurementId: "G-3SVP8SFWL2",
          androidClientId: '342269915568-uiinnbdmtv4vqpvbjv4j9n14ti9bikle.apps.googleusercontent.com');
    }
  }
}
