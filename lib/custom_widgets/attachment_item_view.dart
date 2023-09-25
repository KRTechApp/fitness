import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../mobile_pages/web_view_attachment.dart';
import '../model/attachment_list_item.dart';
import '../utils/color_code.dart';

class AttachmentItemView extends StatelessWidget {
  final Function(int)? onAttachmentRemove;
  final AttachmentListItem _attachmentItem;
  final int index;
  final String viewType;

  const AttachmentItemView(this.index, this._attachmentItem, this.onAttachmentRemove, {super.key, required this.viewType});

  @override
  Widget build(BuildContext context) {
    debugPrint(
      index.toString(),
    );
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            if (_attachmentItem.attachmentNetwork != null) {
              if (kIsWeb) {
                var url = StaticData.getAttachmentUrl(_attachmentItem.attachmentNetwork!);
                await canLaunchUrl( Uri.parse(url))
                    ? await launchUrl(Uri.parse(url))
                    : throw 'Could not launch '
                        '$url';
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WebViewAttachment(_attachmentItem.attachmentNetwork!),
                  ),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 15, 0),
            child: CircleAvatar(
              maxRadius: 28,
              backgroundColor: ColorCode.mainColor,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    color: Colors.white,
                    child: getFileType(_attachmentItem),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (onAttachmentRemove != null && viewType != "view")
          Positioned(
            width: 25,
            height: 25,
            left: 38,
            bottom: 38,
            child: InkWell(
              onTap: () {
                onAttachmentRemove!(index);
              },
              child: CircleAvatar(
                backgroundColor: ColorCode.white,
                maxRadius: 5,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/cross_icon.svg',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Widget getFileType(AttachmentListItem attachmentItem) {
  debugPrint("attachmentType ${attachmentItem.attachmentType}");
  if (attachmentItem.attachmentType == "pdf") {
    return SvgPicture.asset(
      'assets/images/ic_file_pdf.svg',
      fit: BoxFit.cover,
    );
  } else if (attachmentItem.attachmentType == "csv") {
    return SvgPicture.asset(
      'assets/images/ic_file_csv.svg',
      fit: BoxFit.fill,
    );
  } else if (attachmentItem.attachmentType == "doc" || attachmentItem.attachmentType == "docx") {
    return SvgPicture.asset(
      'assets/images/ic_file_doc.svg',
      fit: BoxFit.fill,
    );
  } else if (attachmentItem.attachmentType == "xls" || attachmentItem.attachmentType == "xlsx") {
    return SvgPicture.asset(
      'assets/images/ic_file_xls.svg',
      fit: BoxFit.fill,
    );
  } else if (attachmentItem.attachmentType == "ppt" ||
      attachmentItem.attachmentType == "pptm" ||
      attachmentItem.attachmentType == "pptx") {
    return SvgPicture.asset(
      'assets/images/ic_file_ppt.svg',
      fit: BoxFit.fill,
    );
  } else if (attachmentItem.attachmentType == "txt") {
    return SvgPicture.asset(
      'assets/images/ic_file_txt.svg',
      fit: BoxFit.fill,
    );
  } else {
    return attachmentItem.attachment != null
        ? Image.memory(
            attachmentItem.attachment!.readAsBytesSync(),
            fit: BoxFit.fill,
            height: 52,
            width: 52,
          )
        : Image.network(
            attachmentItem.attachmentNetwork!,
            fit: BoxFit.fill,
            height: 52,
            width: 52,
          );
  }
}
