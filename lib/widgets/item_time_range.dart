import 'package:flutter/material.dart';
import 'package:word/utils/color_utils.dart';
import 'package:word/utils/ext.dart';

class ItemTimeRange extends StatefulWidget {
  final ValueChanged<bool>? touchChange;
  final Widget text;
  final bool isWordRemind;

  const ItemTimeRange(
      {super.key,
      this.touchChange,
      required this.text,
      required this.isWordRemind});

  @override
  State<ItemTimeRange> createState() => _ItemTimeRangeState();
}

class _ItemTimeRangeState extends State<ItemTimeRange> {
  bool? _isScrollUp;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        if (_isScrollUp == null || widget.isWordRemind) return;
        widget.touchChange?.call(_isScrollUp!);
        setState(() => _isScrollUp = null);
      },
      child: CircleAvatar(
        radius: 23,
        backgroundColor:
            widget.isWordRemind ? ColorUtils.grey : ColorUtils.blue,
        child: Center(child: widget.text),
      ),
    );
  }
}
