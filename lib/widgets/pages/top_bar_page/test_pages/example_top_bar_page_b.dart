import 'package:flutter/material.dart';
import 'package:flutter_layout_widgets/pages/top_bar_page/top_bar_page.dart';
import 'package:flutter_layout_widgets/pages/top_bar_page/top_bars/curved_top_bar.dart';

class TestTopBarPageB extends TopBarPageItem {
  final String title =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

  @override
  Widget buildBody(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(30),
        child: Container(
          height: 250,
          width: 250,
          decoration:
              ShapeDecoration(color: Colors.blue, shape: CircleBorder()),
        ));
  }
}