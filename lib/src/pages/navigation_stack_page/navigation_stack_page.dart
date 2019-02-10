import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';
import 'package:tf_layout_widgets/src/ui_elements/top_bars/curved_top_bar.dart';

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

  NavigationStackPage({@required this.controller, @required this.rootWidget});

  @override
  State<StatefulWidget> createState() {
    return NavigationStackPageState(controller, rootWidget);
  }
}

class NavigationStackPageState extends State<NavigationStackPage> {
  final NavigationStackController controller;
  List<NavigationStackPageItem> navigationStack;

  NavigationStackPageItem _presentedPage;
  set presentedPage(NavigationStackPageItem value) {
    _presentedPage = value;
  }

  NavigationStackPageItem get presentedPage {
    return _presentedPage;
  }

  NavigationStackPageState(
      this.controller, NavigationStackPageItem rootWidget) {
    navigationStack = [rootWidget];
    presentedPage = rootWidget;
    controller.parent = this;
  }

  @override
  Widget build(BuildContext context) {
    return TopBarPage(
        topBarFractionalHeight: presentedPage.preferredTopBarFractionalHeight,
        preferredBodyHeight: presentedPage.preferredBodyHeight,
        color: presentedPage.preferredBodyColor,
        isScrollable: presentedPage.isScrollable,
        buildTopBar: (context) {
          return CurvedTopBar(
            centerView: presentedPage.buildTopBarCenterView(context),
            bottomView: presentedPage.buildTopBarBottomView(context),
            color: presentedPage.preferredTopBarColor,
            amplitude: presentedPage.preferredTopBarAmplitude,
            waveLerp: presentedPage.preferredTopBarWaveLerp,
            waveOffset: presentedPage.preferredTopBarWaveOffset,
            waveFrequency: presentedPage.preferredTopBarWaveFrequency,
            onBackButtonPressed: () {
              pop();
            },
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
