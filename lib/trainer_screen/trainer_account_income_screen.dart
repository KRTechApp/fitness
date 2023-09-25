import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../custom_widgets/trainer_account_income_item_view.dart';
import '../providers/payment_history_provider.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';

class TrainerAccountIncomeScreen extends StatefulWidget {
  final ShowProgressDialog showProgressDialog;

  const TrainerAccountIncomeScreen({Key? key, required this.showProgressDialog}) : super(key: key);

  @override
  State<TrainerAccountIncomeScreen> createState() => _TrainerAccountIncomeScreenState();
}

class _TrainerAccountIncomeScreenState extends State<TrainerAccountIncomeScreen> {
  late PaymentHistoryProvider paymentHistoryProvider;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";
  bool sortByCreated = true;

  @override
  void initState() {
    super.initState();
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = await _preference.getValue(prefUserId, "");
      userRole = await _preference.getValue(prefUserRole, "");
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
                  return TrainerAccountIncomeItemView(
                    sortByCreated: sortByCreated,
                    userId: userId,
                    status: "",
                    documentSnapshot: documentSnapshot,
                    userRole: userRole,
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
                    const Padding(
                      padding: EdgeInsets.only(left: 17.0, right: 17, top: 15),
                      child: Text(
                        "You don't have any Income History",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
              Text('${AppLocalizations.of(context)!.trainer_fees_payment}?', style: GymStyle.inputTextBold),
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
                        // trainerProvider.deleteTrainer(trainerId: documentSnapshot.id);
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

  Future<void> _pullRefresh() async {
    widget.showProgressDialog.show();
    await paymentHistoryProvider.getCreatedPaymentHistory(
        currentUserId: userId, sortByCreated: sortByCreated, status: "");
    widget.showProgressDialog.hide();
    setState(() {});
  }
}
