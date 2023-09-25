import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/Utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/utils_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/cash_payment_detail_view.dart';
import '../custom_widgets/paypal_payment_detail_bottam_sheet.dart';
import '../custom_widgets/stripe_payment_detail_bottam_sheet.dart';
import '../providers/payment_history_provider.dart';
import 'package:http/http.dart' as http;

class PaymentUtils {

  Future<void> checkUserPaymentStatus(
      {required BuildContext context, required paymentHistoryDoc, required String currentPaymentType}) async {
    final SharedPreferencesManager preference = SharedPreferencesManager();
    String userRole = await preference.getValue(prefUserRole, "");
    debugPrint('checkUserPaymentStatus userRole : $userRole');
    debugPrint(
        'checkUserPaymentStatus currentPaymentType : $currentPaymentType');
    PaymentHistoryProvider? paymentHistoryProvider;
    if (context.mounted) {
      paymentHistoryProvider =
          Provider.of<PaymentHistoryProvider>(context, listen: false);
    }
    QueryDocumentSnapshot? subCollectionData = await paymentHistoryProvider
        ?.getSingleSubTableDocument(paymentDocId: paymentHistoryDoc.id);

    if (paymentHistoryDoc[keyPaymentStatus] == paymentPaid &&
        paymentHistoryDoc[keyPaymentType] == paymentTypeStripe) {
      if (context.mounted) {
        showModalBottomSheet(
            context: context,
            enableDrag: false,
            isScrollControlled: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            builder: (context) =>
                StripePaymentDetailBottomSheet(
                  queryDocumentSnapshot: paymentHistoryDoc,
                  subCollectionData: subCollectionData,
                ));
      }
    } else if (currentPaymentType == paymentTypeStripe &&
        paymentHistoryDoc[keyPaymentStatus] == paymentUnPaid) {
      if (context.mounted) {
        await PaymentUtils().makePaymentForStripe(context: context,
            documentSnapshot: paymentHistoryDoc,
            userRole: userRole);
      }
    } else if (paymentHistoryDoc[keyPaymentStatus] == paymentPaid &&
        paymentHistoryDoc[keyPaymentType] == paymentTypePayPal) {
      //view paypal payment sheet
      if (context.mounted) {
        showModalBottomSheet(
            context: context,
            enableDrag: false,
            isScrollControlled: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            builder: (context) =>
                PayPalPaymentDetailBottamSheet(
                  queryDocumentSnapshot: paymentHistoryDoc,
                  subCollectionData: subCollectionData,
                ));
      }
    } else if (currentPaymentType == paymentTypePayPal &&
        paymentHistoryDoc[keyPaymentStatus] == paymentUnPaid) {
      //pay paypal payment sheet
      if (context.mounted) {
        makePaymentForPayPal(documentSnapshot: paymentHistoryDoc,
            context: context,
            userRole: userRole);
      }
    } else {
      if (context.mounted) {
        showModalBottomSheet(
            context: context,
            enableDrag: false,
            isScrollControlled: true,
            isDismissible: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            builder: (context) =>
                CashPaymentDetailView(
                  queryDocumentSnapshot: paymentHistoryDoc,
                ));
      }
    }
  }

  Future<void> makePaymentForStripe(
      {required BuildContext context, required QueryDocumentSnapshot documentSnapshot, required String userRole}) async {
    var amount = documentSnapshot.get(keyAmount) * 100;

    try {
      var paymentIntent = await createPaymentIntent(amount: amount.toString(),
          currency: (userRole == userRoleTrainer
              ? StaticData.currentCurrencyName
              : StaticData.currentTrainerCurrencyName),
          userRole: userRole,
          documentSnapshot: documentSnapshot,
          context: context);
      debugPrint('Payment userRole $userRole');
      /* var gpay = PaymentSheetGooglePay(
          merchantCountryCode: StaticData.currentCurrencyCountry,
          currencyCode: (userRole == userRoleTrainer ? StaticData
              .currentCurrencyName : StaticData.currentTrainerCurrencyName),
          testEnv: true);*/
      debugPrint('paymentId: ${documentSnapshot.id}');

      debugPrint("paymentIntent id : ${paymentIntent!['id']}");
      debugPrint("client secret : ${paymentIntent!['client_secret']}");
      debugPrint("currency : ${paymentIntent!['currency']}");
      debugPrint("status : ${paymentIntent!['status']}");
      debugPrint("amount : ${paymentIntent!['amount']}");
      //STEP 2: Initialize Payment Sheet

      Stripe.instance
          .initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          //Gotten from payment intent
          style: ThemeMode.light,
          customFlow: Platform.isIOS ? false :  true,
          // applePay: PaymentSheetApplePay(merchantCountryCode: userRole == userRoleTrainer
          //     ? StaticData.currentCurrencyCountry
          //     : StaticData.currentTrainerCurrencyCountry,
          //     buttonType: PlatformButtonType.order,cartItems: [ApplePayCartSummaryItem()]),
          merchantDisplayName: StaticData.appName,
          // googlePay: gpay,
        ),)
          .then((value) {
        debugPrint('displayPaymentSheet...');
        PaymentUtils().displayPaymentSheet(context: context,
            documentSnapshot: documentSnapshot,
            userRole: userRole, paymentIntentId: paymentIntent!['id']);
      });

