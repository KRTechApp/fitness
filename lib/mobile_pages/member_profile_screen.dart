import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/utils/color_code.dart';
import 'package:crossfit_gym_trainer/utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../custom_widgets/member_profile_membership_tab.dart';
import '../custom_widgets/member_profile_personal_tab.dart';
import '../custom_widgets/member_profile_workout_tab.dart';
import '../main.dart';
import '../trainer_screen/add_member_screen.dart';
import '../trainer_screen/member_profile_progress_tab.dart';
import '../utils/gym_style.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'main_drawer_screen.dart';

class MemberProfileScreen extends StatefulWidget {
  final String memberId;
  final double memberProgress;

  const MemberProfileScreen({Key? key, required this.memberId, required this.memberProgress}) : super(key: key);

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DocumentSnapshot? documentSnapshot;
  late MemberProvider memberProvider;
  String userRole = "";
  final SharedPreferencesManager _preference = SharedPreferencesManager();

  @override
  void initState() {
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        documentSnapshot = await memberProvider.getSelectedMember(memberId: widget.memberId);
        userRole = await _preference.getValue(prefUserRole, "");
        setState(
          () {},
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
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
        title: Text(AppLocalizations.of(context)!.member_profile),
      ),
      body: documentSnapshot == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: height * 0.018,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      //color: Color(0xFF44CB7F),
                      margin: const EdgeInsets.only(left: 15,right: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF44CB7F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FadeInImage(
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                          image: customImageProvider(
                            url: documentSnapshot![keyProfile],
                          ),
                          placeholderFit: BoxFit.fitWidth,
                          placeholder: customImageProvider(),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return getPlaceHolder();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height * 0.015,
                        ),
                        SizedBox(
                          width: width * 0.37,
                          child: Text(
                            documentSnapshot![keyName] ?? "",
                            maxLines: 1,
                            style: GymStyle.listTitle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: SizedBox(
                            width: width * 0.37,
                            child: Text(
                              widget.memberProgress.toStringAsFixed(2) +' ${AppLocalizations.of(context)!.workout_complete}',
                              maxLines: 1,
                              style: GymStyle.listSubTitle2,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: width * 0.37,
                          child: Text(
                            '${AppLocalizations.of(context)!.member_since}: ${DateFormat(StaticData.currentDateFormat).format(DateTime.fromMillisecondsSinceEpoch(documentSnapshot![keyCreatedAt] ?? 0))}',
                            maxLines: 1,
                            style: GymStyle.listSubTitle3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if(userRole == userRoleTrainer)
                      Padding(
                      padding: const EdgeInsets.only(right: 13, top: 30, left: 13),
                      child: SizedBox(
                        height: height * 0.06,
                        width: width * 0.21,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddMemberScreen(
                                          viewType: "edit",
                                          documentSnapshot: documentSnapshot,
                                        )));
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor: ColorCode.mainColor,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.edit.allInCaps,
                            style: GymStyle.editButton,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.022,
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: isDarkTheme ? ColorCode.socialLoginBackground : ColorCode.tabBarBackground),
                      child: DefaultTabController(
                        initialIndex: 0,
                        length: 4,
                        child: Column(
                          children: [
                            SizedBox(
                              width: width,
                              height: 40,
                              child: TabBar(
                                isScrollable: true,
                                indicatorColor: ColorCode.backgroundColor,
                                indicatorPadding: const EdgeInsets.only(top: 37, bottom: 0, left: 10, right: 10),
                                tabs: [
                                  Tab(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLocalizations.of(context)!.workout.allInCaps,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLocalizations.of(context)!.membership.allInCaps,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLocalizations.of(context)!.progress.allInCaps,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                  Tab(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLocalizations.of(context)!.personal.allInCaps,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: width,
                              height: height * 0.651,
                              color: isDarkTheme ? ColorCode.backgroundColor : ColorCode.white,
                              child: TabBarView(
                                children: <Widget>[
                                  MemberProfileWorkoutTab(
                                      key: UniqueKey(),
                                      documentSnapshot: documentSnapshot!,
                                      userRole: userRole,
                                      trainerName: documentSnapshot![keyName] ?? "",
                                      memberProgress: widget.memberProgress,
                                      userId: documentSnapshot!.id),
                                  MemberProfileMembershipTab(
                                    userRole: userRole,
                                    key: UniqueKey(),
                                    documentSnapshot: documentSnapshot!,
                                  ),
                                  MemberProfileProgressTab(key: UniqueKey(), documentSnapshot: documentSnapshot!),
                                  MemberProfilePersonalTab(
                                    key: UniqueKey(),
                                    documentSnapshot: documentSnapshot!,
                                  ),
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
    );
  }

}
