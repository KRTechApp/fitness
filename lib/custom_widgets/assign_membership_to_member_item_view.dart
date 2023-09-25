import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/gym_style.dart';
import '../utils/tables_keys_values.dart';
import '../utils/utils_methods.dart';
import 'custom_card.dart';

class AssignMembershipToMemberItemView extends StatefulWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final int index;
  final List<String> selectedMemberList;
  final Function(String memberId, bool selected) onMemberSelected;
  final String membershipId;

  const AssignMembershipToMemberItemView(
      {Key? key,
      required this.documentSnapshot,
      required this.index,
      required this.selectedMemberList,
      required this.onMemberSelected,
      required this.membershipId})
      : super(key: key);

  @override
  State<AssignMembershipToMemberItemView> createState() => _AssignMembershipToMemberItemViewState();
}

class _AssignMembershipToMemberItemViewState extends State<AssignMembershipToMemberItemView> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              activeColor: const Color(0xFF6842FF),
              value: widget.selectedMemberList.contains(widget.documentSnapshot.id),
              onChanged: (bool? value) {
                if (widget.selectedMemberList.contains(widget.documentSnapshot.id)) {
                  widget.onMemberSelected(widget.documentSnapshot.id, false);
                } else {
                  widget.onMemberSelected(widget.documentSnapshot.id, true);
                }
              },
            ),
            InkWell(
              onTap: () {},
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
                          width: width * 0.61,
                          child: Text(
                            widget.documentSnapshot[keyName] ?? "",
                            // 'Golden Membership',
                            maxLines: 1,
                            style: GymStyle.listTitle,
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        SizedBox(
                          width: width * 0.51,
                          child: Text(widget.documentSnapshot[keyUserRole] ?? "", style: GymStyle.listSubTitle),
                        ),
                        // child: Text('Trainer' + ' month', style: GymStyle.listSubTitle),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: height * 0.011,
            ),
          ],
        ),
        SizedBox(
          height: height * 0.012,
        ),
      ],
    );
  }
}
