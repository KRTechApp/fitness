import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../admin_screen/add_trainer_package_screen.dart';
import '../admin_screen/assign_membership_to_trainer_screen.dart';
import '../trainer_screen/assign_membership_to_member_screen.dart';
import '../trainer_screen/trainer_add_membership.dart';
import '../utils/color_code.dart';
import '../utils/gym_style.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/static_data.dart';
import '../utils/tables_keys_values.dart';
import '../providers/membership_provider.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class MembershipListItemView extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final Function() pullRefresh;
  final String userRole;

  const MembershipListItemView(
      {Key? key, required this.queryDocumentSnapshot, required this.pullRefresh, required this.userRole})
      : super(key: key);

  @override
  State<MembershipListItemView> createState() => _MembershipListItemViewState();
}

class _MembershipListItemViewState extends State<MembershipListItemView> {
  late MembershipProvider membershipProvider;
  late ShowProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            widget.userRole == userRoleAdmin
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTrainerPackageScreen(
                        documentSnapshot: widget.queryDocumentSnapshot,
                        viewType: "view",
                      ),
                    ),
                  )
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrainerAddMemberShip(
                        documentSnapshot: widget.queryDocumentSnapshot,
                        viewType: "view",
                      ),
                    ),
                  );
          },
          child: customCard(
            blurRadius: 5,
            radius: 15,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FadeInImage(
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      image: customImageProvider(
                        url: widget.queryDocumentSnapshot[keyProfile],
                      ),
                      placeholderFit: BoxFit.fitWidth,
                      placeholder: customImageProvider(),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return getPlaceHolder();
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: width * 0.54,
                      child: Text(
                        widget.queryDocumentSnapshot[keyMembershipName] ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GymStyle.listTitle,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Row(
                      children: [
                        Text('${widget.userRole == userRoleAdmin ? StaticData.currentCurrency : StaticData.currentTrainerCurrency} ${widget.queryDocumentSnapshot[keyAmount]}',
                            style: GymStyle.membershipprice),
                        Text(' / ', style: GymStyle.listSubTitle),
                        Text('${widget.queryDocumentSnapshot[keyPeriod] ?? ""} ${AppLocalizations.of(context)!.days}', style: GymStyle.listSubTitle),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton(
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  onSelected: (selection) async {
                    switch (selection) {
                      case 0:
                        bool? isRefreshRequired;
                        if (widget.userRole == userRoleAdmin) {
                          isRefreshRequired = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignMembershipToTrainerScreen(
                                documentSnapshot: widget.queryDocumentSnapshot,
                              ),
                            ),
                          );
                        } else {
                          isRefreshRequired = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignMembershipToMember(
                                queryDocumentSnapshot: widget.queryDocumentSnapshot,
                                alreadySelectedMember: const [],
                              ),
                            ),
                          );
                        }
                        debugPrint("isRefreshRequired : $isRefreshRequired");
                        if (isRefreshRequired == true) {
                          widget.pullRefresh();
                        }

                        break;
                      case 1:
                        widget.userRole == userRoleAdmin
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTrainerPackageScreen(
                                    documentSnapshot: widget.queryDocumentSnapshot,
                                    viewType: "edit",
                                  ),
                                ),
                              )
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrainerAddMemberShip(
                                    documentSnapshot: widget.queryDocumentSnapshot,
                                    viewType: "edit",
                                  ),
                                ),
                              );
                        break;
                      case 2:
                        deletePopup(widget.queryDocumentSnapshot);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 0,
                      padding: const EdgeInsets.fromLTRB(17, 0,17, 0),
                      child: Text(
                          widget.userRole == userRoleAdmin
                              ? AppLocalizations.of(context)!.assign_to_trainer
                              : AppLocalizations.of(context)!.assign_to_member,
                          style: GymStyle.popupbox),
                    ),
                    PopupMenuItem(
                      value: 1,
                      padding: const EdgeInsets.only(
                        left: 17,right: 17
                      ),
                      child: Text(AppLocalizations.of(context)!.edit.firstCapitalize(), style: GymStyle.popupbox),
                    ),
                    PopupMenuItem(
                      value: 2,
                      padding: const EdgeInsets.only(
                        left: 17,right: 17
                      ),
                      child:
                          Text(AppLocalizations.of(context)!.delete.firstCapitalize(), style: GymStyle.popupboxdelate),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 35,
                      width: 30,
                      alignment: Alignment.center,
                      child: const Icon(Icons.more_vert, color: ColorCode.grayLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: height * 0.015,
        ),
      ],
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
              Text((documentSnapshot[keyMembershipName] ?? "") + '?', style: GymStyle.inputTextBold),
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
                      onPressed: () async {
                        progressDialog.show();
                        await membershipProvider.deleteMembership(membershipId: documentSnapshot.id);
                        if(context.mounted) {
                          Navigator.pop(context);
                        }
                        progressDialog.hide();
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
}
