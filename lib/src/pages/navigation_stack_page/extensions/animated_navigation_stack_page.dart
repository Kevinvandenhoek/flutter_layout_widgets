import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/navigation_stack_page/navigation_stack_page.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';
import 'package:tf_layout_widgets/src/rx/stream_item.dart';

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

class AnimatedNavigationStackPage extends NavigationStackPage {
  AnimatedNavigationStackPage({
    @required NavigationStackController controller,
    @required NavigationStackPageItem rootWidget,
    @required TopBarBuilder topBarBuilder,
  }) : super(
          controller: controller,
          rootWidget: rootWidget,
          topBarBuilder: topBarBuilder,
        );

  @override
  State<StatefulWidget> createState() {
    return AnimatedNavigationStackPageState();
  }
}

class AnimatedNavigationStackPageState extends NavigationStackPageState
    with TickerProviderStateMixin {
  AnimatedNavigationStackPageState() : super() {
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

  final Duration duration = Duration(milliseconds: 300);

  Function() _animationCompletionHandler;
  AnimationController _animationController;
  Animation _animation;

  final Tween<double> opacityTween = Tween<double>(begin: 0.0, end: 1.0);

  NavigationStackPageItem _previousPage;

  @override
  set presentedPage(NavigationStackPageItem value) {
    _previousPage = super.presentedPage ?? value;
    super.presentedPage = value;

    _previousPage.willDisappear();
    presentedPage.willAppear();
    presentedPage
        .didAppear(); // It appears the next frame, albeit with an opacity of 0.0

    _animateWithCompletionHandler(() {
      _previousPage.didDisappear();
      if (navigationStack.contains(_previousPage) == false) {
        _previousPage.dispose();
        _previousPage = null;
      }
    });
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
          var topBarPreferences =
              _previousPage.getTopBarPreferences(context).lerpTo(
                    presentedPage.getTopBarPreferences(context),
                    _animation,
                  );
          var bodyPreferences = _previousPage
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
          child: pageToBuild.buildBody(context),
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

  @override
  void pop() {
    /// We have to override this because we cannot dispose a page directly after popping
    if (this.navigationStack.length > 1) {
      setState(() {
        navigationStack.removeLast();
        presentedPage = navigationStack.last;
      });
    }
  }

  @override
  void push(NavigationStackPageItem item) {
    setState(() {
      this.navigationStack.add(item);
      presentedPage = item;
    });
  }
}
