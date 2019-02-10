import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/widgets/pages/navigation_stack_page/navigation_stack_page.dart';
import 'package:tf_layout_widgets/widgets/pages/top_bar_page/top_bars/top_bar_center_views/title_subtitle_top_bar_center_view.dart';

class TestNavigationStackPageItemB extends NavigationStackPageItem {
  @override
  Color get preferredBodyColor => Colors.green;

  @override
  Color get preferredTopBarColor => Colors.yellow;

  @override
  Widget buildTopBarCenterView(BuildContext context) {
    return TitleSubtitleTopBarCenterView(
      title: Text(
        "Lorem ipsum",
      ),
      subtitle: Text(
        "Dictum fusce ut placerat orci nulla pellentesque dignissim enim sit. Massa tincidunt dui ut ornare lectus sit. Euismod nisi porta lorem mollis aliquam ut porttitor. Orci sagittis eu volutpat odio facilisis.",
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Center(
      child: Text(
        "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.",
      ),
    );
  }
}
