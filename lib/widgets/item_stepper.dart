import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemStepper extends StatelessWidget {
  final String index;
  final Widget title;

  const ItemStepper({super.key, required this.index, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.zero.top5.horizontal20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.blue),
                child: Text(index)),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero.left15,
                  margin: EdgeInsets.zero.left10.top5,
                  child: title,
                ),
                Positioned(
                  left: 10,
                  bottom: 0,
                  child: Container(
                      width: 1,
                      height: 40,
                      color: ColorsDefine.black().of(context)),
                ),
              ],
            ),
          ],
        ),
      );
}
