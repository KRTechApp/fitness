class DefaultResponse{
  int? statusCode = -1;
  bool? status = false;
  String? message = "Message not set";
  dynamic responseData;

  DefaultResponse({this.statusCode,this.status, this.message,this.responseData});
}