import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';

import '../main.dart';
import 'color_code.dart';

class GymStyle {
  static var formTitle =
      const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w700, fontFamily: 'Poppins');
  static var
  dashbordNodataText = const TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    color: ColorCode.listSubTitle,
    fontSize: 12,
  );
  static var formDescription = const TextStyle(fontSize: 13, fontFamily: 'Poppins');
  static var alreadyAccount = TextStyle(
      color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
      fontSize: 16,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400);
  static var alreadyAccount1 =
      const TextStyle(color: Color(0xFF95979C), fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w400);
  static var signUpAccount =
      const TextStyle(color: ColorCode.mainColor, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w400);
  static var buttenText = const TextStyle(
      color: ColorCode.white, fontSize: 16, fontFamily: 'Poppins-SemiBold.ttf', fontWeight: FontWeight.w400);
  static var onBoarding =
      const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w200, fontFamily: 'Poppins');
  static var onBoardingOne =
      const TextStyle(color: Colors.white, fontSize: 45, fontWeight: FontWeight.bold, fontFamily: 'Poppins');
  static var onBoardingTwo =
      const TextStyle(color: Colors.white, height: 2, fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Poppins');
  static var buttonTextStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins-SemiBold.ttf');
  static var buttonTextStyleSmall =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins-SemiBold.ttf');
  static var whitwButtonTextStyle = const TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: ColorCode.mainColor, fontFamily: 'Poppins-SemiBold.ttf');
  static var buttonStyle = ElevatedButton.styleFrom(
    shape: const StadiumBorder(),
    backgroundColor: ColorCode.mainColor,
  );
  static var whiteButtonStyle = ElevatedButton.styleFrom(
    shape: const StadiumBorder(),
    side: const BorderSide(color: ColorCode.mainColor, width: 2),
    backgroundColor: ColorCode.white,
  );
  static var onBoardingTabsText = const TextStyle(fontSize: 35, fontWeight: FontWeight.w600, fontFamily: 'Poppins');

  static var socialLoginLabel = TextStyle(
    fontSize: getFontSize(29),
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
  );

  static var socialLoginText = const TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500);

  static var backButtonStyle = ElevatedButton.styleFrom(
    shape: const StadiumBorder(),
    backgroundColor: const Color(0xFF676767),
  );
  static var emailTextStyle = const TextStyle(fontFamily: 'Poppins');
  static var emailHintTextStyle = const TextStyle(color: Color(0xFF95979C));
  static var continueWith = const TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500);
  static var forgotPassword =
      const TextStyle(color: ColorCode.mainColor, fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w300);

  //-----------------*****-------------------******----------------*****---------------*****--------------*****
  static var listTitle = const TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: ColorCode.backgroundColor);
  static var listTitle2 = TextStyle(fontSize: getFontSize(18), fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var listSubTitle = TextStyle(
    color: ColorCode.listSubTitle,
    fontSize: getFontSize(14),
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );
  static var listSubTitle3 = TextStyle(
      color: ColorCode.listSubTitle2, fontSize: getFontSize(14), fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var listSubTitle2 =  TextStyle(fontSize: getFontSize(14), fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var screenHeader = const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var screenHeader2 =
      const TextStyle(color: ColorCode.mainColor, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var buttonText =
      const TextStyle(color: ColorCode.mainColor, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var startButton =
      const TextStyle(color: ColorCode.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var resetButton =
      const TextStyle(color: ColorCode.white, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  static var editButton =
      const TextStyle(color: ColorCode.white, fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var progressText =
      const TextStyle(color: ColorCode.white, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var containerSubHeader =
      const TextStyle(color: ColorCode.listSubTitle, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var popupbox =
      const TextStyle(color: ColorCode.tabBarText, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var searchbox =
      const TextStyle(color: ColorCode.tabBarText, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  static var popupboxdelate =
      const TextStyle(color: ColorCode.orangeHigh, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var containerSubHeader2 =
      const TextStyle(color: ColorCode.white, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var smalltTextinput = const TextStyle(
      color: ColorCode.tabBarBoldText, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var des = const TextStyle(
      color: ColorCode.descriptionText, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var containerSubHeader3 =
      const TextStyle(color: ColorCode.white, fontSize: 12, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var containerHeader = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var containersmallHeader = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  static var headerColor1 = const TextStyle(
      color: ColorCode.backIcon, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var containerHeader1 = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var headerColor =
      const TextStyle(color: ColorCode.backIcon, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var containerHeader2 =
      const TextStyle(color: ColorCode.white, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var seeAllStyle = const TextStyle(
      color: ColorCode.listSubTitle, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins-SemiBold.ttf');
  static var inputText = const TextStyle(
      color: ColorCode.tabBarBoldText, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  static var inputTextSmall = TextStyle(
      fontSize: getFontSize(14), fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  static var boldText = const TextStyle(
      color: ColorCode.tabBarBoldText, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var whiteboldText =
  TextStyle(color: ColorCode.white, fontSize: getFontSize(16), fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var inputTextBold =  TextStyle(
      color: ColorCode.backgroundColor, fontSize: getFontSize(16), fontWeight: FontWeight.w500, fontFamily: 'Poppins');
  static var containerLowarText = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var desTitle = const TextStyle(
      color: ColorCode.descriptionTitle, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins');
  static var membershipprice =
      const TextStyle(color: ColorCode.listSubTitle, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins');
  static var containerUpperText = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var tabbar = const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var drawerFont = const TextStyle(
    color: ColorCode.backIcon,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );
  static var drawerswitchtext = TextStyle(
    color: ColorCode.backIcon,
    fontSize: getFontSize(14),
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );
  static var exerciseLableText = const TextStyle(
    color: ColorCode.backIcon,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );
  static var deviderThiknes = 1.0;

  static var settingTitle = const TextStyle(fontSize: 16, color: ColorCode.tabBarText, fontWeight: FontWeight.w500);

  static var settingHeadingTitle =
      const TextStyle(fontSize: 14, color: ColorCode.tabBarText, fontWeight: FontWeight.w500);
  static var settingHeadingTitleDefault =
      const TextStyle(fontSize: 14, color: ColorCode.tabBarText, fontWeight: FontWeight.w500);

  static var adminProfileHeadingTitle =
      const TextStyle(fontSize: 16, color: ColorCode.tabBarBoldText, fontWeight: FontWeight.w500);

  static var adminProfileLogoutText =
      const TextStyle(fontSize: 14, color: ColorCode.adminProfileLogoutColor, fontWeight: FontWeight.w400);
  static var settingHeadingTitle1 =
      const TextStyle(fontSize: 14, color: ColorCode.hintText, fontWeight: FontWeight.w500);
  static var settingSubTitleText =
      const TextStyle(fontSize: 16, color: ColorCode.backgroundColor, fontWeight: FontWeight.w500);
  static var italicText = const TextStyle(
      color: ColorCode.listSubTitle,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins',
      fontStyle: FontStyle.italic);

  static var adminProfileName = const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ColorCode.backIcon);
  static var adminProfileEmail =
      const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ColorCode.adminProfileEmailColor);

  static var globalSearchTitle =
      TextStyle(color: ColorCode.backgroundColor2, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var globalSearchTitleHighLight = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var reportMainTitleText = const TextStyle(
      color: ColorCode.backgroundColor, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Poppins');
  static var titleLightDark = const TextStyle(
      color: ColorCode.backIcon, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var dayNameEnable = const TextStyle(
      color: ColorCode.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
  static var dayNameDisable = const TextStyle(
      color: ColorCode.backIcon, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins');
}
