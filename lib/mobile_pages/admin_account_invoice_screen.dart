import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import 'account_invoice_item_view.dart';

class AdminAccountInvoiceScreen extends StatefulWidget {
  final ShowProgressDialog showProgressDialog;
  const AdminAccountInvoiceScreen({
    Key? key, required this.showProgressDialog,
  }) : super(key: key);

  @override
  State<AdminAccountInvoiceScreen> createState() => _AdminAccountInvoiceScreenState();
}

class _AdminAccountInvoiceScreenState extends State<AdminAccountInvoiceScreen> {
  String? selectedValueByFilter;
  String? selectedValueBySort;
  late PaymentHistoryProvider paymentHistoryProvider;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";
  bool sortByCreated = true;
  String status = "";

  @override
  void initState() {
    super.initState();
    paymentHistoryProvider = Provider.of<PaymentHistoryProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = await _preference.getValue(prefUserId, "");
      userRole = await _preference.getValue(prefUserRole, "");
      debugPrint('ID132: $userId');
      _pullRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final List<String> filterType = [
      AppLocalizations.of(context)!.all.allInCaps,
      AppLocalizations.of(context)!.paid.allInCaps,
      AppLocalizations.of(context)!.un_paid.allInCaps,
    ];
    final List<String> sortBy = [
      AppLocalizations.of(context)!.newest_first,
      AppLocalizations.of(context)!.oldest_first,
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 15, left: 15,right:15),
              height: 40,
              width: 151,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xff6842FF), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  hint: Text(
                    AppLocalizations.of(context)!.all.allInCaps,
                    style: GymStyle.exerciseLableText,
                  ),
                  items: filterType
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: GymStyle.exerciseLableText,
                          ),
                        ),
                      )
                      .toList(),
                  value: selectedValueByFilter,
                  onChanged: (value) {
                    setState(
                      () {
                        selectedValueByFilter = value as String;
                        int selectedIndex = filterType.indexWhere((element) => element == selectedValueByFilter);
                        if (selectedIndex == 1) {
                          status = 'paid';
                        } else if (selectedIndex == 2) {
                          status = 'unpaid';
                        } else {
                          status = "";
                        }
                      },
                    );
                    paymentHistoryProvider.getCreatedPaymentHistory(
                        currentUserId: userId, sortByCreated: sortByCreated, status: status);
                  },
                  icon: const Icon(Icons.expand_more, color: Colors.black, size: 30),
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.only(top: 15, right: 15,left:15),
              height: 40,
              width: 156,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xff6842FF), width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  hint: Text(
                    AppLocalizations.of(context)!.newest_first,
                    style: GymStyle.exerciseLableText,
                  ),
                  items: sortBy
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: GymStyle.exerciseLableText,
                          ),
                        ),
                      )
                      .toList(),
                  value: selectedValueBySort,
                  onChanged: (value) {
                    setState(
                      () {
                        selectedValueBySort = value as String;
                        int selectIndex = sortBy.indexWhere((element) => element == selectedValueBySort);
                        if (selectIndex == 0) {
                          sortByCreated = true;
                        } else {
                          sortByCreated = false;
                        }
                      },
                    );
                    paymentHistoryProvider.getCreatedPaymentHistory(
                        currentUserId: userId, sortByCreated: sortByCreated, status: status);
                  },
                  icon: const Icon(Icons.expand_more, color: Colors.black, size: 30),
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
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
                          userId: userId,
                          userRole: userRole,
                          sortByCreated: sortByCreated,
                          status: status,
                          trainerName: "",
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
          ),
      ],
    );
  }

  Future<void> _pullRefresh() async {
    widget.showProgressDialog.show();
    await paymentHistoryProvider.getCreatedPaymentHistory(
        currentUserId: userId, sortByCreated: sortByCreated, status: status);
    widget.showProgressDialog.hide();
    setState(() {
    });
  }
}
