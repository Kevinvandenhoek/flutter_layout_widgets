import 'dart:math';

import 'package:flutter/material.dart';

class ExpandedPreferredSizeBox extends StatelessWidget {
  final double maximumWidth;
  final double maximumHeight;
  final Widget child;

  ExpandedPreferredSizeBox({
    this.maximumHeight,
    this.maximumWidth,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: min(constraints.maxWidth, maximumWidth ?? double.infinity),
          height: min(constraints.maxHeight, maximumHeight ?? double.infinity),
          child: child,
        );
      },
    );
  }
}
