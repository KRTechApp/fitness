import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/trainer_provider.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import 'dashboard_screen.dart';
import 'member_account_expense_screen.dart';
import 'member_account_invoice_screen.dart';

class AccountMemberScreen extends StatefulWidget {
  const AccountMemberScreen({Key? key}) : super(key: key);

  @override
  State<AccountMemberScreen> createState() => _AccountMemberScreenState();
}

class _AccountMemberScreenState extends State<AccountMemberScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TrainerProvider trainerProvider;
  DocumentSnapshot? trainerDoc;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";
  String userCreatedBy = "";
  String userName = "";
  late ShowProgressDialog showProgressDialog;

  @override
  void initState() {
    super.initState();
    trainerProvider = Provider.of<TrainerProvider>(context, listen: false);
    showProgressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = await _preference.getValue(prefUserId, "");
      userRole = await _preference.getValue(prefUserRole, "");
      userCreatedBy = await _preference.getValue(prefCreatedBy, "");
      trainerDoc =
          await trainerProvider.getSingleTrainer(userId: userCreatedBy);
      userName = trainerDoc![keyName] ?? "";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
          title: Text(AppLocalizations.of(context)!.account),
        ),
        body: Column(
          children: [
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: isDarkTheme
                          ? ColorCode.socialLoginBackground
                          : ColorCode.tabBarBackground),
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: 2,
                    child: Column(
                      children: [
                        SizedBox(
                          width: width,
                          height: 40,
                          child: TabBar(
                            indicatorColor: ColorCode.backgroundColor,
                            indicatorPadding: const EdgeInsets.only(
                                top: 37, left: 10, right: 10),
                            tabs: [
                              Tab(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .invoice
                                      .allInCaps,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .expense
                                      .allInCaps,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: width,
                          height: height - 157,
                          color: isDarkTheme
                              ? ColorCode.backgroundColor
                              : ColorCode.white,
                          child: TabBarView(
                            children: <Widget>[
                              MemberAccountInvoiceScreen(
                                  trainerName: userName,
                                  userId: userId,
                                  userRole: userRole,
                                  key: UniqueKey(),
                                  showProgressDialog: showProgressDialog),
                              MemberAccountExpenseScreen(
                                  trainerName: userName,
                                  key: UniqueKey(),
                                  showProgressDialog: showProgressDialog),
                              // TrainerAccountExpenseScreen(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }
}
