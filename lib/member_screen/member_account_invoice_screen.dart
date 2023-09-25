import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/color_code.dart';
import '../mobile_pages/account_invoice_item_view.dart';
import '../providers/payment_history_provider.dart';
import '../utils/show_progress_dialog.dart';

class MemberAccountInvoiceScreen extends StatefulWidget {
  final String userId;
  final String userRole;
  final String trainerName;
  final ShowProgressDialog showProgressDialog;

  const MemberAccountInvoiceScreen(
      {Key? key,
      required this.userId,
      required this.userRole,
      required this.trainerName,
      required this.showProgressDialog})
      : super(key: key);

  @override
  State<MemberAccountInvoiceScreen> createState() => _MemberAccountInvoiceScreenState();
}

class _MemberAccountInvoiceScreenState extends State<MemberAccountInvoiceScreen> {
  late PaymentHistoryProvider paymentHistoryProvider;
  bool sortByCreated = true;
  String status = "";

  @override
  void initState() {
    super.initState();
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _pullRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      height: height - 212,
      child: Consumer<PaymentHistoryProvider>(
        builder: (context, paymentData, child) => paymentData.paymentHistoryItemList.isNotEmpty
            ? ListView.builder(
                itemCount: paymentData.paymentHistoryItemList.length,
                padding: const EdgeInsets.only(top: 15),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final QueryDocumentSnapshot documentSnapshot = paymentData.paymentHistoryItemList[index];
                  return AccountInvoiceItemView(
                    queryDocumentSnapshot: documentSnapshot,
                    userId: widget.userId,
                    userRole: widget.userRole,
                    sortByCreated: sortByCreated,
                    status: status,
                    trainerName: widget.trainerName,
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
                      child: Image.asset('assets/images/empty_box.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                      child: Text(
                        AppLocalizations.of(context)!.you_do_not_have_any_payment_history,
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
    );
  }

  Future<void> _pullRefresh() async {
    widget.showProgressDialog.show();
    debugPrint("is refresh");
    await paymentHistoryProvider.getMemberPayment(
      currentUserId: widget.userId,
    );
    widget.showProgressDialog.hide();
    setState(() {});
  }
}
