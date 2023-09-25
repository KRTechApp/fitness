import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/gym_style.dart';
import '../Utils/color_code.dart';
import '../providers/trainer_provider.dart';
import '../utils/payment_utils.dart';
import '../utils/static_data.dart';

class AccountInvoiceListBottomSheet extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final String trainerName;
  final String adminName;
  final String createdBy;
  final String userRole;
  final String status;
  final bool sortByCreated;
  final String viewtype;
  final String isPay;

  const AccountInvoiceListBottomSheet({
    Key? key,
    required this.queryDocumentSnapshot,
    required this.trainerName,
    required this.sortByCreated,
    required this.createdBy,
    required this.status,
    required this.adminName,
    required this.userRole,
    required this.viewtype,
    required this.isPay,
  }) : super(key: key);

  @override
  State<AccountInvoiceListBottomSheet> createState() => _AccountInvoiceListBottomSheetState();
}

class _AccountInvoiceListBottomSheetState extends State<AccountInvoiceListBottomSheet> {
  late TrainerProvider trainerProvider;
  String trainerName = "";
  String? selectedValue;
  var paidStatus = "";
  var oldPaidStatus = "";
  var oldExtendDate = "";
  late PaymentHistoryProvider paymentHistoryProvider;
  late ShowProgressDialog showProgressDialog;
  var extendDateController = TextEditingController();
  var startDateMillisecond = 0;

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    showProgressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        /* userId = await _preference.getValue(prefUserId, "");
      DocumentSnapshot documentSnapshot =
          await trainerProvider.getSingleTrainer(prefUserId: widget.documentSnapshot![keyCreatedBy],);
      debugPrint("widget.documentSnapshots DATA${documentSnapshot.id.toString()}");
      setState(() {
        trainerName = documentSnapshot.get(keyName);
      },);*/
        debugPrint("widget.documentSnapshots DATA${widget.queryDocumentSnapshot[keyExtendDate].toString()}");
        debugPrint("widget.documentSnapshots DATA${widget.queryDocumentSnapshot.id}");
        paidStatus = widget.queryDocumentSnapshot[keyPaymentStatus] ?? "";
        oldPaidStatus = widget.queryDocumentSnapshot[keyPaymentStatus] ?? "";
        selectedValue =
            paidStatus == paymentPaid ? AppLocalizations.of(context)!.paid : AppLocalizations.of(context)!.un_paid;

