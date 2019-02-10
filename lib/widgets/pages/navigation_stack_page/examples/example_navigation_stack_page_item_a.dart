import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/widgets/pages/navigation_stack_page/extensions/animated_navigation_stack_page.dart';
import 'package:tf_layout_widgets/widgets/pages/navigation_stack_page/navigation_stack_page.dart';
import 'package:tf_layout_widgets/widgets/pages/top_bar_page/top_bars/top_bar_center_views/title_subtitle_top_bar_center_view.dart';

class TestNavigationStackPageItemA extends NavigationStackPageItem
    with NavigationStackAnimatable {
  @override
  double get preferredTopBarWaveLerp => 1.0;

  @override
  Color get preferredBodyColor => Colors.red;

  @override
  Widget buildTopBarCenterView(BuildContext context) {
    return visiblityBuilder(
      (visiblity) {
        return TitleSubtitleTopBarCenterView(
          title: Text(
            "Habitant morbi",
          ),
          subtitle: Text(
            "malesuada fames",
          ),
        );
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return visiblityBuilder(
      (visiblity) {
        return Container(
          child: Transform(
            transform: Matrix4.translationValues((1 - visiblity) * 100, 0, 0),
            child: Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
            ),
          ),
        );
      },
    );
  }
}
