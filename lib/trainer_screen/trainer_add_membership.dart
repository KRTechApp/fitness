import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/main.dart';
import 'package:crossfit_gym_trainer/utils/show_progress_dialog.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:crossfit_gym_trainer/utils/validate_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path_extension;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../Utils/color_code.dart';
import '../custom_widgets/TagView/tags.dart';
import '../custom_widgets/attachment_item_view.dart';
import '../mobile_pages/main_drawer_screen.dart';
import '../model/attachment_list_item.dart';
import '../model/member_selection_model.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../utils/firebase_interface.dart';
import '../utils/gym_style.dart';
import '../utils/shared_preferences_manager.dart';
import '../utils/static_data.dart';
import '../utils/utils_methods.dart';
import 'select_member_list.dart';
import 'tag_view_item_view.dart';

class TrainerAddMemberShip extends StatefulWidget {
  final String viewType;
  final QueryDocumentSnapshot? documentSnapshot;

  const TrainerAddMemberShip({
    Key? key,
    required this.viewType,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  State<TrainerAddMemberShip> createState() => _TrainerAddMemberShipState();
}

class _TrainerAddMemberShipState extends State<TrainerAddMemberShip> {
  final ImagePicker imgPicker = ImagePicker();
  Uint8List? imageByte, memberImageByte;
  File? imagePath;
  ImagePicker picker = ImagePicker();
  XFile? image;
  var profile = '';
  var selectedMemberProfile = '';
  var memberShipName = TextEditingController();
  var amount = TextEditingController();
  var period = TextEditingController();
  var description = TextEditingController();
  FirebaseInterface firebaseInterface = FirebaseInterface();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late MembershipProvider membershipProvider;
  late ShowProgressDialog progressDialog;
  late MemberProvider memberProvider;
  List<AttachmentListItem> attachmentList = [];
  List<AttachmentListItem> removeAttachmentList = [];
  final SharedPreferencesManager _preference = SharedPreferencesManager();
  String userId = "";
  String userRole = "";
  bool enableRecurringPackage = true;
  MemberSelectionModel memberSelectionModel =
      MemberSelectionModel(alreadySelectedMember: [], selectedMember: [], unselectedMember: []);

  @override
  void initState() {
    super.initState();
    membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    progressDialog = ShowProgressDialog(barrierDismissible: false, context: context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        userId = await _preference.getValue(prefUserId, "");
        userRole = await _preference.getValue(prefUserRole, "");
        if ((widget.viewType == "edit" || widget.viewType == "view") && widget.documentSnapshot != null) {
          memberShipName.text = widget.documentSnapshot!.get(keyMembershipName);
          amount.text = widget.documentSnapshot!.get(keyAmount).toString();
          period.text = widget.documentSnapshot!.get(keyPeriod).toString();
          enableRecurringPackage = widget.documentSnapshot!.get(keyRecurringPackage);

          List<String> tempMemberList = List.castFrom(widget.documentSnapshot!.get(keyAssignedMembers) as List);
          debugPrint("tempMemberList : $tempMemberList");
          memberSelectionModel.selectedMember!.addAll(tempMemberList);
          memberSelectionModel.alreadySelectedMember!.addAll(tempMemberList);

          description.text = widget.documentSnapshot!.get(keyDescription);
          profile = widget.documentSnapshot!.get(keyProfile);
          List<String> tempAttachmentList = List.castFrom(widget.documentSnapshot!.get(keyAttachment) as List);
          tempAttachmentList.asMap().forEach((index, attachment) {
            var attachmentName = getFileNameFromFirebaseURL(attachment);
            attachmentList.add(AttachmentListItem(
                id: index,
                attachmentNetwork: attachment,
                attachmentType: path_extension.extension(attachmentName).replaceAll(".", "")));
          });
        }
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
        Navigator.pop(context);
        return Future.value(true);
      },
      child: Scaffold(
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
          title: Text(
            widget.viewType == "view"
                ? AppLocalizations.of(context)!.view_membership
                : widget.viewType == "edit"
                    ? AppLocalizations.of(context)!.edit_membership
                    : AppLocalizations.of(context)!.add_membership,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Stack(
            children: [
              SizedBox(
                height: height,
                width: width,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: memberShipName,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_membership_name;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            labelText: '${AppLocalizations.of(context)!.membership_name}*',
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          controller: amount,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_amount;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            labelText: '${AppLocalizations.of(context)!.amount}(${StaticData.currentCurrency})*',
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          controller: period,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return AppLocalizations.of(context)!.please_enter_period;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            labelText: '${AppLocalizations.of(context)!.period_days}*',
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1,
                              child: Checkbox(
                                visualDensity: VisualDensity.compact,
                                activeColor: ColorCode.mainColor,
                                value: enableRecurringPackage,
                                onChanged: widget.viewType == "view"
                                    ? null
                                    : (bool? value) {
                                        if (value != null) {
                                          setState(
                                            () {
                                              enableRecurringPackage = value;
                                            },
                                          );
                                        }
                                      },
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.recurring_membership,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: enableRecurringPackage ? ColorCode.backgroundColor : ColorCode.tabBarText,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(AppLocalizations.of(context)!.image, style: GymStyle.inputText),
                        const SizedBox(
                          height: 10,
                        ),
                        DottedBorder(
                          color: ColorCode.mainColor,
                          strokeWidth: 1,
                          borderType: BorderType.Circle,
                          radius: const Radius.circular(10),
                          dashPattern: const [4, 4, 4, 4],
                          strokeCap: StrokeCap.round,
                          child: InkWell(
                            onTap: () {
                              widget.viewType == "view" ? "" : openImage();
                              widget.viewType == "view"
                                  ? Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!.you_have_no_access,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0)
                                  : "";
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                // border: Border.all(color: Colors.blueAccent, width: 3),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              height: 45,
                              width: 45,
                              child: imageByte != null || profile.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50.0,
                                      backgroundImage: customImageProvider(url: profile, imageByte: imageByte),
                                    )
                                  : const Icon(
                                      Icons.add,
                                      color: Color(0Xff6842FF),
                                      size: 30,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: description,
                          cursorColor: ColorCode.mainColor,
                          readOnly: widget.viewType == "view" ? true : false,
                          decoration: InputDecoration(
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorCode.mainColor,
                              ),
                            ),
                            labelText: AppLocalizations.of(context)!.description,
                            labelStyle: GymStyle.inputText,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(AppLocalizations.of(context)!.attach_document, style: GymStyle.inputText),
                        const SizedBox(
                          height: 10,
                        ),
                        Tags(
                          alignment: WrapAlignment.start,
                          itemCount: attachmentList.length,
                          customWidget: InkWell(
                            onTapDown: (TapDownDetails details) async {
                              widget.viewType == "view" ? "" : openAttachment();
                              widget.viewType == "view"
                                  ? Fluttertoast.showToast(
                                      msg: AppLocalizations.of(context)!.you_have_no_access,
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0)
                                  : "";
                            },
                            child: DottedBorder(
                              color: ColorCode.mainColor,
                              strokeWidth: 1,
                              borderType: BorderType.Circle,
                              radius: const Radius.circular(10),
                              dashPattern: const [4, 4, 4, 4],
                              strokeCap: StrokeCap.round,
                              child: Container(
                                decoration: BoxDecoration(
                                  // border: Border.all(color: Colors.blueAccent, width: 3),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                height: 55,
                                width: 55,
                                child: const Icon(
                                  Icons.add,
                                  color: Color(0Xff6842FF),
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (index) {
                            return AttachmentItemView(
                              index,
                              attachmentList[index],
                              onAttachmentRemove,
                              viewType: widget.viewType,
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 10),
                          child: Text(AppLocalizations.of(context)!.member, style: GymStyle.inputText),
                        ),
                        Tags(
                          alignment: WrapAlignment.start,
                          itemCount: memberSelectionModel.selectedMember!.length,
                          itemBuilder: (index) {
                            return FutureBuilder(
                              // key: UniqueKey(),
                              future: memberProvider.getSelectedMember(
                                memberId: memberSelectionModel.selectedMember![index],
                              ),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> asyncSnapshot) {
                                if (asyncSnapshot.hasData) {
                                  var documentSnapShot = asyncSnapshot.data as DocumentSnapshot;
                                  if (documentSnapShot.exists) {
                                    return TagViewItemView(index, documentSnapShot);
                                  } else {
                                    return const SizedBox();
                                  }
                                }
                                return Text(
                                  AppLocalizations.of(context)!.select_member,
                                  style: GymStyle.inputText,
                                );
                              },
                            );
                          }, //Selected id length
                          customWidget: InkWell(
                            onTap: () async {
                              if (widget.viewType == "view") {
                                Fluttertoast.showToast(
                                    msg: AppLocalizations.of(context)!.you_have_no_access,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 3,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                                return;
                              }

                              MemberSelectionModel tempSelectedMember = (await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SelectMemberList(
                                        memberSelectionModel: memberSelectionModel,
                                      ),
                                    ),
                                  ) ??
                                  MemberSelectionModel(
                                      alreadySelectedMember: [], selectedMember: [], unselectedMember: []));
                              setState(
                                () {
                                  memberSelectionModel = tempSelectedMember;
                                },
                              );
                            },
                            child: Column(
                              children: [
                                DottedBorder(
                                  color: ColorCode.mainColor,
                                  strokeWidth: 1,
                                  borderType: BorderType.Circle,
                                  radius: const Radius.circular(10),
                                  dashPattern: const [4, 4, 4, 4],
                                  strokeCap: StrokeCap.round,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    height: 45,
                                    width: 45,
                                    child: memberImageByte != null || selectedMemberProfile.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 50.0,
                                            backgroundImage: getProfile(),
                                          )
                                        : const Icon(
                                            Icons.add,
                                            color: Color(0Xff6842FF),
                                            size: 30,
                                          ),
                                  ),
                                ),
                                const Text(''),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 10,
                right: 10,
                child: SizedBox(
                  height: height * 0.08,
                  width: width * 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.viewType == "view") {
                        Navigator.pop(context);
                        return;
                      }
                      if (formKey.currentState!.validate()) {
                        if (widget.viewType == "edit") {
                          progressDialog.show(message: 'Loading...');
                          membershipProvider
                              .updateTrainerMembership(
                                  userRole: userRole,
                                  assignMember: memberSelectionModel.selectedMember!,
                                  currentUserId: userId,
                                  membershipId: widget.documentSnapshot!.id,
                                  amount: amount.text.trim().toString(),
                                  period: period.text.trim().toString(),
                                  recurringPackage: enableRecurringPackage,
                                  membershipName: memberShipName.text.trim().toString().firstCapitalize(),
                                  description: description.text.trim().toString(),
                                  profile: imagePath,
                                  imageUrl: profile,
                                  membershipAttachment: attachmentList,
                                  removeAttachment: removeAttachmentList)
                              .then(
                                ((defaultResponseData) => {
                                      progressDialog.hide(),
                                      if (defaultResponseData.status != null && defaultResponseData.status!)
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
                                          memberProvider.assignMembershipToMember(
                                              membershipDoc: widget.documentSnapshot!,
                                              selectedMemberList: memberSelectionModel.selectedMember!,
                                              alreadySelectedMemberList: memberSelectionModel.alreadySelectedMember!,
                                              unSelectedMemberList: memberSelectionModel.unselectedMember!),
                                          debugPrint('selectMemberList${memberSelectionModel.selectedMember!.length}'),
                                          Navigator.pop(context)
                                        }
                                      else
                                        {
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
                                    }),
                              );
                        } else {
                          progressDialog.show(message: 'Loading...');
                          DocumentSnapshot membershipData;

                          membershipProvider
                              .addTrainerMembershipFirebase(
                                  userRole: userRole,
                                  assignMember: memberSelectionModel.selectedMember!,
                                  amount: amount.text.trim().toString(),
                                  description: description.text.trim().toString(),
                                  membershipName: memberShipName.text.trim().toString().capitalizeFirstOfEach,
                                  period: period.text.trim().toString(),
                                  recurringPackage: enableRecurringPackage,
                                  profile: imagePath,
                                  membershipAttachment: attachmentList,
                                  createdBy: userId)
                              .then(
                                (defaultResponseData) async => {
                                  progressDialog.hide(),
                                  if (defaultResponseData.status != null && defaultResponseData.status!)
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
                                      membershipData = (await membershipProvider.getSingleMembership(
                                          membershipId: defaultResponseData.responseData))!,
                                      memberProvider.assignMembershipToMember(
                                          membershipDoc: membershipData,
                                          selectedMemberList: memberSelectionModel.selectedMember!,
                                          alreadySelectedMemberList: memberSelectionModel.alreadySelectedMember!,
                                          unSelectedMemberList: memberSelectionModel.unselectedMember!),
                                      debugPrint('selectMemberList${memberSelectionModel.selectedMember!.length}'),
                                      Navigator.pop(context),
                                    }
                                  else
                                    {
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
                        }
                      }
                    },
                    style: GymStyle.buttonStyle,
                    child: Text(
                      widget.viewType == "view"
                          ? AppLocalizations.of(context)!.go_back.allInCaps
                          : widget.viewType == "edit"
                              ? AppLocalizations.of(context)!.save_membership.allInCaps
                              : AppLocalizations.of(context)!.add_membership.allInCaps,
                      style: GymStyle.buttonTextStyle,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        drawer: MainDrawerScreen(scaffoldKey: _scaffoldKey),
      ),
    );
  }

  openImage() async {
    try {
      var pickedFile = await imgPicker.pickImage(source: ImageSource.gallery);
      //you can use ImageCourse.camera for Camera capture
      if (pickedFile != null) {
        imageByte = await pickedFile.readAsBytes();
        imagePath = File(pickedFile.path);
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  openAttachment() async {
    try {
      if (!await openFilePermission()) {
        if (context.mounted) {
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.please_give_a_storage_read_write_and_permission,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              timeInSecForIosWeb: 3,
              fontSize: 16.0);
        }
        return null;
      }
      var pickedFile = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'jpg',
            'jpeg',
            'png',
            'csv',
            'pdf',
            'doc',
            'docx',
            'txt',
            'ppt',
            'pptm',
            'pptx',
            'xls',
            'xlsx'
          ],
          allowMultiple: false,
          withData: true);
      if (pickedFile != null) {
        pickedFile.files.asMap().forEach(
          (index, platformFile) async {
            double sizeInMb = platformFile.size / (1024 * 1024);
            debugPrint("File Size : $sizeInMb");
            if (sizeInMb < 2) {
              if (StaticData.isAttachmentValid(platformFile.name, StaticData.attachmentExtensionList)) {
                attachmentList.add(
                  AttachmentListItem(
                      id: index,
                      attachment: File(platformFile.path!),
                      attachmentName: platformFile.name,
                      attachmentSize: platformFile.size,
                      attachmentType: platformFile.extension),
                );
              } else {
                Fluttertoast.showToast(
                    msg: AppLocalizations.of(context)!.please_select_valid_file,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            } else {
              Fluttertoast.showToast(
                  msg: AppLocalizations.of(context)!.attachment_file_size_allow_only_mb,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 3,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          },
        );
        setState(
          () {},
        );
      }
    } catch (e) {
      debugPrint("error while picking file.");
    }
  }

  Future<bool> openFilePermission() async {
    var status = await Permission.storage.status;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    var sdkInt = await deviceInfo.androidInfo;
    if (status.isGranted || (Platform.isAndroid && (sdkInt.version.sdkInt) >= 33)) {
      return true;
    } else {
      var permissionRequest = await Permission.storage.request();
      if (permissionRequest.isGranted) {
        return true;
      }
    }
    return false;
  }

  void onAttachmentRemove(int index) {
    debugPrint("remove index : $index");
    setState(
      () {
        removeAttachmentList.add(
          attachmentList[index],
        );
        attachmentList.removeAt(index);
      },
    );
  }

  ImageProvider getProfile() {
    if (memberImageByte != null) {
      return MemoryImage(memberImageByte!);
    } else {
      return AssetImage(selectedMemberProfile);
    }
  }
}
