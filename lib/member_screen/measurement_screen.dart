import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crossfit_gym_trainer/providers/measurement_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/custom_calendar_app.dart';
import '../custom_widgets/custom_card.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../utils/gym_style.dart';
import '../utils/utils_methods.dart';
import 'dashboard_screen.dart';

class MeasurementScreen extends StatefulWidget {
  const MeasurementScreen({Key? key}) : super(key: key);

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late MeasurementProvider measurementProvider;
  late ShowProgressDialog showProgressDialog;
  var selectedDateTime =
      DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
  var weightController = TextEditingController();
  var heightController = TextEditingController();
  var chestController = TextEditingController();
  var waistController = TextEditingController();
  var thighController = TextEditingController();
  var armsController = TextEditingController();
  String trainerId = "";
  String userId = "";
  String currentLanguage = "";
  String? currentDocId;

  @override
  void initState() {
    super.initState();
    measurementProvider =
        Provider.of<MeasurementProvider>(context, listen: false);
    showProgressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      trainerId = await _preference.getValue(prefCreatedBy, "");
      userId = await _preference.getValue(prefUserId, "");
      currentLanguage = await _preference.getValue(prefLanguage, "");
      showProgressDialog.show();
      await measurementProvider.getMeasurement(currentUser: userId);
      showProgressDialog.hide();
      var currentDate =
          DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));

      if (measurementProvider.measurementListItem.isNotEmpty) {
        var docItem = measurementProvider.measurementListItem.firstWhere(
            (element) => currentDate.isSameDate(
                DateTime.fromMillisecondsSinceEpoch(
                    element.get(keyCreatedAt))));
        onDateChange(currentDate, docItem);
      } else {
        setState(
          () {
            debugPrint("currentLanguage 2 : $currentLanguage");

            selectedDateTime = currentDate;
            debugPrint('selectedDateTime : $selectedDateTime');
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (Route<dynamic> route) => false);

        return Future.value(true);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          leadingWidth: 48,
          leading: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            splashColor: const Color(0xFFB7C8FF),
            onTap: () {
              scaffoldKey.currentState!.openDrawer();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 10, 5),
              child: SvgPicture.asset(
                'assets/images/appbar_menu.svg',
                color: isDarkTheme
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF181A20),
              ),
            ),
          ),
          title: Text(AppLocalizations.of(context)!.measurement),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 65),
              child: Column(
                children: [
                  Consumer<MeasurementProvider>(
                    builder: (context, measurementData, child) => Container(
                      // height: height * 0.45,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      width: width,
                      child: CustomCalendarApp(
                        currentView: CalendarViews.month,
                        onDateChange: onDateChange,
                        measurementList: measurementData.measurementListItem,
                        disableFutureDate: true,
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20, top: 15),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        children: [
                          customCard(
                            blurRadius: 5,
                            radius: 15,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SvgPicture.asset(
                                          height: 50,
                                          width: 50,
                                          'assets/images/weight.svg')),
                                ),
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.weight}(${StaticData.weight})',
                                      maxLines: 1,
                                      style: GymStyle.listTitle,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (weightController.text
                                              .trim()
                                              .isEmpty) {
                                            weightController.text = "1.0";
                                            return;
                                          }
                                          var weight = double.parse(
                                              weightController.text.trim());
                                          if (weight == 1) {
                                            return;
                                          }
                                          weight = weight - 1;
                                          weightController.text =
                                              weight.toString();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: Image.asset(
                                            'assets/images/mines.png',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: ColorCode.mainColor,
                                                width: 2),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: weightController,
                                          maxLength: 5,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: GymStyle.settingSubTitleText,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (weightController.text
                                              .trim()
                                              .isEmpty) {
                                            weightController.text = "1.0";
                                            return;
                                          }
                                          var weight = double.parse(
                                              weightController.text.trim());
                                          weight = weight + 1;
                                          weightController.text =
                                              weight.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: const Icon(Icons.add,
                                              color: ColorCode.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          customCard(
                            blurRadius: 5,
                            radius: 15,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SvgPicture.asset(
                                          height: 50,
                                          width: 50,
                                          'assets/images/height.svg')),
                                ),
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.height}(${StaticData.height})',
                                      maxLines: 1,
                                      style: GymStyle.listTitle,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (heightController.text
                                              .trim()
                                              .isEmpty) {
                                            heightController.text = "1.0";
                                            return;
                                          }
                                          var height = double.parse(
                                              heightController.text.trim());
                                          if (height == 1) {
                                            return;
                                          }
                                          height = height - 1;
                                          heightController.text =
                                              height.toString();
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(13),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(40)
                                                    : const Radius.circular(0),
                                                bottomRight: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(40)
                                                    : const Radius.circular(0),
                                                bottomLeft: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(0)
                                                    : const Radius.circular(40),
                                                topLeft: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(0)
                                                    : const Radius.circular(40),
                                              ),
                                              color: ColorCode.mainColor,
                                            ),
                                            height: height * 0.06,
                                            width: width * 0.1,
                                            child: Image.asset(
                                              'assets/images/mines.png',
                                            )),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: ColorCode.mainColor,
                                                width: 2),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: heightController,
                                          maxLength: 5,
                                          style: GymStyle.settingSubTitleText,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (heightController.text
                                              .trim()
                                              .isEmpty) {
                                            heightController.text = "1.0";
                                            return;
                                          }
                                          var height = double.parse(
                                              heightController.text.trim());
                                          height = height + 1;
                                          heightController.text =
                                              height.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: const Icon(Icons.add,
                                              color: ColorCode.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          customCard(
                            blurRadius: 5,
                            radius: 15,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SvgPicture.asset(
                                          height: 50,
                                          width: 50,
                                          'assets/images/chest.svg')),
                                ),
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.chest}(${StaticData.chest})',
                                      maxLines: 1,
                                      style: GymStyle.listTitle,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (chestController.text
                                              .trim()
                                              .isEmpty) {
                                            chestController.text = "1.0";
                                            return;
                                          }
                                          var chest = double.parse(
                                              chestController.text.trim());
                                          if (chest == 1) {
                                            return;
                                          }
                                          chest = chest - 1;
                                          chestController.text =
                                              chest.toString();
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(13),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(40)
                                                    : const Radius.circular(0),
                                                bottomRight: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(40)
                                                    : const Radius.circular(0),
                                                bottomLeft: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(0)
                                                    : const Radius.circular(40),
                                                topLeft: checkRtl(
                                                        currentLanguage:
                                                            currentLanguage)
                                                    ? const Radius.circular(0)
                                                    : const Radius.circular(40),
                                              ),
                                              color: ColorCode.mainColor,
                                            ),
                                            height: height * 0.06,
                                            width: width * 0.1,
                                            child: Image.asset(
                                              'assets/images/mines.png',
                                            )),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: ColorCode.mainColor,
                                                width: 2),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: chestController,
                                          maxLength: 5,
                                          keyboardType: TextInputType.number,
                                          style: GymStyle.settingSubTitleText,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (chestController.text
                                              .trim()
                                              .isEmpty) {
                                            chestController.text = "1.0";
                                            return;
                                          }
                                          var chest = double.parse(
                                              chestController.text.trim());
                                          chest = chest + 1;
                                          chestController.text =
                                              chest.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: const Icon(Icons.add,
                                              color: ColorCode.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          customCard(
                            blurRadius: 5,
                            radius: 15,
                            child: Row(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(13),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SvgPicture.asset(
                                            height: 50,
                                            width: 50,
                                            'assets/images/waist.svg'))),
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.waist}(${StaticData.waist})',
                                      maxLines: 1,
                                      style: GymStyle.listTitle,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (waistController.text
                                              .trim()
                                              .isEmpty) {
                                            waistController.text = "1.0";
                                            return;
                                          }
                                          var waist = double.parse(
                                              waistController.text.trim());
                                          if (waist == 1) {
                                            return;
                                          }
                                          waist = waist - 1;
                                          waistController.text =
                                              waist.toString();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: Image.asset(
                                            'assets/images/mines.png',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: ColorCode.mainColor,
                                                width: 2),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: waistController,
                                          maxLength: 5,
                                          keyboardType: TextInputType.number,
                                          style: GymStyle.settingSubTitleText,
                                          textAlign: TextAlign.center,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (waistController.text
                                              .trim()
                                              .isEmpty) {
                                            waistController.text = "1.0";
                                            return;
                                          }
                                          var waist = double.parse(
                                              waistController.text.trim());
                                          waist = waist + 1;
                                          waistController.text =
                                              waist.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: const Icon(Icons.add,
                                              color: ColorCode.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          customCard(
                            blurRadius: 5,
                            radius: 15,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                          height: 50,
                                          width: 50,
                                          'assets/images/Thigh.png')),
                                ),
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.thigh}(${StaticData.thigh})',
                                      maxLines: 1,
                                      style: GymStyle.listTitle,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (thighController.text
                                              .trim()
                                              .isEmpty) {
                                            thighController.text = "1.0";
                                            return;
                                          }
                                          var thigh = double.parse(
                                              thighController.text.trim());
                                          if (thigh == 1) {
                                            return;
                                          }
                                          thigh = thigh - 1;
                                          thighController.text =
                                              thigh.toString();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: Image.asset(
                                            'assets/images/mines.png',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: ColorCode.mainColor,
                                                width: 2),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: thighController,
                                          maxLength: 5,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: GymStyle.settingSubTitleText,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (thighController.text
                                              .trim()
                                              .isEmpty) {
                                            thighController.text = "1.0";
                                            return;
                                          }
                                          var thigh = double.parse(
                                              thighController.text.trim());
                                          thigh = thigh + 1;
                                          thighController.text =
                                              thigh.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: const Icon(Icons.add,
                                              color: ColorCode.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          customCard(
                            blurRadius: 5,
                            radius: 15,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(13),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                          height: 50,
                                          width: 50,
                                          'assets/images/Arm.png')),
                                ),
                                SizedBox(
                                  width: width * 0.3,
                                  child: Text(
                                      '${AppLocalizations.of(context)!.arms}(${StaticData.arms})',
                                      maxLines: 1,
                                      style: GymStyle.listTitle,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 15, left: 15),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (armsController.text
                                              .trim()
                                              .isEmpty) {
                                            thighController.text = "1.0";
                                            return;
                                          }
                                          var arms = double.parse(
                                              armsController.text.trim());
                                          if (arms == 1) {
                                            return;
                                          }
                                          arms = arms - 1;
                                          armsController.text = arms.toString();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(13),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: Image.asset(
                                            'assets/images/mines.png',
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.06,
                                        width: width * 0.12,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.symmetric(
                                            horizontal: BorderSide(
                                                color: ColorCode.mainColor,
                                                width: 2),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: armsController,
                                          maxLength: 5,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: GymStyle.settingSubTitleText,
                                          decoration: const InputDecoration(
                                            counterText: "",
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (armsController.text
                                              .trim()
                                              .isEmpty) {
                                            armsController.text = "1.0";
                                            return;
                                          }
                                          var arms = double.parse(
                                              armsController.text.trim());
                                          arms = arms + 1;
                                          armsController.text = arms.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomRight: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(40),
                                              bottomLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                              topLeft: checkRtl(
                                                      currentLanguage:
                                                          currentLanguage)
                                                  ? const Radius.circular(40)
                                                  : const Radius.circular(0),
                                            ),
                                            color: ColorCode.mainColor,
                                          ),
                                          height: height * 0.06,
                                          width: width * 0.1,
                                          child: const Icon(Icons.add,
                                              color: ColorCode.white),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Positioned(
                bottom: 10,
                right: 15,
                left: 15,
                child: SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      showProgressDialog.show();
                      if (currentDocId != null) {
                        measurementProvider
                            .updateMeasurement(
                                measurementId: currentDocId,
                                currentUser: userId,
                                weight: double.parse(
                                    weightController.text.trim().toString()),
                                height: double.parse(
                                    heightController.text.trim().toString()),
                                chest: double.parse(
                                    chestController.text.trim().toString()),
                                waist: double.parse(
                                    waistController.text.trim().toString()),
                                thigh: double.parse(
                                    thighController.text.trim().toString()),
                                arms: double.parse(
                                    armsController.text.trim().toString()))
                            .then((defaultResponseData) => {
                                  showProgressDialog.hide(),
                                  if (defaultResponseData.status != null &&
                                      defaultResponseData.status!)
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponseData.message ??
                                              AppLocalizations.of(context)!
                                                  .something_want_to_wrong,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                          fontSize: 16.0),
                                      // Navigator.pop(context),
                                    }
                                  else
                                    {
                                      Fluttertoast.showToast(
                                          msg: defaultResponseData.message ??
                                              AppLocalizations.of(context)!
                                                  .something_want_to_wrong,
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 3,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0)
                                    }
                                });
                      } else {
                        measurementProvider
                            .addMeasurement(
                                dateTimestamp:
                                    selectedDateTime.millisecondsSinceEpoch,
                                weight: double.parse(weightController.text.trim().toString().isEmpty
                                    ? "0"
                                    : weightController.text.trim().toString()),
                                height: double.parse(heightController.text
                                        .trim()
                                        .toString()
                                        .isEmpty
                                    ? "0"
                                    : heightController.text.trim().toString()),
                                chest: double.parse(chestController.text.trim().toString().isEmpty
                                    ? "0"
                                    : chestController.text.trim().toString()),
                                waist: double.parse(waistController.text.trim().toString().isEmpty
                                    ? "0"
                                    : waistController.text.trim().toString()),
                                thigh: double.parse(
                                    thighController.text.trim().toString().isEmpty
                                        ? "0"
                                        : thighController.text.trim().toString()),
                                arms: double.parse(armsController.text.trim().toString().isEmpty ? "0" : armsController.text.trim().toString()),
                                trainerId: trainerId,
                                currentId: userId)
                            .then(
                              (defaultResponseData) => {
                                showProgressDialog.hide(),
                                if (defaultResponseData.status != null &&
                                    defaultResponseData.status!)
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponseData.message ??
                                            AppLocalizations.of(context)!
                                                .something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                    // Navigator.pop(context),
                                  }
                                else
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponseData.message ??
                                            AppLocalizations.of(context)!
                                                .something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                  }
                              },
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: ColorCode.mainColor,
                    ),
                    child: Text(AppLocalizations.of(context)!.save.allInCaps,
                        style: GymStyle.buttonTextStyle),
                  ),
                )),
          ],
        ),
        drawer: MainDrawerScreen(scaffoldKey: scaffoldKey),
      ),
    );
  }

  void onDateChange(DateTime tempDate, QueryDocumentSnapshot? document) {
    if (document != null) {
      weightController.text = document.get(keyWeight).toString();
      heightController.text = document.get(keyHeight).toString();
      chestController.text = document.get(keyChest).toString();
      waistController.text = document.get(keyWaist).toString();
      thighController.text = document.get(keyThigh).toString();
      armsController.text = document.get(keyArms).toString();
      currentDocId = document.id;
    } else {
      currentDocId = null;
      weightController.clear();
      heightController.clear();
      chestController.clear();
      waistController.clear();
      thighController.clear();
      armsController.clear();
    }
    setState(
      () {
        debugPrint("currentLanguage 2 : $currentLanguage");

        selectedDateTime = tempDate;
        debugPrint('selectedDateTime : $selectedDateTime');
      },
    );
  }
}
