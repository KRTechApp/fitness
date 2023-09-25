import 'dart:convert';

/// email : ""
/// password : ""
/// gender : ""
/// age : ""
/// weight : ""
/// height : ""
/// name : ""
/// birthDate : ""
/// phoneNumber : ""
/// address : ""

UserModal userModalFromJson(String str) => UserModal.fromJson(json.decode(str));

String userModalToJson(UserModal data) => json.encode(data.toJson());

class UserModal {
  UserModal({
    String? email,
    String? password,
    String? gender,
    String? age,
    String? weight,
    String? height,
    String? name,
    String? currentMembership,
    int? membershipTimestamp,
    int? birthDate,
    String? countryCode,
    String? phoneNumber,
    String? address,
  }) {
    userEmail = email;
    userPassword = password;
    userGender = gender;
    userAge = age;
    userWeight = weight;
    userHeight = height;
    userName = name;
    userCurrentMembership = currentMembership;
    userMembershipTimestemp = membershipTimestamp;
    userBirthDate = birthDate;
    userCountryCode = countryCode;
    userPhoneNumber = phoneNumber;
    userAddress = address;
  }

  UserModal.fromJson(dynamic json) {
    userEmail = json['email'];
    userPassword = json['password'];
    userGender = json['gender'];
    userAge = json['age'];
    userWeight = json['weight'];
    userHeight = json['height'];
    userName = json['name'];
    userCurrentMembership = json['currentMembership'];
    userMembershipTimestemp = json['membershipTimestamp'];
    userBirthDate = json['birthDate'];
    userCountryCode = json['countryCode'];
    userPhoneNumber = json['phoneNumber'];
    userAddress = json['address'];
  }

  String? userEmail;
  String? userPassword;
  String? userGender;
  String? userAge;
  String? userWeight;
  String? userHeight;
  String? userName;
  String? userCurrentMembership;
  int? userBirthDate;
  int? userMembershipTimestemp;
  String? userCountryCode;
  String? userPhoneNumber;
  String? userAddress;

  UserModal copyWith({
    String? email,
    String? password,
    String? gender,
    String? age,
    String? weight,
    String? height,
    String? name,
    String? currentMembership,
    int? membershipTimestamp,
    int? birthDate,
    String? countryCode,
    String? phoneNumber,
    String? address,
  }) =>
      UserModal(
        email: email ?? userEmail,
        password: password ?? userPassword,
        gender: gender ?? userGender,
        age: age ?? userAge,
        weight: weight ?? userWeight,
        height: height ?? userHeight,
        name: name ?? userName,
        currentMembership: currentMembership ?? userCurrentMembership,
        membershipTimestamp: membershipTimestamp ?? userMembershipTimestemp,
        birthDate: birthDate ?? userBirthDate,
        countryCode: countryCode ?? userCountryCode,
        phoneNumber: phoneNumber ?? userPhoneNumber,
        address: address ?? userAddress,
      );

  String? get email => userEmail;

  String? get password => userPassword;

  String? get gender => userGender;

  String? get age => userAge;

  String? get weight => userWeight;

  String? get height => userHeight;

  String? get name => userName;

  String? get currentMembership => userCurrentMembership;

  int? get birthDate => userBirthDate;

  int? get membershipTimestamp => userMembershipTimestemp;

  String? get countryCode => userCountryCode;

  String? get phoneNumber => userPhoneNumber;

  String? get address => userAddress;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['email'] = userEmail;
    map['password'] = userPassword;
    map['gender'] = userGender;
    map['age'] = userAge;
    map['weight'] = userWeight;
    map['height'] = userHeight;
    map['name'] = userName;
    map['currentMembership'] = userCurrentMembership;
    map['membershipTimestamp'] = userMembershipTimestemp;
    map['birthDate'] = userBirthDate;
    map['countryCode'] = userCountryCode;
    map['phoneNumber'] = userPhoneNumber;
    map['address'] = userAddress;
    return map;
  }
}
