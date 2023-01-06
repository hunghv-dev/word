import 'package:flutter/material.dart';
import 'package:word/utils/color_utils.dart';

class ItemStepper extends StatelessWidget {
  final String index;
  final String title;

  const ItemStepper({super.key, required this.index, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 10,
            child: Text(index,
                style: const TextStyle(color: ColorUtils.background)),
          ),
          Container(
            width: double.infinity,
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 15),
            margin: const EdgeInsets.only(left: 10, top: 5),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
