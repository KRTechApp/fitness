import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../Utils/shared_preferences_manager.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../utils/tables_keys_values.dart';
import 'trainer_account_expense_screen.dart';
import 'trainer_account_income_screen.dart';
import 'trainer_account_invoice_screen.dart';
import 'trainer_dashboard_screen.dart';

class TrainerAccountScreen extends StatefulWidget {
  const TrainerAccountScreen({Key? key}) : super(key: key);

  @override
  State<TrainerAccountScreen> createState() => _TrainerAccountScreenState();
}

class _TrainerAccountScreenState extends State<TrainerAccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MemberProvider memberProvider;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog showProgressDialog;
  String switchRole = "";

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    showProgressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var userId = await _preference.getValue(prefUserId, "");
      switchRole = await _preference.getValue(keySwitchRole, "");
      debugPrint('switchRole $switchRole');
      showProgressDialog.show();
      await memberProvider.getMemberOfTrainer(createdById: userId, isRefresh: true);
      showProgressDialog.hide();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
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
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
          title:  Text(AppLocalizations.of(context)!.account),
        ),
        body: Column(
          children: [
            SizedBox(
              height: height * 0.02,
            ),
            Row(
              children: [
                Container(
                  decoration:
                      BoxDecoration(color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.tabBarBackground),
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: switchRole == userRoleAdmin ? 2 : 3,
                    child: Column(
                      children: [
                        SizedBox(
                          width: width,
                          height: 40,
                          child: TabBar(
                            indicatorColor: ColorCode.backgroundColor,
                            indicatorPadding: const EdgeInsets.only(top: 37, left: 10, right: 10),
                            tabs: [
                              Tab(
                                child: Text(
                                  AppLocalizations.of(context)!.invoice.allInCaps,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  AppLocalizations.of(context)!.income.allInCaps,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                              if (switchRole != userRoleAdmin)
                                Tab(
                                  child: Text(
                                    AppLocalizations.of(context)!.expense.allInCaps,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: width,
                          height: height - 157,
                          color: isDarkTheme ? ColorCode.backgroundColor : ColorCode.white,
                          child: TabBarView(
                            children: <Widget>[
                              TrainerAccountInvoiceScreen(showProgressDialog: showProgressDialog),
                              TrainerAccountIncomeScreen(showProgressDialog: showProgressDialog),
                              if (switchRole != userRoleAdmin)
                                TrainerAccountExpenseScreen(showProgressDialog: showProgressDialog),
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

  @override
  void dispose() {
    super.dispose();
  }
}
