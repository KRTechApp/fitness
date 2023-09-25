import 'dart:io';

/// id : 1
/// attachment : "test"
/// attachment_name : "test"
/// attachment_size : 123
/// attachment_type : "test"

class AttachmentListItem {
  int? _id;
  File? _attachment;
  String? _attachmentNetwork;
  String? _attachmentName;
  int? _attachmentSize;
  String? _attachmentType;

  int? get id => _id;

  File? get attachment => _attachment;

  String? get attachmentNetwork => _attachmentNetwork;
  String? get attachmentName => _attachmentName;

  int? get attachmentSize => _attachmentSize;

  String? get attachmentType => _attachmentType;

  AttachmentListItem(
      {int? id, File? attachment, String? attachmentNetwork, String? attachmentName, int? attachmentSize, String? attachmentType}) {
    _id = id;
    _attachment = attachment;
    _attachmentNetwork = attachmentNetwork;
    _attachmentName = attachmentName;
    _attachmentSize = attachmentSize;
    _attachmentType = attachmentType;
  }

  AttachmentListItem.fromJson(dynamic json) {
    _id = json["id"];
    _attachment = json["attachment"];
    _attachmentName = json["attachment_name"];
    _attachmentSize = json["attachment_size"];
    _attachmentType = json["attachment_type"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["attachment"] = _attachment;
    map["attachment_name"] = _attachmentName;
    map["attachment_size"] = _attachmentSize;
    map["attachment_type"] = _attachmentType;
    return map;
  }
}
