import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../mobile_pages/account_invoice_list_bottom_sheet.dart';
import '../providers/member_provider.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import 'custom_card.dart';

class TrainerAccountIncomeItemView extends StatefulWidget {
  final String userRole;
  final QueryDocumentSnapshot documentSnapshot;
  final String status;
  final bool sortByCreated;
  final String userId;

  const TrainerAccountIncomeItemView(
      {super.key,
      required this.userRole,
      required this.documentSnapshot,
      required this.status,
      required this.sortByCreated,
      required this.userId});

  @override
  State<TrainerAccountIncomeItemView> createState() => _TrainerAccountIncomeItemViewState();
}

class _TrainerAccountIncomeItemViewState extends State<TrainerAccountIncomeItemView> {
  late MemberProvider memberProvider;
  var userName = "";

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: GestureDetector(
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
                    queryDocumentSnapshot: widget.documentSnapshot,
                    trainerName: userName,
                    adminName: userName,
                    sortByCreated: widget.sortByCreated,
                    createdBy: widget.userId,
                    status: widget.status,
                    userRole: widget.userRole,
                    viewtype: "",
                    isPay: "",
                  ),
                );
              }
            : null,
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
                            width: width * 0.46,
                            child: FutureBuilder(
                              future: memberProvider.getMemberFromId(
                                  createdById: widget.userId, userId: widget.documentSnapshot.get(keyUserId)),
                              builder: (context, AsyncSnapshot<DocumentSnapshot?> asyncSnapshot) {
                                if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                                  var queDoc = asyncSnapshot.data;
                                  userName = queDoc![keyName];
                                  return Text(userName,
                                      overflow: TextOverflow.ellipsis, maxLines: 1, style: GymStyle.listTitle);
                                }
                                return Text('N/A', style: GymStyle.listTitle);
                              },
                            )
                            // Text('Bendial Joseph', maxLines: 1, style: GymStyle.listSubTitle),
                            ),
                        SizedBox(
                          width: width * 0.46,
                          child: Text(AppLocalizations.of(context)!.trainer_fees_payment,
                              overflow: TextOverflow.ellipsis, maxLines: 1, style: GymStyle.listSubTitle),
                        ),
                        SizedBox(
                          width: width * 0.46,
                          child: Text('${StaticData.currentCurrency} ${widget.documentSnapshot[keyAmount] ?? ""} ',
                              maxLines: 1, style: GymStyle.listSubTitle),
                        ),
                      ],
                    ),
                    const Spacer(),
                    /* Container(
                                        alignment: Alignment.center,
                                        child: InkWell(
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(50),
                                            ),
                                            splashColor: ColorCode.linearProgressBar,
                                            onTap: () {
                                              // Navigator.pop(context);
                                              deletePopup(documentSnapshot);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(5, 15, 10, 15),
                                              child: SvgPicture.asset('assets/images/delete.svg'),
                                            )),
                                      ),*/
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
