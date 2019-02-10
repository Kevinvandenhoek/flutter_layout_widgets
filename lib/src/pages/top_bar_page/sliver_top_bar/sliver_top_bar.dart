import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

abstract class SliverTopBarToContainerDelegate {
  Function topBarHeightChanged(double height);
}

/// A custom type of 'AppBar' which unlike i.e. [AppBar] & [SliverAppBar] does not inherit from [PreferredSizeWidget], allowing it's children to determine its size.
/// It's used by the [TopBarPage] widget, which behaves like [Scaffold], but has a dynamically sized appbar
class SliverTopBarToContainer extends SingleChildRenderObjectWidget {
  final SliverTopBarToContainerDelegate delegate;

  SliverTopBarToContainer({Key key, Widget child, this.delegate})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverTopBar(delegate: delegate);
  }
}

class RenderSliverTopBar extends RenderSliverSingleBoxAdapter {
  final SliverTopBarToContainerDelegate delegate;

  RenderSliverTopBar({
    RenderBox child,
    this.delegate,
  }) : super(child: child);

  Size get size {
    return child?.size ?? Size.zero;
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child.size.width;
        break;
      case Axis.vertical:
        childExtent = child.size.height;
        break;
    }
    assert(childExtent != null);
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      paintOrigin: constraints.scrollOffset + constraints.overlap,
      visible: true,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    delegate?.topBarHeightChanged(child.size.height);
    setChildParentData(child, constraints, geometry);
  }
}
