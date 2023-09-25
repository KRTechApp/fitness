import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import 'package:flutter_paypal/flutter_paypal.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/custom_card.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/payment_utils.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'main_drawer_screen.dart';

class MembershipPackageScreen extends StatefulWidget {
  final String userRole;

  const MembershipPackageScreen({Key? key, required this.userRole})
      : super(key: key);

  @override
  State<MembershipPackageScreen> createState() =>
      _MembershipPackageScreenState();
}

class _MembershipPackageScreenState extends State<MembershipPackageScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? paymentIntent;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MembershipProvider membershipProvider;
  late PaymentHistoryProvider paymentHistoryProvider;
  late MemberProvider memberProvider;
  late ShowProgressDialog progressDialog;
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userRole = "";
  String currentUserId = "";
  String createdBy = "";

  /*var selectedWeek = 0;
  List<String> weeks = ["30 Days", "90 Days", "180 Month", "365 Months"];
  String? selectedValue;*/
  bool sortByCreated = true;

  @override
  void initState() {
    super.initState();
    membershipProvider =
        Provider.of<MembershipProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    paymentHistoryProvider =
        Provider.of<PaymentHistoryProvider>(context, listen: false);
    progressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userRole = await _preference.getValue(prefUserRole, "");
        currentUserId = await _preference.getValue(prefUserId, "");
        createdBy = await _preference.getValue(prefCreatedBy, "");
        progressDialog.show();
        // await membershipProvider.getMembershipList(isRefresh: true, currentUserId: createdBy);
        await paymentHistoryProvider.getPaymentHistory(
            currentUserId: currentUserId,
            sortByCreated: sortByCreated,
            status: "");
        progressDialog.hide();
        debugPrint('CurrentUserId$currentUserId');
        setState(
          () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        widget.userRole == userRoleTrainer
            ? Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const TrainerDashboardScreen()),
                (Route<dynamic> route) => false)
            : Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
                (Route<dynamic> route) => false);
        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leadingWidth: 48,
          leading: InkWell(
            borderRadius: const BorderRadius.all(
              Radius.circular(50),
            ),
            splashColor: ColorCode.linearProgressBar,
            onTap: () {
              _scaffoldKey.currentState!.openDrawer();
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
          title: userRole == userRoleMember
              ? Text(AppLocalizations.of(context)!.my_membership_plan)
              : Text(AppLocalizations.of(context)!.my_packages),
        ),
        body: SizedBox(
          height: height,
          width: width,
          child: RefreshIndicator(
            onRefresh: pullRefresh,
            child: Column(
              children: [
                /*if (searchVisible)
                  Card(
                    // elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFD9E1ED),
                      ),
                    ),
                    child: TextField(
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      controller: textSearchController,
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          onSearchTextChanged(
                            value.trim(),
                          );
                        } else {
                          onSearchTextChanged("");
                        }
                      },
                      decoration: InputDecoration(
                        hintStyle: GymStyle.searchbox,
                        hintText: AppLocalizations.of(context)!.search_membership,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                          child: SvgPicture.asset(
                            "assets/images/SearchIcon.svg",
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                      ),
                    ),
                  ),*/
                /*SizedBox(
                  height: height * 0.02,
                ),*/
                /*SizedBox(
                  height: 50,
                  width: width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weeks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(
                                () {
                                  selectedWeek = index;
                                },
                              );
                            },
                            child: Card(
                              elevation: 5,
                              color: selectedWeek == index ? const Color(0xFFCDDAFF) : const Color(0xFFffffff),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Color(0xFFB0BEEB), width: 1),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Container(
                                width: 100,
                                height: 55,
                                alignment: Alignment.center,
                                child: Text(
                                  weeks[index].toString(),
                                  style: GymStyle.listSubTitle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),*/
/*
                Center(
                  child: TextButton(
                      onPressed: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => UsePaypal(
                                sandboxMode: true,
                                clientId:
                                "AacGnXjkiXPlIpt4ePvOVbMsSXNzRfPNfo3Uw5LSm0VEJskSaORGk3qgI-p7tvyK7_FxYvaj9ETKAagU",
                                secretKey:
                                "EA6n3LU0VDU35eXZwlnEDkjC53qisvqfzBAG3hg72enDX1lDV7D4gZgYqQ_RC4sUaHtJTnWIu2202M7Y",
                                returnURL: "https://samplesite.com/return",
                                cancelURL: "https://samplesite.com/cancel",
                                transactions: const [
                                  {
                                    "amount": {
                                      "total": '11',
                                      "currency": "USD",
                                      "details": {
                                        "subtotal": '11',
                                        "shipping": '0',
                                        "shipping_discount": 0
                                      }
                                    },
                                    "description": "The payment transaction description.",
                                    // "payment_options": {
                                    //   "allowed_payment_method":
                                    //       "INSTANT_FUNDING_SOURCE"
                                    // },
                                    "item_list": {
                                      "items": [
                                        {
                                          "name": "A demo product",
                                          "quantity": 2,
                                          "price": '5.5',
                                          "currency": "USD"
                                        }
                                      ],

                                      // shipping address is not required though
                                      */
/*"shipping_address": {
                                        "recipient_name": "Jane Foster",
                                        "line1": "Travis County",
                                        "line2": "",
                                        "city": "Austin",
                                        "country_code": "US",
                                        "postal_code": "73301",
                                        "phone": "+00000000",
                                        "state": "Texas"
                                      },*/ /*

                                    }
                                  }
                                ],
                                note: "Contact us for any questions on your order.",
                                onSuccess: (Map params) async {
                                  print("onSuccess: $params");
                                  Fluttertoast.showToast(
                                      msg: 'Payment Successfully',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                },
                                onError: (error) {
                                  print("onError: $error");
                                  Fluttertoast.showToast(
                                      msg: 'Payment not Completed',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                },
                                onCancel: (params) {
                                  print('cancelled: $params');
                                  Fluttertoast.showToast(
                                      msg: 'Payment Cancelled',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }),
                          ),
                        )
                      },
                      child: const Text("Make Payment")),
                ),
*/
                SizedBox(
                  height:
                      searchVisible ? height * 0.97 - 120 : height * 0.97 - 75,
                  width: width,
                  child: Consumer<PaymentHistoryProvider>(
                    builder: (context, paymentHistoryData, child) =>
                        paymentHistoryProvider
                                .packagePaymentHistoryItemList.isNotEmpty
                            ? ListView.builder(
                                padding:
                                    const EdgeInsets.only(bottom: 10, top: 10),
                                itemCount: paymentHistoryData
                                    .packagePaymentHistoryItemList.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final QueryDocumentSnapshot
                                      paymentHistoryDoc = paymentHistoryData
                                          .packagePaymentHistoryItemList[index];
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          /*  Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TrainerAddMemberShip(
                                                documentSnapshot: paymentHistoryDoc,
                                                viewType: "view",
                                              ),
                                            ),
                                          );*/
                                          PaymentUtils().checkUserPaymentStatus(
                                              context: context,
                                              paymentHistoryDoc:
                                                  paymentHistoryDoc,
                                              currentPaymentType:
                                                  widget.userRole ==
                                                          userRoleTrainer
                                                      ? StaticData.paymentType
                                                      : StaticData
                                                          .paymentTrainerType);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: customCard(
                                            blurRadius: 5,
                                            radius: 15,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: Directionality(
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: FadeInImage(
                                                            fit: BoxFit.cover,
                                                            width: 50,
                                                            height: 50,
                                                            image:
                                                                customImageProvider(
                                                              url: getDocumentValue(
                                                                  key:
                                                                      keyProfile,
                                                                  documentSnapshot:
                                                                      paymentHistoryDoc),
                                                            ),
                                                            placeholderFit:
                                                                BoxFit.fitWidth,
                                                            placeholder:
                                                                customImageProvider(),
                                                            imageErrorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return getPlaceHolder();
                                                            },
                                                          ),
                                                        ),
                                                        Positioned(
                                                            child: paymentHistoryDoc[
                                                                        keyPaymentStatus] ==
                                                                    "paid"
                                                                ? SvgPicture
                                                                    .asset(
                                                                    'assets/images/Paidlable.svg',
                                                                  )
                                                                : SvgPicture
                                                                    .asset(
                                                                    height: 35,
                                                                    width: 35,
                                                                    'assets/images/UnPaidLable.svg',
                                                                  ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                      width: width * 0.47,
                                                      child: Text(
                                                        paymentHistoryDoc[
                                                                keyMembershipName] ??
                                                            "",
                                                        // 'Golden Membership',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GymStyle.listTitle,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: height * 0.01),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            '${userRole == userRoleTrainer ? StaticData.currentCurrency : StaticData.currentTrainerCurrency} ${paymentHistoryDoc[keyAmount]}',
                                                            style: GymStyle
                                                                .membershipprice),
                                                        Text(' / ',
                                                            style: GymStyle
                                                                .listSubTitle),
                                                        Text(
                                                            '${paymentHistoryDoc[keyPeriod] ?? ""} ${AppLocalizations.of(context)!.days}',
                                                            style: GymStyle
                                                                .listSubTitle),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                FutureBuilder(
                                                  future: memberProvider
                                                      .getSelectedMember(
                                                    memberId: currentUserId,
                                                  ),
                                                  builder: (context,
                                                      AsyncSnapshot<
                                                              DocumentSnapshot?>
                                                          asyncSnapshot) {
                                                    if (asyncSnapshot.hasData &&
                                                        asyncSnapshot.data !=
                                                            null) {
                                                      var queryDoc =
                                                          asyncSnapshot.data;
                                                      return (queryDoc![
                                                                      keyCurrentMembership] ==
                                                                  paymentHistoryDoc[
                                                                      keyMembershipId]) &&
                                                              (queryDoc[
                                                                      keyMembershipTimestamp] ==
                                                                  paymentHistoryDoc[
                                                                      keyCreatedAt])
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 20,
                                                                      left: 20),
                                                              child: SvgPicture
                                                                  .asset(
                                                                      'assets/images/ProgressIcon.svg'),
                                                            )
                                                          : Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 8,
                                                                      left: 8),
                                                              child: SvgPicture
                                                                  .asset(
                                                                'assets/images/ic_Right.svg',
                                                              ),
                                                            );
                                                    }
                                                    return Container();
                                                  },
                                                ),
                                                /*const Spacer(),
                                            documentSnapshot[keyCurrentMembership] ==
                                                paymentHistoryDoc[keyMembershipId]
                                                ? Padding(
                                              padding: const EdgeInsets.only(right: 15),
                                              child: SvgPicture.asset('assets/images/ProgressIcon.svg'),
                                            )
                                                : Padding(
                                              padding: const EdgeInsets.only(right: 5),
                                              child: SvgPicture.asset(
                                                'assets/images/ic_Right.svg',
                                              ),
                                            ),*/
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.015,
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: ColorCode.tabDivider,
                                      maxRadius: 45,
                                      child: Image.asset(
                                          'assets/images/empty_box.png'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 17.0, right: 17, top: 15),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .you_do_not_have_any_membership,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                          color: ColorCode.listSubTitle,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  /*onSearchTextChanged(String text) async {
    membershipProvider.membershipListItem.clear();
    paymentHistoryProvider.packagePaymentHiSocialstoryItemList.clear();
    if (userRole == userRoleMember) {
      await paymentHistoryProvider.getPaymentHistory(
          currentUserId: currentUserId, sortByCreated: sortByCreated, status: "", isRefresh: true, searchText: text);
    } else {
      await membershipProvider.getMembershipList(searchText: text, isRefresh: true, currentUserId: currentUserId);
    }
  }*/

  Future<void> pullRefresh() async {
    progressDialog.show();
    if (userRole == userRoleMember) {
      await paymentHistoryProvider.getPaymentHistory(
          currentUserId: currentUserId,
          sortByCreated: sortByCreated,
          status: "");
    } else {
      await membershipProvider.getMembershipList(
          isRefresh: true, createdById: currentUserId);
    }
    progressDialog.hide();
  }

/* Future<void> makePaymentForStripe(QueryDocumentSnapshot documentSnapshot) async {
    var amount = documentSnapshot.get(keyAmount) * 100;

    try {
      paymentIntent = await createPaymentIntent(amount.toString(), StaticData.currentCurrencyName);

      var gpay = PaymentSheetGooglePay(
          merchantCountryCode: StaticData.currentCurrencyCountry,
          currencyCode: StaticData.currentCurrencyName,
          testEnv: true);

      debugPrint("client secret : ${paymentIntent!['client_secret']}");
      debugPrint("currency : ${paymentIntent!['currency']}");
      debugPrint("status : ${paymentIntent!['status']}");
      debugPrint("amount : ${paymentIntent!['amount']}");
      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!['client_secret'], //Gotten from payment intent
            style: ThemeMode.light,
            merchantDisplayName: 'Rasik',
            googlePay: gpay,
          ))
          .then((value) {});

      //STEP 3: Display Payment sheet

      displayPaymentSheet(documentSnapshot);
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  displayPaymentSheet(QueryDocumentSnapshot documentSnapshot) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await checkPaymentStatus(paymentIntentId: paymentIntent!['id'], paymentDocId: documentSnapshot.id);
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StaticData.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // debugPrint('createPaymentIntent body : ${body}');
      // debugPrint('responce : ${json.decode(response.body)}');
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<bool> checkPaymentStatus({required String paymentIntentId, required String paymentDocId}) async {
    final url = 'https://api.stripe.com/v1/payment_intents/$paymentIntentId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${StaticData.stripeSecretKey}',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final status = responseData['status'];
      debugPrint('PaymentStatus : $status');
      debugPrint('PaymentId : ${responseData['id']}');
      debugPrint('PaymentAmmount : ${(responseData['amount']) / 100}');
      debugPrint('Paymentamount_received : ${responseData['amount_received']}');
      debugPrint('PaymentCountry : ${responseData['charges']['data'][0]['billing_details']['address']['country']}');
      debugPrint('PaymentCurrency : ${responseData['currency']}');
      debugPrint('PaymentBrand : ${responseData['charges']['data'][0]['payment_method_details']['card']['brand']}');
      debugPrint('PaymentType : ${responseData['charges']['data'][0]['payment_method_details']['type']}');
      debugPrint(
          'PaymentCardCountry : ${responseData['charges']['data'][0]['payment_method_details']['card']['country']}');
      debugPrint('PaymentLast4 : ${responseData['charges']['data'][0]['payment_method_details']['card']['last4']}');
      debugPrint('PaymentEmail : ${responseData['charges']['data'][0]['receipt_email']}');
      debugPrint('PaymentRecept : ${responseData['charges']['data'][0]['receipt_url']}');
      debugPrint('PaymentClientSecret : ${responseData['client_secret']}');
      if (status == 'succeeded') {
        paymentHistoryProvider
            .addSubCollection(
                paymentDocId: paymentDocId,
                paymentStatus: responseData['status'],
                paymentId: responseData['id'],
                paymentAmount: (responseData['amount']) / 100,
                paymentRecivedAmount: (responseData['amount_received']) / 100,
                paymentCountry: responseData['charges']['data'][0]['billing_details']['address']['country'],
                paymentCourrency: responseData['currency'],
                paymentBrand: responseData['charges']['data'][0]['payment_method_details']['card']['brand'],
                paymentType: responseData['charges']['data'][0]['payment_method_details']['type'],
                paymentCardCountry: responseData['charges']['data'][0]['payment_method_details']['card']['country'],
                cardLast4: responseData['charges']['data'][0]['payment_method_details']['card']['last4'],
                paymentEmail: responseData['charges']['data'][0]['receipt_email'],
                paymentRecept: responseData['charges']['data'][0]['receipt_url'],
                clientSecretId: responseData['client_secret'],
                createdAt: getCurrentDateTime())
            .then(
              (defaultResponseData) => {
                if (defaultResponseData.status != null && defaultResponseData.status!)
                  {
                    paymentHistoryProvider.getPaymentHistory(
                        currentUserId: currentUserId, sortByCreated: sortByCreated, status: ""),
                    Fluttertoast.showToast(
                        msg: defaultResponseData.message ?? AppLocalizations.of(context)!.something_want_to_wrong,
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
                        msg: defaultResponseData.message ?? AppLocalizations.of(context)!.something_want_to_wrong,
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 3,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0)
                  }
              },
            );
      } else {
        Fluttertoast.showToast(
            msg: "Payment Faild",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      return status == 'succeeded'; // Return true if payment succeeded, false otherwise
    } else {
      throw Exception('Failed to retrieve payment intent.');
    }
  }

  Future<void> makePaymentForPayPal({required QueryDocumentSnapshot documentSnapshot}) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
            sandboxMode: true,
            clientId: "AacGnXjkiXPlIpt4ePvOVbMsSXNzRfPNfo3Uw5LSm0VEJskSaORGk3qgI-p7tvyK7_FxYvaj9ETKAagU",
            secretKey: "EA6n3LU0VDU35eXZwlnEDkjC53qisvqfzBAG3hg72enDX1lDV7D4gZgYqQ_RC4sUaHtJTnWIu2202M7Y",
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": (documentSnapshot[keyAmount]).toString(),
                  "currency": StaticData.currentCurrencyName,
                  "details": {
                    "subtotal": (documentSnapshot[keyAmount]).toString(),
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "The payment transaction description.",
                // "payment_options": {
                //   "allowed_payment_method":
                //       "INSTANT_FUNDING_SOURCE"
                // },
                "item_list": {
                  "items": [
                    {
                      "name": documentSnapshot[keyMembershipName] ?? "",
                      "quantity": 1,
                      "price": (documentSnapshot[keyAmount]).toString(),
                      "currency": StaticData.currentCurrencyName
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) async {
              log('onSuccess: $params');
              final paypalResponce = params;
              debugPrint('paypaltatus :${paypalResponce['status']}');
              if (paypalResponce['status'] == 'success') {
                paymentHistoryProvider
                    .addSubCollectionForPaypal(
                        membershipName: paypalResponce['data']['transactions'][0]['item_list']['items'][0]['name'],
                        paymentCourrency: paypalResponce['data']['transactions'][0]['item_list']['items'][0]
                            ['currency'],
                        paymentEmail: paypalResponce['data']['payer']['payer_info']['email'],
                        totalAmount: paypalResponce['data']['transactions'][0]['related_resources'][0]['sale']['amount']
                            ['total'],
                        paymentDocId: documentSnapshot.id,
                        paymentId: paypalResponce['paymentId'],
                        paymentPayerId: paypalResponce['data']['payer']['payer_info']['payer_id'],
                        paymentStatus: paypalResponce['status'],
                        createdAt: getCurrentDateTime())
                    .then(
                      (defaultResponseData) => {
                        if (defaultResponseData.status != null && defaultResponseData.status!)
                          {
                            paymentHistoryProvider.getPaymentHistory(
                                currentUserId: currentUserId, sortByCreated: sortByCreated, status: ""),
                            debugPrint('payment Success'),
                            Fluttertoast.showToast(
                                msg: defaultResponseData.message ??
                                    AppLocalizations.of(context)!.something_want_to_wrong,
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
                            debugPrint('payment field'),
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
                      },
                    );
              }
            },
            onError: (error) {
              Fluttertoast.showToast(
                  msg: error.toString(),
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            },
            onCancel: (params) {
              Fluttertoast.showToast(
                  msg: 'Payment Cancelled',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }),
      ),
    );
  }*/
}
