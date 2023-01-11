import 'package:flutter/material.dart';
import 'package:word/utils/color_utils.dart';
import 'package:word/utils/ext.dart';

class ItemTimeRange extends StatefulWidget {
  final ValueChanged<bool> touchChange;
  final Widget text;
  final bool isWordRemind;

  const ItemTimeRange(
      {super.key,
      required this.touchChange,
      required this.text,
      required this.isWordRemind});

  @override
  _ItemTimeRangeState createState() => _ItemTimeRangeState();
}

class _ItemTimeRangeState extends State<ItemTimeRange> {
  bool? _isScrollUp;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: widget.isWordRemind ? ColorUtils.grey : ColorUtils.blue,
      radius: 25,
      child: GestureDetector(
        onPanUpdate: (details) {
          _isScrollUp = null;
          if (details.isDragUp) {
            setState(() => _isScrollUp = true);
          }
          if (details.isDragDown) {
            setState(() => _isScrollUp = false);
          }
        },
        onPanEnd: (_) {
          if (_isScrollUp == null) return;
          if (widget.isWordRemind) return;
          widget.touchChange.call(_isScrollUp!);
        },
        child: Center(child: widget.text),
      ),
    );
  }
}
