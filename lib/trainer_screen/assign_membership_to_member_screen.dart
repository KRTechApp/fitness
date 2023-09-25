import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../custom_widgets/assign_membership_to_member_item_view.dart';
import '../main.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../utils/firebase_interface.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/show_progress_dialog.dart';
import '../utils/tables_keys_values.dart';
import 'add_member_screen.dart';

class AssignMembershipToMember extends StatefulWidget {
  final QueryDocumentSnapshot queryDocumentSnapshot;
  final List<String> alreadySelectedMember;

  const AssignMembershipToMember({Key? key, required this.queryDocumentSnapshot, required this.alreadySelectedMember})
      : super(key: key);

  @override
  State<AssignMembershipToMember> createState() => _AssignMembershipToMemberState();
}

class _AssignMembershipToMemberState extends State<AssignMembershipToMember> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> selectMemberList = [];
  List<String> unSelectMemberList = [];
  List<String> alreadySelectedMemberList = [];

  late ShowProgressDialog progressDialog;
  late MemberProvider memberProvider;
  FirebaseInterface firebaseInterface = FirebaseInterface();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String currentUserId = "";

  @override
  void initState() {
    super.initState();
    progressDialog = ShowProgressDialog(context: context, barrierDismissible: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        currentUserId = await _preference.getValue(prefUserId, "");
        getMemberList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
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
        title: Text(widget.queryDocumentSnapshot[keyMembershipName] ?? ""),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                /*
                setState(() {
                  searchVisible = !searchVisible;
                },);
             */
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  height: 25,
                  width: 25,
                  'assets/images/ic_Search.svg',
                  color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0,left: 20),
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  const AddMemberScreen(viewType: "",),
                    ));
              },
              child: SvgPicture.asset(
                height: 20,
                width: 20,
                'assets/images/add_member.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            // margin: EdgeInsets.only(right: 15),
            height: height,
            width: width,
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.025,
                ),
                SizedBox(
                  height: height * 0.85,
                  width: width * 1,
                  child: RefreshIndicator(
                    onRefresh: getMemberList,
                    color: ColorCode.mainColor,
                    child: Consumer<MemberProvider>(
                      builder: (context, memberData, child) => memberProvider.myMemberListItem.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: memberData.myMemberListItem.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot documentSnapshot = memberData.myMemberListItem[index];
                                return AssignMembershipToMemberItemView(
                                  documentSnapshot: documentSnapshot,
                                  membershipId: widget.queryDocumentSnapshot.id,
                                  index: index,
                                  selectedMemberList: selectMemberList,
                                  onMemberSelected: onSelectedTrainer,
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
                                      AppLocalizations.of(context)!.you_do_not_have_any_member,
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
                )
              ],
            ),
          ),
          Positioned(
            bottom: 13,
            left: 23,
            child: SizedBox(
              height: height * 0.08,
              width: width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  progressDialog.show();
                  memberProvider
                      .assignMembershipToMember(
                          membershipDoc: widget.queryDocumentSnapshot,
                          selectedMemberList: selectMemberList,
                          unSelectedMemberList: unSelectMemberList,
                          alreadySelectedMemberList: alreadySelectedMemberList)
                      .then(
                        (defaultResponseData) => {
                      progressDialog.hide(),
                      if (defaultResponseData.status != null &&
                          defaultResponseData.status!)
                        {
                          Fluttertoast.showToast(
                              msg: defaultResponseData.message ??
                                  AppLocalizations.of(context)!.something_want_to_wrong,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0),
                          Navigator.pop(context, true),
                        }
                      else
                        {
                          progressDialog.hide(),
                          Fluttertoast.showToast(
                              msg: defaultResponseData.message ??
                                  AppLocalizations.of(context)!.something_want_to_wrong,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0)
                        }
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  backgroundColor: ColorCode.mainColor,
                ),
                child: Text(
                  AppLocalizations.of(context)!.assign_to_member.toUpperCase(),
                  style: GymStyle.buttonTextStyle,
                ),
              ),
            ),
          )
        ],
      ),
      drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
    );
  }

  onSelectedTrainer(String id, bool selected) {
    setState(
      () {
        if (selected) {
          if (!selectMemberList.contains(id)) {
            selectMemberList.add(id);
            unSelectMemberList.remove(id);
          }
          if (unSelectMemberList.contains(id)) {
            unSelectMemberList.remove(id);
          }
        } else {
          selectMemberList.remove(id);
          unSelectMemberList.add(id);
        }
      },
    );
  }

  Future<void> getMemberList() async {
    progressDialog.show();
    await memberProvider.getMemberOfTrainer(createdById: currentUserId, isRefresh: true);
    progressDialog.hide();
    selectMemberList.clear();
    alreadySelectedMemberList.clear();
    List<QueryDocumentSnapshot> memberList = memberProvider.myMemberListItem
        .where((element) => element[keyCurrentMembership] == widget.queryDocumentSnapshot.id)
        .toList();
    for (QueryDocumentSnapshot doc in memberList) {
      selectMemberList.add(doc.id);
      alreadySelectedMemberList.add(doc.id);
    }
    setState(
      () {},
    );
    debugPrint("selectTrainerList : $selectMemberList");
  }
}
