import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';
import 'package:tf_layout_widgets/src/rx/stream_item.dart';
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

typedef TopBarBuilder = TopBar Function(BuildContext context,
    TopBarPreferences topBarPreferences, Widget centerView, Widget bottomView);

abstract class NavigationStackAnimatable {
  void animate(double lerp) {
    visibilityStream.value = lerp;
  }

  DataStream<double> visibilityStream = DataStream(1.0);

  Widget visiblityBuilder(Widget Function(double visiblity) builder) {
    return StreamBuilder(
      initialData: visibilityStream.value,
      stream: visibilityStream.valueObservable,
      builder: (context, snapshot) {
        return builder(snapshot.data ?? 0);
      },
    );
  }

  void dispose() {
    /// TODO: Somehow ensure the conforming object does have a dispose method to extend?
    visibilityStream.close();
  }
}

class NavigationStackPage extends StatefulWidget {
  final NavigationStackController controller;
  final NavigationStackPageItem rootWidget;

  final TopBarBuilder topBarBuilder;

  NavigationStackPage(
      {@required this.controller,
      @required this.rootWidget,
      @required this.topBarBuilder})
      : assert(rootWidget != null),
        assert(controller != null),
        assert(topBarBuilder != null);

  @override
  State<StatefulWidget> createState() {
    return NavigationStackPageState();
  }
}

class NavigationStackPageState extends State<NavigationStackPage>
    with TickerProviderStateMixin {
  List<NavigationStackPageItem> navigationStack;
  List<NavigationStackPageItem> toDispose = [];

  NavigationStackPageItem _presentedPage;
  set presentedPage(NavigationStackPageItem value) {
    _presentedPage = value;

    _previousPage?.willDisappear();
    presentedPage.willAppear();
    presentedPage
        .didAppear(); // It appears the next frame, albeit with an opacity of 0.0

    _animateWithCompletionHandler(() {
      _previousPage?.didDisappear();
    });
  }

  NavigationStackPageItem get presentedPage {
    return _presentedPage;
  }

  NavigationStackPageItem _previousPage;
  set previousPage(NavigationStackPageItem value) {
    if (toDispose.contains(_previousPage)) {
      _previousPage?.dispose();
    }
    _previousPage = value;
  }

  NavigationStackPageItem get previousPage {
    return _previousPage;
  }

  final Duration duration = Duration(milliseconds: 300);

  Function() _animationCompletionHandler;
  AnimationController _animationController;
  Animation _animation;

  final Tween<double> opacityTween = Tween<double>(begin: 0.0, end: 1.0);

  NavigationStackPageState() {
    _animationController = AnimationController(
      duration: duration,
      vsync: this,
    )..addStatusListener((status) {
        if (_animationCompletionHandler != null &&
            status == AnimationStatus.completed) _animationCompletionHandler();
      });
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );
  }

  @override
  void initState() {
    super.initState();
    navigationStack = [widget.rootWidget];
    presentedPage = widget.rootWidget;
    widget.controller.parent = this;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, animation) {
          if (presentedPage is NavigationStackAnimatable) {
            (presentedPage as NavigationStackAnimatable)
                .animate(_animation.value);
          }
          if (_previousPage is NavigationStackAnimatable) {
            (_previousPage as NavigationStackAnimatable)
                .animate(1.0 - _animation.value);
          }
          var oldPreferencesPage = _previousPage ?? presentedPage;
          var topBarPreferences =
              oldPreferencesPage.getTopBarPreferences(context).lerpTo(
                    presentedPage.getTopBarPreferences(context),
                    _animation,
                  );
          var bodyPreferences = oldPreferencesPage
              .getBodyPreferences(context)
              .lerpTo(presentedPage.getBodyPreferences(context), _animation);
          var topBar = widget.topBarBuilder(
              context,
              topBarPreferences,
              presentedPage.buildTopBarCenterView(context),
              presentedPage.buildTopBarBottomView(context));
          return TopBarPage(
            topBarFractionalHeight:
                topBarPreferences.preferredTopBarFractionalHeight,
            preferredBodyHeight: bodyPreferences.preferredBodyHeight,
            color: bodyPreferences.preferredBodyColor,
            isScrollable:
                presentedPage.getBodyPreferences(context).isScrollable,
            buildTopBar: (context) {
              return topBar;
            },
            buildBody: (context) {
              if (_animation.isCompleted) {
                return _buildPageBody(presentedPage, 1.0);
              } else {
                var presentedPageBody =
                    _buildPageBody(presentedPage, _animation.value);
                var previousPageBody =
                    _buildPageBody(_previousPage, 1.0 - _animation.value);
                var stack = Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    _previousPage.getBodyPreferences(context).isScrollable
                        ? Positioned(
                            left: 0,
                            top: 0,
                            right: 0,
                            child: previousPageBody,
                          )
                        : previousPageBody,
                    presentedPageBody,
                  ],
                );
                return stack;
              }
            },
          );
        });
  }

  Widget _buildPageBody(NavigationStackPageItem page, double animationLerp) {
    var _build = (NavigationStackPageItem pageToBuild) {
      return Container(
        child: AnimatedSize(
          vsync: this,
          duration: duration,
          child: pageToBuild?.buildBody(context) ?? Container(),
        ),
      );
    };
    return (page is NavigationStackAnimatable)
        ? _build(page)
        : Opacity(
            opacity: opacityTween.lerp(animationLerp),
            child: _build(page),
          );
  }

  void _animateWithCompletionHandler(Function() completion) {
    _animationController?.forward(from: 0.0);
    _animationCompletionHandler = completion;
  }

  void pop() {
    if (this.navigationStack.length > 1) {
      setState(() {
        previousPage = navigationStack.removeLast();
        toDispose.add(previousPage);
        presentedPage = navigationStack.last;
      });
    }
  }

  void push(NavigationStackPageItem item) {
    setState(() {
      previousPage = navigationStack.last;
      this.navigationStack.add(item);
      presentedPage = item;
    });
  }
}
