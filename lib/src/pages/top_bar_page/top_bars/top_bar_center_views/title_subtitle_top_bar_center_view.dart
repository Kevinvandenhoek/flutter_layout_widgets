import 'package:flutter/material.dart';

class TitleSubtitleTopBarCenterView extends StatelessWidget {
  final Text title;
  final Text subtitle;
  TitleSubtitleTopBarCenterView({this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (title != null) {
      children.add(title);
    }
    if (subtitle != null) {
      children.add(subtitle);
    }
    return Column(
      children: children,
    );
  }
}
