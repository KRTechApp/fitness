import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class MemberSelectItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final int index;
  final List<String> selectedMemberList;
  final Function(String memberId, bool selected) onMemberSelected;

  const MemberSelectItemView(
      {super.key,
      required this.documentSnapshot,
      required this.index,
      required this.selectedMemberList,
      required this.onMemberSelected});

  @override
  State<MemberSelectItemView> createState() => _MemberSelectItemViewState();
}

class _MemberSelectItemViewState extends State<MemberSelectItemView> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.selectedMemberList.contains(widget.documentSnapshot.id)) {
                widget.onMemberSelected(widget.documentSnapshot.id, false);
              } else {
                widget.onMemberSelected(widget.documentSnapshot.id, true);
              }
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
                          url: widget.documentSnapshot[keyProfile],
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
                        width: width * 0.53,
                        child: Text(
                          widget.documentSnapshot[keyName] ?? "",
                          maxLines: 1,
                          style: GymStyle.listTitle,
                        ),
                      ),
                      Text(
                        '+${widget.documentSnapshot[keyCountryCode] ?? ""} ${widget.documentSnapshot[keyPhone] ?? ""}',
                        style: GymStyle.listSubTitle,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (widget.selectedMemberList.contains(widget.documentSnapshot.id))
                    const Padding(
                      padding: EdgeInsets.only(right: 15,left: 15),
                      child: Icon(Icons.done),
                    )
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.012,
          )
        ],
      ),
    );
  }
}
