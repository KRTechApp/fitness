import 'package:cloud_firestore/cloud_firestore.dart';

/// query_document : ""
/// type : ""

class GlobalSearchModel {
  GlobalSearchModel({
    QueryDocumentSnapshot? queryDocument,
      String? type,}){
    _queryDocument = queryDocument;
    _type = type;
}

  GlobalSearchModel.fromJson(dynamic json) {
    _queryDocument = json['query_document'];
    _type = json['type'];
  }
  QueryDocumentSnapshot? _queryDocument;
  String? _type;
GlobalSearchModel copyWith({  QueryDocumentSnapshot? queryDocument,
  String? type,
}) => GlobalSearchModel(  queryDocument: queryDocument ?? _queryDocument,
  type: type ?? _type,
);
  QueryDocumentSnapshot? get queryDocument => _queryDocument;
  String? get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['query_document'] = _queryDocument;
    map['type'] = _type;
    return map;
  }

}