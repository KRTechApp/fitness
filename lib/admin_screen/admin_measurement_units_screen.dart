import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../providers/general_setting_provider.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';

class AdminMeasurementUnitsScreen extends StatefulWidget {
  final DocumentSnapshot? documentSnapshot;

  const AdminMeasurementUnitsScreen({Key? key, required this.documentSnapshot}) : super(key: key);

  @override
  State<AdminMeasurementUnitsScreen> createState() => _AdminMeasurementUnitsScreenState();
}

class _AdminMeasurementUnitsScreenState extends State<AdminMeasurementUnitsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String weight = "kg";
  String heights = "centimeter";
  String chest = "centimeter";
  String waist = "centimeter";
  String thigh = "centimeter";
  String arms = "centimeter";
  late SettingProvider settingProvider;
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    settingProvider = Provider.of<SettingProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        showProgressDialog.show();
        settingProvider.getSettingsList().then(
              (value) => {showProgressDialog.hide(), updateDocument(settingProvider.generalSettingItem)},
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leadingWidth: 38,
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
            child: SvgPicture.asset(
              'assets/images/ic_left_arrow.svg',
            ),
          ),
        ),
        title: Text(AppLocalizations.of(context)!.measurement_units),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: width,
              margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: ColorCode.tabBarBackground,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.weight,
                        style: GymStyle.settingHeadingTitle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.kg.toUpperCase(),
                                style: TextStyle(
                                  color: weight == "kg" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "kg",
                                groupValue: weight,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      weight = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.lbs.toUpperCase(),
                                style: TextStyle(
                                  color: weight == "lbs" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "lbs",
                                groupValue: weight,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      weight = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                      child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.height,
                        style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.centimeter,
                                style: TextStyle(
                                  color: heights == "centimeter" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "centimeter",
                                groupValue: heights,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      heights = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.inches,
                                style: TextStyle(
                                  color: heights == "inches" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "inches",
                                groupValue: heights,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      heights = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                      child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.chest,
                        style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.centimeter,
                                style: TextStyle(
                                  color: chest == "centimeter" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "centimeter",
                                groupValue: chest,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      chest = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.inches,
                                style: TextStyle(
                                  color: chest == "inches" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "inches",
                                groupValue: chest,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      chest = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                      child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.waist,
                        style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.centimeter,
                                style: TextStyle(
                                  color: waist == "centimeter" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "centimeter",
                                groupValue: waist,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      waist = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.inches,
                                style: TextStyle(
                                  color: waist == "inches" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "inches",
                                groupValue: waist,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      waist = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                      child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.thigh,
                        style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.centimeter,
                                style: TextStyle(
                                  color: thigh == "centimeter" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "centimeter",
                                groupValue: thigh,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      thigh = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.inches,
                                style: TextStyle(
                                  color: thigh == "inches" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "inches",
                                groupValue: thigh,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      thigh = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                      child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20.0),
                      child: Text(
                        AppLocalizations.of(context)!.arms,
                        style: const TextStyle(fontSize: 14, color: ColorCode.tabBarText),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.centimeter,
                                style: TextStyle(
                                  color: arms == "centimeter" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "centimeter",
                                groupValue: arms,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      arms = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.05,
                            width: width * 0.38,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              horizontalTitleGap: -5,
                              title: Text(
                                AppLocalizations.of(context)!.inches,
                                style: TextStyle(
                                  color: arms == "inches" ? ColorCode.backgroundColor : ColorCode.tabBarBoldText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Radio(
                                activeColor: ColorCode.mainColor,
                                value: "inches",
                                groupValue: arms,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      arms = value.toString();
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 20, right: 20),
                      child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 14,
            left: 27,
            child: Container(
              height: height * 0.08,
              width: width * 0.85,
              margin: const EdgeInsets.only(bottom: 38),
              child: ElevatedButton(
                onPressed: () {
                  if (widget.documentSnapshot == null) {
                    showProgressDialog.show(message: "Loading");
                    settingProvider
                        .addMeasurement(
                          weight: weight.trim(),
                          height: heights.trim(),
                          chest: chest.trim(),
                          waist: waist.trim(),
                          thigh: thigh.trim(),
                          arms: arms.trim(),
                        )
                        .then(
                          ((defaultResponse) => {
                                showProgressDialog.hide(),
                                if (defaultResponse.status != null && defaultResponse.status!)
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponse.message ??
                                            AppLocalizations.of(context)!.something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                    refreshData()
                                  }
                                else
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponse.message ??
                                            AppLocalizations.of(context)!.something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                  }
                              }),
                        );
                  } else {
                    debugPrint("update : ");
                    showProgressDialog.show(message: 'Loading...');
                    settingProvider
                        .updateMeasurement(
                          settingId: widget.documentSnapshot!.id,
                          weight: weight.trim(),
                          height: heights.trim(),
                          chest: chest.trim(),
                          waist: waist.trim(),
                          thigh: thigh.trim(),
                          arms: arms.trim(),
                        )
                        .then(
                          ((defaultResponseData) => {
                                showProgressDialog.hide(),
                                if (defaultResponseData.status != null && defaultResponseData.status!)
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponseData.message ??
                                            AppLocalizations.of(context)!.something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0),
                                    refreshData()
                                  }
                                else
                                  {
                                    Fluttertoast.showToast(
                                        msg: defaultResponseData.message ??
                                            AppLocalizations.of(context)!.something_want_to_wrong,
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 3,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0)
                                  }
                              }),
                        );
                  }
                },
                style: GymStyle.buttonStyle,
                child: Text(
                  AppLocalizations.of(context)!.submit.toUpperCase(),
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      setState(
        () {
          weight = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyWeight)
              ? documentSnapshot.get(keyWeight)
              : weight;
          heights = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyHeight)
              ? documentSnapshot.get(keyHeight)
              : heights;
          chest = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyChest)
              ? documentSnapshot.get(keyChest)
              : chest;
          waist = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyWaist)
              ? documentSnapshot.get(keyWaist)
              : waist;
          thigh = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyThigh)
              ? documentSnapshot.get(keyThigh)
              : thigh;
          arms = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyArms)
              ? documentSnapshot.get(keyArms)
              : arms;
        },
      );
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    settingProvider.getSettingsList().then(
          (value) => {showProgressDialog.hide(), updateDocument(settingProvider.generalSettingItem)},
        );
  }
}
