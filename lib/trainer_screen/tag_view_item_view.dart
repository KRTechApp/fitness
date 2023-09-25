import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';

import '../utils/utils_methods.dart';

class TagViewItemView extends StatelessWidget {
  final DocumentSnapshot documentSnapshot;
  final int index;

  const TagViewItemView(this.index, this.documentSnapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("documentSnapshot.id : ${documentSnapshot.id}");
    return Column(
      children: [
        CircleAvatar(
          maxRadius: 28,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              maxRadius: 28,
              backgroundImage: customImageProvider(
                url: getDocumentValue(documentSnapshot: documentSnapshot, key: keyProfile),
              ),
            ),
          ),
        ),
        Container(
          width: 60,
          alignment: Alignment.center,
          child: Text(
            documentSnapshot[keyName],
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
                color: Color(0xff919bb3),
                decoration: TextDecoration.none,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins'),
          ),
        ),
      ],
    );
  }
}
