import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../model/user_modal.dart';
import '../../providers/member_provider.dart';
import '../../utils/gym_style.dart';
import '../../utils/shared_preferences_manager.dart';
import '../Utils/color_code.dart';
import '../custom_widgets/member_select_item_view.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/member_selection_model.dart';
import 'add_member_screen.dart';

class SelectMemberList extends StatefulWidget {
  final MemberSelectionModel memberSelectionModel;

  const SelectMemberList({Key? key, required this.memberSelectionModel}) : super(key: key);

  @override
  State<SelectMemberList> createState() => _SelectMemberListState();
}

class _SelectMemberListState extends State<SelectMemberList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late MemberProvider memberProvider;
  late UserModal userModal;
  String userId = "";
  String userRole = "";
  bool searchVisible = false;
  NumberFormat formatter = NumberFormat("00");
  var textSearchController = TextEditingController();
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  late ShowProgressDialog progressDialog;

  @override
  void initState() {
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        setState(
          () {},
        );
        progressDialog.show();
        await memberProvider.getMemberOfTrainer(createdById: userId, isRefresh: true);
        debugPrint('ID : $userId');
        progressDialog.hide();
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
        title: Text(AppLocalizations.of(context)!.select_member),
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
                height: 23,
                width: 23,
                'assets/images/search.svg',
                color: isDarkTheme ? const Color(0xFFFFFFFF) : const Color(0xFF181A20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(50),
              ),
              splashColor: ColorCode.linearProgressBar,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddMemberScreen(viewType: ""),
                    ));
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
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (searchVisible)
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Card(
                // elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFD9E1ED),
                    )),
                child: TextField(
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  controller: textSearchController,
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
          SizedBox(
            height: height * 0.012,
          ),
          if (widget.memberSelectionModel.selectedMember!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Text('${AppLocalizations.of(context)!.selected_member} ${formatter.format(widget.memberSelectionModel.selectedMember!.length)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: ColorCode.listSubTitle)),
            ),

          Stack(
            children: [
              SizedBox(
                height: searchVisible ? height * 0.83 - 58 : height * 0.83,
                width: width,
                child: RefreshIndicator(
                  onRefresh: _pullRefresh,
                  color: ColorCode.mainColor,
                  child: Consumer<MemberProvider>(
                      builder: (context, memberData, child) => memberProvider.myMemberListItem.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80, top: 10),
                              itemCount: memberData.myMemberListItem.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final QueryDocumentSnapshot documentSnapshot = memberData.myMemberListItem[index];
                                return MemberSelectItemView(
                                  documentSnapshot: documentSnapshot,
                                  index: index,
                                  onMemberSelected: onSelectedMember,
                                  selectedMemberList: widget.memberSelectionModel.selectedMember!,
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      userRole == userRoleTrainer
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const AddMemberScreen(viewType: ""),
                                              ))
                                          : null;
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: ColorCode.tabDivider,
                                      maxRadius: 45,
                                      child: SvgPicture.asset('assets/images/add_member.svg', height: 30),
                                    ),
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
                            )),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 18,
                child: SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, widget.memberSelectionModel);
                      debugPrint("SelectMember : ${widget.memberSelectionModel.selectedMember!}");
                    },
                    style: GymStyle.buttonStyle,
                    child: Text(
                      AppLocalizations.of(context)!.done,
                      style: GymStyle.buttonTextStyle,
                    ),
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

  @override
  void dispose() {
    super.dispose();
  }

  onSelectedMember(String id, bool selected) {
    setState(() {
      if (selected) {
        if (!widget.memberSelectionModel.selectedMember!.contains(id)) {
          widget.memberSelectionModel.selectedMember!.add(id);
          widget.memberSelectionModel.unselectedMember!.remove(id);
        }
        if (widget.memberSelectionModel.unselectedMember!.contains(id)) {
          widget.memberSelectionModel.unselectedMember!.remove(id);
        }
      } else {
        widget.memberSelectionModel.selectedMember!.remove(id);
        widget.memberSelectionModel.unselectedMember!.add(id);
      }
    });
  }

  onSearchTextChanged(String text) async {
    memberProvider.myMemberListItem.clear();
    memberProvider.getMemberOfTrainer(searchText: text,createdById: userId,isRefresh: true);
  }

  Future<void> _pullRefresh() async {
    progressDialog.show();
    memberProvider.getMemberOfTrainer(createdById: userId);
    progressDialog.hide();
  }
}