      //STEP 3: Display Payment sheet

    } catch (err) {
      debugPrint("makePaymentForStripe error : ");
      debugPrint(err.toString());
    }
  }

  displayPaymentSheet(
      {required BuildContext context, required QueryDocumentSnapshot documentSnapshot, required String userRole, required paymentIntentId}) async {
    try {
      debugPrint("displayPaymentSheet : ");
      debugPrint('paymentIntentId : $paymentIntentId');
      Stripe.instance.presentPaymentSheet().then((value) {
        debugPrint('paymentIntentId : $paymentIntentId');
        debugPrint('Open Payment detail bottom sheet');
        Stripe.instance.confirmPaymentSheetPayment().then((value) =>
        {
          PaymentUtils().checkPaymentStatus(context: context,
              paymentIntentId: paymentIntentId,
              paymentDocId: documentSnapshot.id,
              userRole: userRole,
              currentUserId: documentSnapshot[keyUserId] ?? "")
        }).onError((error, stackTrace) =>
        {
          PaymentUtils().checkPaymentStatus(context: context,
              paymentIntentId: paymentIntentId,
              paymentDocId: documentSnapshot.id,
              userRole: userRole,
              currentUserId: documentSnapshot[keyUserId] ?? "")
        });
      });
    } catch (e) {
      debugPrint("displayPaymentSheet error : ");

      debugPrint(e.toString());
    }
  }

  createPaymentIntent(
      {required String amount, required String currency, required String userRole, required QueryDocumentSnapshot documentSnapshot, required BuildContext context,}) async {
    DocumentSnapshot? userDoc;
    if (context.mounted) {
      userDoc = await Provider.of<MemberProvider>(context, listen: false)
          .getSelectedMember(memberId: documentSnapshot.get(keyUserId));
    }
    if (getDocumentValue(documentSnapshot: userDoc!, key: keyName).isNotEmpty &&
        getDocumentValue(documentSnapshot: userDoc, key: keyAddress).isNotEmpty
        &&
        getDocumentValue(documentSnapshot: userDoc, key: keyCity).isNotEmpty &&
        getDocumentValue(documentSnapshot: userDoc, key: keyState).isNotEmpty
        && getDocumentValue(documentSnapshot: userDoc, key: keyZipCode)
            .isNotEmpty &&
        getDocumentValue(documentSnapshot: userDoc, key: keyCountryCodeName)
            .isNotEmpty) {
      try {
        Map<String, dynamic> body = {
          "use_stripe_sdk": "true",
          "amount": amount,
          "currency": currency,
          "description": "Pay for membership",
          "automatic_payment_methods[enabled]": "true",
          "shipping[name]": userDoc.get(keyName),
          "shipping[address][line1]": userDoc.get(keyAddress),
          "shipping[address][city]": userDoc.get(keyCity),
          "shipping[address][state]": userDoc.get(keyState),
          "shipping[address][postal_code]": userDoc.get(keyZipCode),
          "shipping[address][country]": userDoc.get(keyCountrySortName),
        };


        debugPrint("createPaymentIntent body : $body");
        var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
            'Authorization': 'Bearer ${(userRole == userRoleTrainer ? StaticData
                .stripeSecretKey : StaticData.stripeTrainerSecretKey)}',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: body,
        );
        // debugPrint('createPaymentIntent body : ${body}');
        debugPrint('createPaymentIntent : ${json.decode(response.body)}');
        debugPrint('StatusCode : ${response.statusCode}');
        return json.decode(response.body);
      } catch (err) {
        debugPrint("show Error Message : ${err.toString()}");
        throw Exception(err.toString());
      }
    } else {
      if(context.mounted) {
        Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!
                .please_add_your_address_city_postelCode_state_and_country_for_payment,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      return;
    }
  }

  Future<bool> checkPaymentStatus(
      {required BuildContext context, required String paymentIntentId, required String paymentDocId, required String userRole, required String currentUserId}) async {
    PaymentHistoryProvider paymentHistoryProvider = Provider.of<
        PaymentHistoryProvider>(context, listen: false);
    final url = 'https://api.stripe.com/v1/payment_intents/$paymentIntentId';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${(userRole == userRoleTrainer ? StaticData
            .stripeSecretKey : StaticData.stripeTrainerSecretKey)}',
      },
    );

    debugPrint("response.body : ${response.body}");
    final responseData = jsonDecode(response.body);
    // debugPrint("error Message : ${responseData["last_payment_error"]["message"]}",);
    if (response.statusCode == 200) {
      final status = responseData['status'];
      if (status == 'succeeded') {
        debugPrint('123');
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
              (defaultResponseData) async =>
          {
            if (defaultResponseData.status != null &&
                defaultResponseData.status!)
              {
/*
                if(userRole == userRoleTrainer){
*/
                  await paymentHistoryProvider.getPaymentHistory(
                      currentUserId: currentUserId,
                      sortByCreated: true,
                      status: ""),/*} */
               /* else
                  {*/
                    await paymentHistoryProvider.getMemberPayment(
                      currentUserId: currentUserId,
                    ),/*},*/
                debugPrint("is refresh123"),
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
                debugPrint('456'),
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
      } else {
        if(context.mounted) {
          String errorMessage = AppLocalizations.of(context)!.payment_failed;
          if (responseData["last_payment_error"] != null &&
              responseData["last_payment_error"]["message"] != null) {
            errorMessage = responseData["last_payment_error"]["message"];
          }

          Fluttertoast.showToast(
              msg: errorMessage,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
      return status ==
          'succeeded'; // Return true if payment succeeded, false otherwise
    } else {
      throw Exception('Failed to retrieve payment intent.');
    }
  }

  Future<void> makePaymentForPayPal(
      {required BuildContext context, required QueryDocumentSnapshot documentSnapshot, required userRole}) async {
    PaymentHistoryProvider paymentHistoryProvider = Provider.of<
        PaymentHistoryProvider>(context, listen: false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            UsePaypal(
                sandboxMode: true,
                clientId: userRole == userRoleTrainer ? StaticData
                    .paypalClientId : StaticData.paypalTrainerClientId,
                secretKey: userRole == userRoleTrainer ? StaticData
                    .paypalSecretKey : StaticData.paypalTrainerSecretKey,
                returnURL: "https://samplesite.com/return",
                cancelURL: "https://samplesite.com/cancel",
                transactions: [
                  {
                    "amount": {
                      "total": (documentSnapshot[keyAmount]).toString(),
                      "currency": userRole == userRoleTrainer ? StaticData
                          .currentCurrencyName : StaticData
                          .currentTrainerCurrencyName,
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
                          "currency": userRole == userRoleTrainer ? StaticData
                              .currentCurrencyName : StaticData
                              .currentTrainerCurrencyName,
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
                          (defaultResponseData) async =>
                      {
                        if (defaultResponseData.status != null &&
                            defaultResponseData.status!)
                          {
                            /*if(userRole == userRoleTrainer){*/
                            await paymentHistoryProvider.getPaymentHistory(
                                  currentUserId: documentSnapshot[keyUserId] ??
                                      "",
                                  sortByCreated: true,
                                  status: ""),/*}*/
                            /*else
                              {*/
                            await paymentHistoryProvider.getMemberPayment(
                                  currentUserId: documentSnapshot[keyUserId] ??
                                      "",
                                ),/*},*/
                            debugPrint('payment Success'),
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
                            debugPrint('payment field'),
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
                      msg: AppLocalizations.of(context)!.payment_failed,
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 3,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }),
      ),
    );
  }
}