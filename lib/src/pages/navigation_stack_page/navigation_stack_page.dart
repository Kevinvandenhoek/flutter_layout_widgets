import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';
import 'package:tf_layout_widgets/src/ui_elements/top_bars/curved_top_bar.dart';
import 'package:tf_layout_widgets/src/ui_elements/top_bars/top_bar.dart';

class NavigationStackController {
  NavigationStackPageState parent;
  bool get hasParent {
    return parent != null;
  }

  void push(NavigationStackPageItem item) {
    if (hasParent) Exception("Parent == null");
    parent.push(item);
  }

  void pop() {
    if (hasParent) Exception("Parent == null");
    parent.pop();
  }
}

abstract class NavigationStackPageItem extends TopBarPageItem {
  void willAppear() {}
  void didAppear() {}

  void willDisappear() {}
  void didDisappear() {}

  void dispose() {}
}

class NavigationStackPage extends StatefulWidget {
  final NavigationStackController controller;
  final NavigationStackPageItem rootWidget;

  final TopBar Function(
      BuildContext context,
      TopBarPreferences topBarPreferences,
      Widget centerView,
      Widget bottomView) topBarBuilder;

  NavigationStackPage(
      {@required this.controller,
      @required this.rootWidget,
      @required this.topBarBuilder});

  @override
  State<StatefulWidget> createState() {
    return NavigationStackPageState();
  }
}

class NavigationStackPageState extends State<NavigationStackPage> {
  List<NavigationStackPageItem> navigationStack;

  NavigationStackPageItem _presentedPage;
  set presentedPage(NavigationStackPageItem value) {
    _presentedPage = value;
  }

  NavigationStackPageItem get presentedPage {
    return _presentedPage;
  }

  NavigationStackPageState() {
    navigationStack = [widget.rootWidget];
    presentedPage = widget.rootWidget;
    widget.controller.parent = this;
  }

  @override
  Widget build(BuildContext context) {
    var topBarPreferences = presentedPage.getTopBarPreferences(context);
    var bodyPreferences = presentedPage.getBodyPreferences(context);
    return TopBarPage(
        topBarFractionalHeight:
            topBarPreferences.preferredTopBarFractionalHeight,
        preferredBodyHeight: bodyPreferences.preferredBodyHeight,
        color: bodyPreferences.preferredBodyColor,
        isScrollable: bodyPreferences.isScrollable,
        buildTopBar: (context) {
          var curvedTopBarPreferences =
              topBarPreferences as CurvedTopBarPreferences ??
                  CurvedTopBarPreferences.from(topBarPreferences);
          return widget.topBarBuilder(
            context,
            curvedTopBarPreferences,
            presentedPage.buildTopBarCenterView(context),
            presentedPage.buildTopBarBottomView(context),
          );
        },
        buildBody: (context) {
          return Container(
            child: presentedPage.buildBody(context),
          );
        });
  }

  void push(NavigationStackPageItem item) {
    setState(() {
      var previousPage = presentedPage;
      previousPage?.willDisappear();
      this.navigationStack.add(item);
      item.willAppear();
      presentedPage = item;
      previousPage?.didDisappear();
      item.didAppear();
    });
  }

  void pop() {
    if (this.navigationStack.length > 1) {
      setState(() {
        navigationStack.last.willDisappear();
        var removedPage = navigationStack.removeLast();
        removedPage.didDisappear();
        removedPage.dispose();

        navigationStack.last?.willAppear();
        presentedPage = navigationStack.last;
        presentedPage?.didAppear();
      });
    }
  }
}
