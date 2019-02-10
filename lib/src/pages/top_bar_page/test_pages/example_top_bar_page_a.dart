import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';

class TestTopBarPageA extends TopBarPageItem {
  final String title =
      "Habitant morbi tristique senectus et netus et malesuada fames ac.";

  @override
  double getPreferredBottomBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.bottom + 100;

  @override
  Widget buildBody(BuildContext context) {
    return Container(
      color: Colors.green,
      height: 900,
    );
  }
}
