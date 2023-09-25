import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:provider/provider.dart';

import '../../utils/gym_style.dart';
import '../Utils/color_code.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../Utils/shared_preferences_manager.dart';
import '../providers/member_provider.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';

class MemberFilterBottomSheetScreen extends StatefulWidget {
  const MemberFilterBottomSheetScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MemberFilterBottomSheetScreen> createState() => _MemberFilterBottomSheetScreenState();
}

class _MemberFilterBottomSheetScreenState extends State<MemberFilterBottomSheetScreen> {
  String tempOrderBy = "";
  String tempEndOfPlan = "all";
  late MemberProvider memberProvider;
  late ShowProgressDialog progressDialog;
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userRole = "";
  String userId = "";

  @override
  void initState() {
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        tempOrderBy = StaticData.orderBy;
        tempEndOfPlan = StaticData.planBy;
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

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 600,
          width: width,
          margin: const EdgeInsets.only(top: 30),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, bottom: 30),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset('assets/images/arrow-left.svg'),
                      ),
                      SizedBox(width: width * 0.03),
                      Text(
                        AppLocalizations.of(context)!.filter,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 35,
                        width: 80,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(
                              () {
                                tempOrderBy = "new_first";
                                tempEndOfPlan = "all";
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCode.mainColor,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.reset,
                            style: GymStyle.resetButton,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.order_by,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PoppinsSemiBold',
                          color: Color(0xff0B204C),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            tempOrderBy = "new_first";
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempOrderBy == "new_first" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.newest_first,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            tempOrderBy = "old_first";
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempOrderBy == "old_first" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.oldest_first,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            tempOrderBy = "az";
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempOrderBy == "az" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.a_to_z,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            tempOrderBy = "za";
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempOrderBy == "za" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.z_to_a,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                       Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text(
                          AppLocalizations.of(context)!.by_end_0f_plan,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'PoppinsSemiBold',
                            color: Color(0xff0B204C),
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(
                            () {
                              tempEndOfPlan = "all";
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempEndOfPlan == "all" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.all,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(
                            () {
                              tempEndOfPlan = "with_in_thirty_days";
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempEndOfPlan == "with_in_thirty_days" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.with_in_thirty_days,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(
                            () {
                              tempEndOfPlan = "with_in_sixty_days";
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 15, 15, 10),
                          child: Row(
                            children: [
                              Opacity(
                                opacity: tempEndOfPlan == "with_in_sixty_days" ? 1.0 : 0.0,
                                child: const Icon(
                                  Icons.done,
                                  size: 20,
                                  color: Color(0xff6842FF),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.with_in_sixty_days,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: Color(0xff0B204C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 15,
          left: 15,
          child: SizedBox(
            height: height * 0.08,
            width: width * 0.9,
            child: ElevatedButton(
              /*onPressed: () async {
                progressDialog.show();
                await memberProvider.getMemberOfTrainer(
                    currentUserId: userId, isRefresh: true, orderBy: widget.orderBy);
                Navigator.pop(context);
                progressDialog.hide();
              },*/
              onPressed: () async {
                progressDialog.show();
                StaticData.orderBy = tempOrderBy;
                StaticData.planBy = tempEndOfPlan;
                await memberProvider.getMemberOfTrainer(
                    createdById: userId, isRefresh: true,);
                if(context.mounted) {
                  Navigator.pop(context);
                }
                progressDialog.hide();
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: const Color(0xFF6842FF),
              ),
              child: Text(
                AppLocalizations.of(context)!.done.toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
              ),
            ),
          ),
        )
      ],
    );
  }
}
