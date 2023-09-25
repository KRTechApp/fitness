import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/workout_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/model/user_modal.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../utils/color_code.dart';
import '../../utils/gym_style.dart';
import '../../utils/shared_preferences_manager.dart';
import '../custom_widgets/member_list_item_view.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../providers/payment_history_provider.dart';
import 'add_member_screen.dart';
import 'member_filter_bottom_sheet_screen.dart';
import 'trainer_dashboard_screen.dart';

class MemberList extends StatefulWidget {
  const MemberList({Key? key}) : super(key: key);

  @override
  State<MemberList> createState() => _MemberListState();
}

class _MemberListState extends State<MemberList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MemberProvider memberProvider;
  late WorkoutHistoryProvider workoutHistoryProvider;
  late UserModal userModal;
  late ShowProgressDialog progressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userRole = "";
  String userId = "";
  bool searchVisible = false;
  var textSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    workoutHistoryProvider =
        Provider.of<WorkoutHistoryProvider>(context, listen: false);
    progressDialog =
        ShowProgressDialog(context: context, barrierDismissible: false);
    Provider.of<PaymentHistoryProvider>(context, listen: false)
        .createdByPaymentHistory
        .clear();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        progressDialog.show();
        await workoutHistoryProvider.getTrainerAllWorkout(
          trainerId: userId,
          isRefresh: true,
        );
        await workoutHistoryProvider.getAllMemberWorkoutHistory(
          trainerId: userId,
          isRefresh: true,
        );
        await memberProvider.getMemberOfTrainer(
          createdById: userId,
          isRefresh: true,
        );
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
    debugPrint("Theme $isDarkTheme");
    return WillPopScope(
      onWillPop: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const TrainerDashboardScreen()),
            (Route<dynamic> route) => false);

        return Future.value(true);
      },
      child: Scaffold(
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
          title: Text(AppLocalizations.of(context)!.member),
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
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  height: 20,
                  width: 20,
                  'assets/images/search.svg',
                  color: isDarkTheme
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF181A20),
                ),
              ),
            ),
            InkWell(
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
                  builder: (context) => const MemberFilterBottomSheetScreen(),
                );
              },
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  height: 16,
                  width: 16,
                  'assets/images/ic_Filter.svg',
                  color: isDarkTheme
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF181A20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(50),
                ),
                splashColor: ColorCode.linearProgressBar,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddMemberScreen(viewType: ""),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SvgPicture.asset(
                    height: 20,
                    width: 20,
                    'assets/images/add_member.svg',
                    color: isDarkTheme
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF181A20),
                  ),
                ),
              ),
            ),
          ],
        ),
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            if (searchVisible)
              Padding(
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Card(
                  // elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFD9E1ED),
                      )),
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
                        hintText: AppLocalizations.of(context)!.search_member,
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
              ),
            SizedBox(
              height: height * 0.012,
            ),
            SizedBox(
              height: searchVisible ? height * 0.84 - 58 : height * 0.84,
              width: width,
              child: RefreshIndicator(
                onRefresh: _pullRefresh,
                color: ColorCode.mainColor,
                child: Consumer<MemberProvider>(
                  builder: (context, memberData, child) => memberProvider
                          .myMemberListItem.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(top: 15),
                          itemCount: memberData.myMemberListItem.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final QueryDocumentSnapshot documentSnapshot =
                                memberData.myMemberListItem[index];

                            return MemberListItemView(
                              documentSnapshot: documentSnapshot,
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AddMemberScreen(viewType: ""),
                                      ));
                                },
                                child: CircleAvatar(
                                  backgroundColor: ColorCode.tabDivider,
                                  maxRadius: 45,
                                  child: SvgPicture.asset(
                                      'assets/images/add_member.svg',
                                      height: 30),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 17.0, right: 17, top: 15),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .you_do_not_have_any_member,
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
                                AppLocalizations.of(context)!.tap_to_add,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  color: ColorCode.listSubTitle,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                ),
              ),
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

  onSearchTextChanged(String text) async {
    memberProvider.myMemberListItem.clear();
    memberProvider.getMemberOfTrainer(
        searchText: text, createdById: userId, isRefresh: true);
  }

  Future<void> _pullRefresh() async {
    progressDialog.show();
    await memberProvider.getMemberOfTrainer(
      createdById: userId,
      isRefresh: true,
    );
    progressDialog.hide();
  }
}
