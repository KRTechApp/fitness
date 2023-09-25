import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:flutter/material.dart';

class SpecializationItemView extends StatelessWidget {
  final QueryDocumentSnapshot documentSnapshot;
  final int index;
  final List<String> selectedSpecializationList;
  final Function(String specializationId, bool selected) onSpecializationSelected;

  const SpecializationItemView(
      {super.key,
      required this.documentSnapshot,
      required this.index,
      required this.selectedSpecializationList,
      required this.onSpecializationSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      // color: Color(0xFFE3E5E8),
      child: GestureDetector(
        onTap: (){
          onSpecializationSelected(documentSnapshot.id, !selectedSpecializationList.contains(documentSnapshot.id));
        },
        child: Row(
          children: [
            Theme(
              data: ThemeData(
                  // border color
                  unselectedWidgetColor: const Color(0xFF959797)),
              child: Checkbox(
                value: selectedSpecializationList.contains(documentSnapshot.id),
                onChanged: (bool? value) {
                  onSpecializationSelected(documentSnapshot.id, value ?? false);
                },
              ),
            ),
            Text(
              documentSnapshot[keySpecialization] ?? "",
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}
