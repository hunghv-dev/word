import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter/material.dart';

class FloatingCircle extends StatelessWidget {
  final Widget child;

  const FloatingCircle({super.key, required this.child});

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        backgroundColor: ColorsDefine.blue().of(context),
        onPressed: null,
        elevation: 0,
        child: child,
      );
}
