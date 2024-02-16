import 'package:base_define/base_define.dart';
import 'package:base_ui/base_ui.dart';
import 'package:flutter/material.dart';

class HourButton extends StatefulWidget {
  final ValueChanged<bool> touchChange;
  final Widget text;
  final bool isWordRemind;

  const HourButton({
    super.key,
    required this.touchChange,
    required this.text,
    required this.isWordRemind,
  });

  @override
  State<HourButton> createState() => _HourButtonState();
}

class _HourButtonState extends State<HourButton> {
  bool? _isScrollUp;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onPanUpdate: (details) {
          _isScrollUp = null;
          setState(() {
            if (details.isDragUp) _isScrollUp = true;
            if (details.isDragDown) _isScrollUp = false;
          });
        },
        onPanEnd: (_) {
          if (_isScrollUp == null || widget.isWordRemind) return;
          widget.touchChange(_isScrollUp!);
          setState(() => _isScrollUp = null);
        },
        child: FloatingActionButton(
          onPressed: null,
          backgroundColor:
              (widget.isWordRemind ? ColorsDefine.grey() : ColorsDefine.blue())
                  .of(context),
          elevation: 0,
          child: widget.text,
        ),
      );
}
