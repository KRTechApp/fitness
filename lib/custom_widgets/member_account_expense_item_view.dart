import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../mobile_pages/account_invoice_list_bottom_sheet.dart';
import '../providers/trainer_provider.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import 'custom_card.dart';

class MemberAccountExpenseItemView extends StatefulWidget {
  final String trainerName;
  final String userRole;
  final String userId;
  final bool sortByCreated;
  final String status;
  final QueryDocumentSnapshot queryDocumentSnapshot;

  const MemberAccountExpenseItemView(
      {super.key,
      required this.trainerName,
      required this.userRole,
      required this.userId,
      required this.sortByCreated,
      required this.status,
      required this.queryDocumentSnapshot});

  @override
  State<MemberAccountExpenseItemView> createState() => _MemberAccountExpenseItemViewState();
}

class _MemberAccountExpenseItemViewState extends State<MemberAccountExpenseItemView> {
  late TrainerProvider trainerProvider;

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: GestureDetector(
        onTap: () {
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
              trainerName: widget.trainerName,
              adminName: widget.trainerName,
              sortByCreated: widget.sortByCreated,
              createdBy: widget.userId,
              status: widget.status,
              userRole: widget.userRole,
              viewtype: "",
              isPay: "",
            ),
          );
        },
        child: Column(
          children: [
            customCard(
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
                        'assets/images/income.svg',
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 45.w,
                          child: Text(widget.trainerName, maxLines: 1, style: GymStyle.listTitle),
                          // Text('Bendial Joseph', maxLines: 1, style: GymStyle.listSubTitle),
                        ),
                        SizedBox(
                          width: 45.w,
                          child: Text(AppLocalizations.of(context)!.trainer_fees_payment,
                              maxLines: 1, style: GymStyle.listSubTitle),
                        ),
                        SizedBox(
                          width: 45.w,
                          child: Text('${StaticData.currentTrainerCurrency} ${widget.queryDocumentSnapshot[keyAmount] ?? ""} ',
                              maxLines: 1, style: GymStyle.membershipprice),
                        ),
                      ],
                    ),
                    const Spacer(),
/*
                              Container(
                                alignment: Alignment.center,
                                child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(50),
                                    ),
                                    splashColor: ColorCode.linearProgressBar,
                                    onTap: () {
                                     */
/* paymentHistoryProvider.deletePayment(paymentId: documentSnapshot.id);
                                      Navigator.pop(context);*/ /*

                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(15, 15, 10, 15),
                                      child: SvgPicture.asset('assets/images/delete.svg'),
                                    )),
                              ),
*/
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
          ],
        ),
      ),
    );
  }
}