        extendDateController.text = (widget.queryDocumentSnapshot[keyExtendDate] ?? 0).toString();
        oldExtendDate = (widget.queryDocumentSnapshot[keyExtendDate] ?? 0).toString();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final List<String> paymentStatus = [
      AppLocalizations.of(context)!.paid,
      AppLocalizations.of(context)!.un_paid,
    ];
    return Container(
      // height: height * 0.6,
      width: width,
      margin: const EdgeInsets.only(top: 30),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, bottom: 30),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset('assets/images/arrow-left.svg'),
                  ),
                  SizedBox(width: width * 0.03),
                  Text(
                    widget.queryDocumentSnapshot[keyMembershipName] ?? "",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.invoice_id.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(widget.queryDocumentSnapshot[keyInvoiceNo] ?? "", style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.date.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(
                            DateFormat(StaticData.currentDateFormat).format(
                                DateTime.fromMillisecondsSinceEpoch(widget.queryDocumentSnapshot[keyCreatedAt] ?? 0)),
                            style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.extend_days.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                          width: width * 0.45,
                          child: widget.viewtype == "invoice"
                              ? TextFormField(
                                  keyboardType: TextInputType.number,
                                  // autovalidateMode: AutovalidateMode.onUserInteraction,
                                  controller: extendDateController,
                                  readOnly: widget.userRole == userRoleMember ? true : false,
                                  style: GymStyle.exerciseLableText,
                                  cursorColor: ColorCode.mainColor,
                                  maxLength: 2,
                                  decoration: InputDecoration(
                                    counterText: "",
                                    /*focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),*/
                                    border: InputBorder.none,
                                    hintStyle: GymStyle.popupbox,
                                  ),
                                )
                              : Text((widget.queryDocumentSnapshot[keyExtendDate] ?? 0).toString(),
                                  style: GymStyle.exerciseLableText)),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.name.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text(
                            widget.userRole == userRoleTrainer
                                ? widget.trainerName
                                : widget.userRole == userRoleMember
                                    ? widget.trainerName
                                    : widget.adminName,
                            maxLines: 1,
                            style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  if (widget.viewtype == "invoice" && widget.userRole != userRoleMember)
                    const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  if (widget.viewtype == "invoice" && widget.userRole != userRoleMember)
                    Row(
                      children: [
                        Text(AppLocalizations.of(context)!.status.allInCaps, maxLines: 1, style: GymStyle.boldText),
                        const Spacer(),
                        SizedBox(
                          width: width * 0.45,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              buttonWidth: width,
                              hint: Text(
                                widget.queryDocumentSnapshot[keyPaymentStatus] ?? "",
                                style: GymStyle.popupbox,
                              ),
                              items: paymentStatus
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: GymStyle.popupbox,
                                        ),
                                      ))
                                  .toList(),
                              value: selectedValue,
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value as String;
                                });
                                paidStatus =
                                    selectedValue == AppLocalizations.of(context)!.paid ? paymentPaid : paymentUnPaid;
                              },
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),

                        /* SizedBox(
                        width: width * 0.45,
                        child:
                            Text(AppLocalizations.of(context)!.paid.allInCaps, maxLines: 1, style: GymStyle.popupbox),
                      ),*/
                      ],
                    ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  Row(
                    children: [
                      Text(AppLocalizations.of(context)!.amount.allInCaps, maxLines: 1, style: GymStyle.boldText),
                      const Spacer(),
                      SizedBox(
                        width: width * 0.45,
                        child: Text((widget.queryDocumentSnapshot[keyAmount] ?? "").toString(),
                            maxLines: 1, style: GymStyle.popupbox),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFE1E3E6), thickness: 1, height: 25),
                  const SizedBox(
                    height: 15,
                  ),
                  if (widget.viewtype == "invoice" && widget.userRole != userRoleMember)
                    SizedBox(
                      height: height * 0.08,
                      width: width * 0.9,
                      child: ElevatedButton(
                        onPressed: () {
                          if (oldPaidStatus != paidStatus.toString() ||
                              extendDateController.text.trim().toString() != oldExtendDate) {
                            showProgressDialog.show();
                            paymentHistoryProvider
                                .updatePaymentStatus(
                                    paymentId: widget.queryDocumentSnapshot.id,
                                    currentUserId: widget.createdBy,
                                    sortByCreated: widget.sortByCreated,
                                    paymentStatus: paidStatus.toString(),
                                    extendedDays: int.parse(extendDateController.text.trim().toString()),
                                    status: widget.status)
                                .then((defaultResponseData) => {
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
                                          Navigator.pop(context),
                                        }
                                      else
                                        {
                                          showProgressDialog.hide(),
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
                                    });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: const Color(0xFF6842FF),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.save.toUpperCase(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                  if (widget.isPay == "pay" &&
                      oldPaidStatus != AppLocalizations.of(context)!.paid &&
                      widget.userRole != userRoleAdmin)
                    SizedBox(
                      height: height * 0.08,
                      width: width * 0.9,
                      child: ElevatedButton(
                        onPressed: () async {
                          debugPrint('PaymentType: ${StaticData.paymentType}');
                          debugPrint('widget.userRole: ${widget.userRole}');
                          debugPrint('PaymentTrainerType: ${StaticData.paymentTrainerType}');
                          PaymentUtils().checkUserPaymentStatus(
                              context: context,
                              paymentHistoryDoc: widget.queryDocumentSnapshot,
                              currentPaymentType: widget.userRole == userRoleTrainer
                                  ? StaticData.paymentType
                                  : StaticData.paymentTrainerType);
                          // Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: const Color(0xFF6842FF),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.pay.toUpperCase(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
