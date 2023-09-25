import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/membership_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../admin_screen/add_trainer_package_screen.dart';
import '../admin_screen/admin_dashboard_screen.dart';
import '../custom_widgets/membership_list_item_view.dart';
import '../main.dart';
import '../member_screen/dashboard_screen.dart';
import '../trainer_screen/trainer_add_membership.dart';
import '../trainer_screen/trainer_dashboard_screen.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import 'main_drawer_screen.dart';

class TrainerPackageListScreen extends StatefulWidget {
  final bool drawerList;
   const TrainerPackageListScreen({Key? key, required this.drawerList}) : super(key: key);

  @override
  State<TrainerPackageListScreen> createState() => _TrainerPackageListScreenState();
}

class _TrainerPackageListScreenState extends State<TrainerPackageListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MembershipProvider membershipProvider;
  late ShowProgressDialog progressDialog;
  bool searchVisible = false;
  var textSearchController = TextEditingController();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userRole = "";
  String currentUserId = "";
  String createdBy = "";
  bool dList = true;

  @override
  void initState() {
    super.initState();
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userRole = await _preference.getValue(prefUserRole, "");
        currentUserId = await _preference.getValue(prefUserId, "");
        createdBy = await _preference.getValue(prefCreatedBy, "");
        progressDialog.show();
        if (userRole == userRoleMember) {
          await membershipProvider.getMembershipList(isRefresh: true, createdById: createdBy);
        } else {
          await membershipProvider.getMembershipList(isRefresh: true, createdById: currentUserId);
        }
        progressDialog.hide();
        setState(
          () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        if(widget.drawerList) {
          userRole == userRoleTrainer
              ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TrainerDashboardScreen()),
                  (Route<dynamic> route) => false)
              : userRole == userRoleAdmin
                  ? Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()), (Route<dynamic> route) => false)
                  : Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      (Route<dynamic> route) => false);
        }

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
          title: Text(userRole == userRoleAdmin
              ? AppLocalizations.of(context)!.trainer_packages
              : AppLocalizations.of(context)!.membership_plan),
          actions: [
            InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                setState(
                  () {
                    searchVisible = !searchVisible;
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
                child: SvgPicture.asset(
                  height: 25,
                  width: 25,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
            if (userRole != userRoleMember)
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: InkWell(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(50),
                  ),
                  splashColor: ColorCode.linearProgressBar,
                  onTap: () {
                    userRole == userRoleAdmin
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTrainerPackageScreen(
                                documentSnapshot: null,
                                viewType: "Add",
                              ),
                            ),
                          )
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TrainerAddMemberShip(
                                documentSnapshot: null,
                                viewType: "Add",
                              ),
                            ),
                          );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SvgPicture.asset(
                      height: 20,
                      width: 20,
                      'assets/images/ic_add.svg',
                      color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: SizedBox(
            height: height,
            width: width,
            child: RefreshIndicator(
              onRefresh: pullRefresh,
              child: Column(
                children: [
                  if (searchVisible)
                    Card(
                      // elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFD9E1ED),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          controller: textSearchController,
                          cursorColor: ColorCode.mainColor,
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              onSearchTextChanged(
                                value.trim(),
                              );
                            } else {
                              onSearchTextChanged("");
                            }
                          },
                          decoration: InputDecoration(
                            hintStyle: GymStyle.searchbox,
                            hintText: AppLocalizations.of(context)!.search_membership,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              child: SvgPicture.asset(
                                "assets/images/SearchIcon.svg",
                              ),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: height * 0.025,
                  ),
                  SizedBox(
                    height: searchVisible ? height * 0.85 - 58 : height * 0.85,
                    width: width,
                    child: Consumer<MembershipProvider>(
                      builder: (context, membershipData, child) => membershipProvider.membershipListItem.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: membershipData.membershipListItem.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot documentSnapshot = membershipData.membershipListItem[index];
                                return MembershipListItemView(
                                  queryDocumentSnapshot: documentSnapshot,
                                  pullRefresh: pullRefresh,
                                  userRole: userRole,
                                );
                              },
                            )
                          : userRole == userRoleMember
                              ? Column(
                                  children: [
                                    const Spacer(),
                                    CircleAvatar(
                                      backgroundColor: ColorCode.tabDivider,
                                      maxRadius: 45,
                                      child: Image.asset('assets/images/empty_box.png'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                      child: Text(
                                        AppLocalizations.of(context)!.you_do_not_have_any_exercise,
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
                                    const Spacer(),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        userRole == userRoleAdmin
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const AddTrainerPackageScreen(
                                                    documentSnapshot: null,
                                                    viewType: "Add",
                                                  ),
                                                ),
                                              )
                                            : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const TrainerAddMemberShip(
                                                    documentSnapshot: null,
                                                    viewType: "Add",
                                                  ),
                                                ),
                                              );
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: ColorCode.tabDivider,
                                        maxRadius: 45,
                                        child: SvgPicture.asset(
                                          'assets/images/ic_add.svg',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 17.0, right: 17, top: 15),
                                      child: Text(
                                        userRole == userRoleAdmin
                                            ? AppLocalizations.of(context)!.you_do_not_have_any_packages
                                            : AppLocalizations.of(context)!.you_do_not_have_any_membership,
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
                                    Text(
                                      AppLocalizations.of(context)!.tap_to_add.firstCapitalize(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        color: ColorCode.listSubTitle,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    membershipProvider.membershipListItem.clear();
    if (userRole == userRoleMember) {
      await membershipProvider.getMembershipList(searchText: text, isRefresh: true, createdById: createdBy);
    } else {
      await membershipProvider.getMembershipList(searchText: text, createdById: currentUserId);
    }
  }

  Future<void> pullRefresh() async {
    progressDialog.show();
    if (userRole == userRoleMember) {
      await membershipProvider.getMembershipList(isRefresh: true, createdById: createdBy);
    } else {
      await membershipProvider.getMembershipList(isRefresh: true, createdById: currentUserId);
    }
    progressDialog.hide();
  }
}
