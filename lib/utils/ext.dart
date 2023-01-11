import 'package:flutter/material.dart';

extension DragUpdateDetailsExt on DragUpdateDetails {
  bool get isDragUp => delta.dy < 0;

  bool get isDragDown => delta.dy > 0;
}
