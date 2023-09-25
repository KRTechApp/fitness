import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../providers/general_setting_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class TrainerPaymentSettingScreen extends StatefulWidget {

  const TrainerPaymentSettingScreen({super.key});

  @override
  State<TrainerPaymentSettingScreen> createState() => _TrainerPaymentSettingScreenState();
}

class _TrainerPaymentSettingScreenState extends State<TrainerPaymentSettingScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late SettingProvider generalSettingProvider;
  late TrainerProvider trainerProvider;
  late ShowProgressDialog showProgressDialog;
  String currentUserId = "";
  final SharedPreferencesManager preferencesManager = SharedPreferencesManager();

  final List<String> paymentList = [
    "Cash-Offline",
    "PayPal",
    "Stripe",
  ];
  String? selectedPayment = "Cash-Offline";
  TextEditingController stripeSecretKey = TextEditingController();
  TextEditingController stripePublishableKey = TextEditingController();
  TextEditingController paypalSecretKey = TextEditingController();
  TextEditingController paypalClientId = TextEditingController();

  @override
  void initState() {
    super.initState();
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: true);
    generalSettingProvider = Provider.of<SettingProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback(
          (_) async {

        showProgressDialog.show();
        currentUserId = await preferencesManager.getValue(prefUserId, "");

        trainerProvider
            .getSingleTrainer(userId: currentUserId)
            .then((doc) => {showProgressDialog.hide(), updateDocument(doc)});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
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
        title: Text(AppLocalizations.of(context)!.payment_setting),
      ),
      body: Stack(
        children: [
          Container(
            width: width,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 25, bottom: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: ColorCode.tabBarBackground,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 100),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Text(
                          AppLocalizations.of(context)!.payment_setting,
                          style: GymStyle.settingHeadingTitle,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            buttonWidth: width,
                            dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hint: Text(
                              AppLocalizations.of(context)!.cash_offline,
                              style: GymStyle.settingSubTitleText,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down, size: 35, color: ColorCode.tabBarText),
                            items: paymentList
                                .map(
                                  (item) =>
                                  DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: GymStyle.settingSubTitleText,
                                    ),
                                  ),
                            )
                                .toList(),
                            value: selectedPayment,
                            onChanged: (value) {

                              setState(
                                    () {
                                  selectedPayment = value as String;
                                },
                              );

                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                        EdgeInsets.only(left: 20, right: 20, bottom: selectedPayment == "Cash-Offline" ? 0 : 25),
                        child: const Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                      ),
                      if (selectedPayment == "PayPal" || selectedPayment == "Stripe")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Divider(height: 1, color: ColorCode.tabDivider, thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                              child: Text(
                                "$selectedPayment ${AppLocalizations.of(context)!.settings}",
                                style: GymStyle.settingSubTitleText,
                              ),
                            ),
                            if (selectedPayment == "PayPal")
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
                                    child: TextFormField(
                                      controller: paypalSecretKey,
                                      cursorColor: ColorCode.mainColor,
                                      keyboardType: TextInputType.text,
                                      style: GymStyle.settingSubTitleText,
                                      validator: (value) {
                                        if (value == null || value
                                            .trim()
                                            .isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_your_secret_key;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.mainColor,
                                          ),
                                        ),
                                        disabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabDivider,
                                          ),
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabBarBoldText,
                                          ),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        labelText: '${AppLocalizations.of(context)!.secret_key}*',
                                        labelStyle: GymStyle.settingHeadingTitleDefault,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: TextFormField(
                                      controller: paypalClientId,
                                      cursorColor: ColorCode.mainColor,
                                      keyboardType: TextInputType.text,
                                      style: GymStyle.settingSubTitleText,
                                      validator: (value) {
                                        if (value == null || value
                                            .trim()
                                            .isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_your_clint_id;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.mainColor,
                                          ),
                                        ),
                                        disabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabDivider,
                                          ),
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabBarBoldText,
                                          ),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        labelText: '${AppLocalizations.of(context)!.clint_id}*',
                                        labelStyle: GymStyle.settingHeadingTitleDefault,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (selectedPayment == "Stripe")
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25),
                                    child: TextFormField(
                                      controller: stripeSecretKey,
                                      cursorColor: ColorCode.mainColor,
                                      keyboardType: TextInputType.text,
                                      style: GymStyle.settingSubTitleText,
                                      validator: (value) {
                                        if (value == null || value
                                            .trim()
                                            .isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_your_secret_key;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.mainColor,
                                          ),
                                        ),
                                        disabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabDivider,
                                          ),
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabBarBoldText,
                                          ),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        labelText: '${AppLocalizations.of(context)!.secret_key}*',
                                        labelStyle: GymStyle.settingHeadingTitleDefault,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: TextFormField(
                                      controller: stripePublishableKey,
                                      cursorColor: ColorCode.mainColor,
                                      keyboardType: TextInputType.text,
                                      style: GymStyle.settingSubTitleText,
                                      validator: (value) {
                                        if (value == null || value
                                            .trim()
                                            .isEmpty) {
                                          return AppLocalizations.of(context)!.please_enter_your_publishable_key;
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        focusedBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.mainColor,
                                          ),
                                        ),
                                        disabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabDivider,
                                          ),
                                        ),
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: ColorCode.tabBarBoldText,
                                          ),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        labelText: '${AppLocalizations.of(context)!.publishable_key}*',
                                        labelStyle: GymStyle.settingHeadingTitleDefault,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (selectedPayment == "Stripe")
            Positioned(
              bottom: 5,
              left: 27,
              child: Container(
                height: height * 0.08,
                width: width * 0.85,
                margin: const EdgeInsets.only(bottom: 38),
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                        showProgressDialog.show(message: "Loading");
                        trainerProvider
                            .addPayment(trainerId: currentUserId,
                            paymentType:  getPaymentType(selectedPayment: selectedPayment!),
                            secretKey: stripeSecretKey.text.trim().toString(),
                            publishableKey: stripePublishableKey.text.trim().toString())
                            .then(
                          ((defaultResponse) =>
                          {
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

                    }
                  },
                  style: GymStyle.buttonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.submit.toUpperCase(),
                    style: GymStyle.buttonTextStyle,
                  ),
                ),
              ),
            ),
          if (selectedPayment == "PayPal")
            Positioned(
              bottom: 5,
              left: 27,
              child: Container(
                height: height * 0.08,
                width: width * 0.85,
                margin: const EdgeInsets.only(bottom: 38),
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('selectedPayment: $selectedPayment');
                    debugPrint('StaticData.currentTrainerCurrencyName: ${StaticData.currentTrainerCurrencyName}');
                    if( selectedPayment == "PayPal" && StaticData.currentTrainerCurrencyName == "INR") {
                      Fluttertoast.showToast(
                          msg: AppLocalizations.of(context)!
                              .please_update_currency_inr_not_supported_in_paypal,
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      return;
                    }
                    if (formKey.currentState!.validate()) {
                        showProgressDialog.show(message: "Loading");
                        trainerProvider
                            .addPayPal(trainerId: currentUserId,
                            paymentType: getPaymentType(selectedPayment: selectedPayment!),
                            secretKey: paypalSecretKey.text.trim().toString(),
                            clientId: paypalClientId.text.trim().toString())
                            .then(
                          ((defaultResponse) =>
                          {
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
                    }
                  },
                  style: GymStyle.buttonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.submit.toUpperCase(),
                    style: GymStyle.buttonTextStyle,
                  ),
                ),
              ),
            ),
          if (selectedPayment == "Cash-Offline")
            Positioned(
              bottom: 5,
              left: 27,
              child: Container(
                height: height * 0.08,
                width: width * 0.85,
                margin: const EdgeInsets.only(bottom: 38),
                child: ElevatedButton(
                  onPressed: () {
                    showProgressDialog.show(message: "Loading");
                    trainerProvider
                        .addCashPayment(trainerId: currentUserId,
                        paymentType: getPaymentType(selectedPayment: selectedPayment!))
                        .then(
                      ((defaultResponse) =>
                      {
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

                  },
                  style: GymStyle.buttonStyle,
                  child: Text(
                    AppLocalizations.of(context)!.submit.toUpperCase(),
                    style: GymStyle.buttonTextStyle,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void updateDocument(DocumentSnapshot? documentSnapshot) {
    if (documentSnapshot != null) {
      setState(() {
        selectedPayment = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyPaymentType)
            ? getPaymentTitle(paymentType: documentSnapshot.get(keyPaymentType))
            : selectedPayment;
        StaticData.paymentTrainerType = getPaymentType(selectedPayment: selectedPayment!);

        stripeSecretKey.text = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keySecretKey)
            ? documentSnapshot.get(keySecretKey)
            : stripeSecretKey.text;
        StaticData.stripeTrainerSecretKey = stripeSecretKey.text;

        stripePublishableKey.text = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyPublishable)
            ? documentSnapshot.get(keyPublishable)
            : stripePublishableKey.text;
        StaticData.stripeTrainerPublishableKey = stripePublishableKey.text;

        paypalClientId.text = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyPaypalClientId)
            ? documentSnapshot.get(keyPaypalClientId)
            : paypalClientId.text;
        StaticData.paypalTrainerClientId = paypalClientId.text;

        paypalSecretKey.text = (documentSnapshot.data() as Map<String, dynamic>).containsKey(keyPaypalSecretKey)
            ? documentSnapshot.get(keyPaypalSecretKey)
            : paypalSecretKey.text;
        StaticData.paypalTrainerSecretKey = paypalSecretKey.text;

      });
    }
  }

  Future<void> refreshData() async {
    showProgressDialog.show();
    trainerProvider
        .getSingleTrainer(userId: currentUserId)
        .then((doc) => {showProgressDialog.hide(), updateDocument(doc)});
  }
}
