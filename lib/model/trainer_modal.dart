import 'dart:io';

import 'package:crossfit_gym_trainer/model/attachment_list_item.dart';

/// name : ""
/// birthDate : ""
/// gender : ""
/// specialization : [""]
/// assignPackage : [""]
/// email : ""
/// currentMembership : ""
/// membershipTimestamp : ""
/// password : ""
/// countryCode : ""
/// mobileNumber : ""
/// wpCountryCode : ""
/// whatsappNumber : ""
/// profilePhoto : ""
/// profilePhotoFile : ""
/// attachment : [""]

class TrainerModal {
  TrainerModal({
    String? name,
    int? birthDate,
    String? gender,
    List<String>? specialization,
    String? email,
    String? currentMembership,
    int? membershipTimestamp,
    String? password,
    String? countryCode,
    String? mobileNumber,
    String? wpCountryCode,
    String? whatsappNumber,
    String? profilePhoto,
    File? profilePhotoFile,
    List<AttachmentListItem>? attachment,
  }) {
    trainerName = name;
    trainerBirthDate = birthDate;
    trainerGender = gender;
    trainerSpecialization = specialization;
    trainerEmail = email;
    trainerCurrentMembership = currentMembership;
    trainerMembershipTimestamp = membershipTimestamp;
    trainerPassword = password;
    trainerCountryCode = countryCode;
    trainerMobileNumber = mobileNumber;
    trainerWpCountryCode = wpCountryCode;
    trainerWhatsappNumber = whatsappNumber;
    trainerProfilePhoto = profilePhoto;
    trainerProfilePhotoFile = profilePhotoFile;
    trainerAttachment = attachment;
  }

  TrainerModal.fromJson(dynamic json) {
    trainerName = json['name'];
    trainerBirthDate = json['birthDate'];
    trainerGender = json['gender'];
    trainerSpecialization = json['specialization'] != null ? json['specialization'].cast<String>() : [];
    trainerEmail = json['email'];
    trainerCurrentMembership = json['currentMembership'];
    trainerMembershipTimestamp = json['membershipTimestamp'];
    trainerPassword = json['password'];
    trainerCountryCode = json['countryCode'];
    trainerMobileNumber = json['mobileNumber'];
    trainerWpCountryCode = json['wpCountryCode'];
    trainerWhatsappNumber = json['whatsappNumber'];
    trainerProfilePhoto = json['profilePhoto'];
    trainerProfilePhotoFile = json['profilePhotoFile'];
    trainerAttachment = json['attachment'] != null ? json['attachment'].cast<AttachmentListItem>() : [];
  }

  String? trainerName;
  int? trainerBirthDate;
  String? trainerGender;
  List<String>? trainerSpecialization;
  String? trainerEmail;
  String? trainerCurrentMembership;
  int? trainerMembershipTimestamp;
  String? trainerPassword;
  String? trainerCountryCode;
  String? trainerMobileNumber;
  String? trainerWpCountryCode;
  String? trainerWhatsappNumber;
  String? trainerProfilePhoto;
  File? trainerProfilePhotoFile;
  List<AttachmentListItem>? trainerAttachment;

  TrainerModal copyWith({
    String? name,
    int? birthDate,
    String? gender,
    List<String>? specialization,
    String? email,
    String? currentMembership,
    int? membershipTimestamp,
    String? password,
    String? countryCode,
    String? mobileNumber,
    String? wpCountryCode,
    String? whatsappNumber,
    String? profilePhoto,
    File? profilePhotoFile,
    List<AttachmentListItem>? attachment,
  }) =>
      TrainerModal(
        name: name ?? trainerName,
        birthDate: birthDate ?? trainerBirthDate,
        gender: gender ?? trainerGender,
        specialization: specialization ?? trainerSpecialization,
        email: email ?? trainerEmail,
        currentMembership: currentMembership ?? trainerCurrentMembership,
        membershipTimestamp: membershipTimestamp ?? trainerMembershipTimestamp,
        password: password ?? trainerPassword,
        countryCode: countryCode ?? trainerCountryCode,
        mobileNumber: mobileNumber ?? trainerMobileNumber,
        wpCountryCode: wpCountryCode ?? trainerWpCountryCode,
        whatsappNumber: whatsappNumber ?? trainerWhatsappNumber,
        profilePhoto: profilePhoto ?? trainerProfilePhoto,
        profilePhotoFile: profilePhotoFile ?? trainerProfilePhotoFile,
        attachment: attachment ?? trainerAttachment,
      );

  String? get name => trainerName;

  int? get birthDate => trainerBirthDate;

  String? get gender => trainerGender;

  List<String>? get specialization => trainerSpecialization;

  String? get email => trainerEmail;

  String? get currentMembership => trainerCurrentMembership;

  int? get membershipTimestamp => trainerMembershipTimestamp;

  String? get password => trainerPassword;

  String? get countryCode => trainerCountryCode;

  String? get mobileNumber => trainerMobileNumber;

  String? get wpCountryCode => trainerWpCountryCode;

  String? get whatsappNumber => trainerWhatsappNumber;

  String? get profilePhoto => trainerProfilePhoto;

  File? get profilePhotoFile => trainerProfilePhotoFile;

  List<AttachmentListItem>? get attachment => trainerAttachment;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = trainerName;
    map['birthDate'] = trainerBirthDate;
    map['gender'] = trainerGender;
    map['specialization'] = trainerSpecialization;
    map['email'] = trainerEmail;
    map['currentMembership'] = trainerCurrentMembership;
    map['membershipTimestamp'] = trainerMembershipTimestamp;
    map['password'] = trainerPassword;
    map['countryCode'] = trainerCountryCode;
    map['mobileNumber'] = trainerMobileNumber;
    map['wpCountryCode'] = trainerWpCountryCode;
    map['whatsappNumber'] = trainerWhatsappNumber;
    map['profilePhoto'] = trainerProfilePhoto;
    map['profilePhotoFile'] = trainerProfilePhotoFile;
    map['attachment'] = trainerAttachment;
    return map;
  }
}
