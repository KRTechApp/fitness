import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';

class AssignPackageItemView extends StatelessWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final int index;
  final List<String> selectedAssignPackageList;
  final Function(String assignPackageId, bool selected) onAssignPackageSelected;

  const AssignPackageItemView(
      {super.key,
      required this.documentSnapshot,
      required this.index,
      required this.selectedAssignPackageList,
      required this.onAssignPackageSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          // color: const Color(0xFFE3E5E8),
          child: Row(
            children: [
              Theme(
                data: ThemeData(
                  // border color
                  unselectedWidgetColor: const Color(0xFF959797),
                ),
                child: Checkbox(
                  value: selectedAssignPackageList.contains(documentSnapshot.id),
                  onChanged: (bool? value) {
                    onAssignPackageSelected(documentSnapshot.id, value ?? false);
                  },
                ),
              ),
              Text(
                documentSnapshot[keyMembershipName] ?? "",
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontFamily: 'Poppins'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
