import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../custom_widgets/custom_card.dart';
import '../mobile_pages/account_invoice_list_bottom_sheet.dart';
import '../providers/payment_history_provider.dart';
import '../providers/trainer_provider.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class TrainerAccountExpenseItemView extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final String userId;
  final String userRole;
  final String status;
  final bool sortByCreated;

  const TrainerAccountExpenseItemView(
      {Key? key,
      required this.queryDocumentSnapshot,
      required this.userId,
      required this.userRole,
      required this.status,
      required this.sortByCreated})
      : super(key: key);

  @override
  State<TrainerAccountExpenseItemView> createState() => _TrainerAccountExpenseItemViewState();
}

class _TrainerAccountExpenseItemViewState extends State<TrainerAccountExpenseItemView> {
  late TrainerProvider trainerProvider;
  late PaymentHistoryProvider paymentHistoryProvider;
  late ShowProgressDialog showProgressDialog;

  var userName = "";

  @override
  void initState() {
    super.initState();
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    showProgressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Date: ${widget.queryDocumentSnapshot[keyCreatedAt] ?? ""}');
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15),
      child: Column(
        children: [
          InkWell(
            onTap: widget.userRole != userRoleMember
                ? () {
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
                      builder: (context) => AccountInvoiceListBottomSheet(
                        queryDocumentSnapshot: widget.queryDocumentSnapshot,
                        trainerName: userName,
                        adminName: userName,
                        sortByCreated: widget.sortByCreated,
                        createdBy: widget.userId,
                        status: widget.status,
                        userRole: widget.userRole,
                        viewtype: "",
                        isPay: "pay",
                      ),
                    );
                  }
                : null,
            child: customCard(
              blurRadius: 5,
              radius: 15,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        fit: BoxFit.contain,
                        widget.queryDocumentSnapshot[keyPaymentStatus] == "unpaid"
                            ? 'assets/images/unpaid.svg'
                            : 'assets/images/paid.svg',
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                            width: width * 0.46,
                            child: FutureBuilder(
                              future: trainerProvider.getSingleTrainer(
                                userId: widget.queryDocumentSnapshot[keyCreatedBy] ?? "",
                              ),
                              builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                                if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                  var queDoc = asyncSnapshot.data;
                                  userName = queDoc![keyName];
                                  return Text(userName, maxLines: 1, style: GymStyle.listTitle);
                                }
                                return Text('N/A', style: GymStyle.listTitle);
                              },
                            )
                            // Text( widget.queryDocumentSnapshot[keyCreatedBy] ?? "", maxLines: 1, style: GymStyle.listTitle),
                            ),
                        SizedBox(
                          width: width * 0.46,
                          child: RichText(
                            text: TextSpan(
                              text: widget.queryDocumentSnapshot[keyInvoiceNo] ?? "",
                              style: GymStyle.listSubTitle,
                              children: <TextSpan>[
                                const TextSpan(
                                  text: ' | ',
                                ),
                                TextSpan(
                                    text: DateFormat(StaticData.currentDateFormat).format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            widget.queryDocumentSnapshot[keyCreatedAt] ?? 0)),
                                    style: GymStyle.listSubTitle),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.46,
                          child: Text(widget.queryDocumentSnapshot[keyMembershipName] ?? "",
                              maxLines: 1, style: GymStyle.listSubTitle),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      alignment: Alignment.center,
                      child: InkWell(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                          splashColor: ColorCode.linearProgressBar,
                          onTap: () {
                            deletePopup(widget.queryDocumentSnapshot);
                            // showProgressDialog.hide();
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 10, 15),
                            child: SvgPicture.asset('assets/images/delete.svg'),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: height * 0.01,
          ),
        ],
      ),
    );
  }

  deletePopup(QueryDocumentSnapshot documentSnapshot) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    showDialog(
      barrierColor: Colors.black.withOpacity(0.7),
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Container(
                padding: const EdgeInsets.all(30),
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF000E).withOpacity(0.20),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset('assets/images/delete.svg'),
              ),
              SizedBox(
                height: height * 0.02,
              ),
              Text(AppLocalizations.of(context)!.are_you_sure_want_to_delete, style: GymStyle.inputTextBold),
              Text((documentSnapshot[keyMembershipName] ?? "") + '?', style: GymStyle.inputTextBold),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                children: [
                  Container(
                    width: width * 0.3,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: ColorCode.mainColor,
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.cancel.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.mainColor,
                            fontSize: getFontSize(17),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.04,
                  ),
                  Container(
                    width: width * 0.3,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCode.mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        paymentHistoryProvider.deletePayment(paymentId: documentSnapshot.id);
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.delete.toUpperCase(),
                        style: TextStyle(
                            color: ColorCode.white,
                            fontSize: getFontSize(17),
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
