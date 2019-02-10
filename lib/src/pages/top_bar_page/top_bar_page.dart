import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/sliver_top_bar/sliver_top_bar.dart';
import 'package:tf_layout_widgets/src/rx/stream_item.dart';

/// A [TopBarPageItem] is a page that has a top bar, which is similar to an [AppBar], but unlike the [AppBar] dynamically sizes to it's child's needs. It is recommended to see the Object that extends this behaviour as the widget controller, which controls the supplemented topbar and body.
abstract class TopBarPageItem {
  Widget buildBody(BuildContext context);

  Widget buildTopBarCenterView(BuildContext context) {
    return null;
  }

  Widget buildTopBarBottomView(BuildContext context) {
    return null;
  }

  BodyPreferences getBodyPreferences(BuildContext context) {
    return BodyPreferences();
  }

  TopBarPreferences getTopBarPreferences(BuildContext context) {
    return TopBarPreferences();
  }
}

class BodyPreferences {
  final double preferredBodyHeight;
  final Color preferredBodyColor;
  final bool isScrollable;

  BodyPreferences({
    this.preferredBodyHeight,
    this.preferredBodyColor,
    this.isScrollable = false,
  });

  BodyPreferences lerpTo(
      BodyPreferences otherBodyPreferences, Animation<double> animation) {
    return BodyPreferences(
      isScrollable: otherBodyPreferences.isScrollable,
      preferredBodyColor: Tween<Color>(
              begin: preferredBodyColor,
              end: otherBodyPreferences.preferredBodyColor)
          .evaluate(animation),
      preferredBodyHeight: Tween<double>(
              begin: preferredBodyHeight,
              end: otherBodyPreferences.preferredBodyHeight)
          .evaluate(animation),
    );
  }
}

class CurvedTopBarPreferences extends TopBarPreferences {
  final double preferredTopBarAmplitude;
  final double preferredTopBarWaveLerp;
  final double preferredTopBarWaveOffset;
  final double preferredTopBarWaveFrequency;

  CurvedTopBarPreferences({
    Color preferredTopBarColor,
    double preferredTopBarFractionalHeight,
    this.preferredTopBarAmplitude = 1.0,
    this.preferredTopBarWaveLerp = 0.0,
    this.preferredTopBarWaveOffset = 1.0,
    this.preferredTopBarWaveFrequency = 1.0,
  }) : super(
            preferredTopBarFractionalHeight: preferredTopBarFractionalHeight,
            preferredTopBarColor: preferredTopBarColor);

  static CurvedTopBarPreferences from(TopBarPreferences topBarPreferences) {
    return CurvedTopBarPreferences(
      preferredTopBarColor: topBarPreferences.preferredTopBarColor,
      preferredTopBarFractionalHeight:
          topBarPreferences.preferredTopBarFractionalHeight,
    );
  }

  @override
  TopBarPreferences lerpTo(
      TopBarPreferences otherTopBarPreferences, Animation<double> animation) {
    var lerpedSuper = super.lerpTo(otherTopBarPreferences, animation);
    if (otherTopBarPreferences is CurvedTopBarPreferences) {
      var otherCurve = otherTopBarPreferences as CurvedTopBarPreferences;
      return CurvedTopBarPreferences(
        preferredTopBarColor: lerpedSuper.preferredTopBarColor,
        preferredTopBarFractionalHeight:
            lerpedSuper.preferredTopBarFractionalHeight,
        preferredTopBarAmplitude: Tween<double>(
          begin: preferredTopBarAmplitude,
          end: otherCurve.preferredTopBarAmplitude,
        ).evaluate(animation),
        preferredTopBarWaveLerp: Tween<double>(
          begin: preferredTopBarWaveLerp,
          end: otherCurve.preferredTopBarWaveLerp,
        ).evaluate(animation),
        preferredTopBarWaveFrequency: Tween<double>(
          begin: preferredTopBarWaveFrequency,
          end: otherCurve.preferredTopBarWaveFrequency,
        ).evaluate(animation),
        preferredTopBarWaveOffset: Tween<double>(
          begin: preferredTopBarWaveOffset,
          end: otherCurve.preferredTopBarWaveOffset,
        ).evaluate(animation),
      );
    } else {
      return CurvedTopBarPreferences.from(lerpedSuper);
    }
  }
}

class TopBarPreferences {
  final double preferredTopBarFractionalHeight;
  final Color preferredTopBarColor;

  TopBarPreferences(
      {this.preferredTopBarFractionalHeight, this.preferredTopBarColor});

  TopBarPreferences lerpTo(
      TopBarPreferences otherTopBarPreferences, Animation<double> animation) {
    return TopBarPreferences(
      // Is there a way to dyanmically loop through properties as types T?
      preferredTopBarFractionalHeight: Tween<double>(
              begin: preferredTopBarFractionalHeight,
              end: otherTopBarPreferences.preferredTopBarFractionalHeight)
          .evaluate(animation),
      preferredTopBarColor: Tween<Color>(
              begin: preferredTopBarColor,
              end: otherTopBarPreferences.preferredTopBarColor)
          .evaluate(animation),
    );
  }
}

/// This widget handles the displaying of a [TopBarPageItem]. It's similar to the [Scaffold] widget, but unlike [Scaffold] the [SliverTopBarToContainer] allows us to have an [AppBar] which lets it's children decide the size
class TopBarPage extends StatefulWidget {
  final Widget Function(BuildContext context) buildTopBar;
  final Widget Function(BuildContext context) buildBody;
  final bool isScrollable;
  final double preferredBodyHeight;
  final double topBarFractionalHeight;
  final Color color;

  TopBarPage({
    @required this.buildTopBar,
    @required this.buildBody,
    this.preferredBodyHeight,
    this.topBarFractionalHeight,
    this.color,
    this.isScrollable = false,
  });

  /// A convenience intializer for classes that conform to the [TopBarPageItem] protocol
  // static TopBarPage fromTopBarPageItem(
  //     BuildContext context, TopBarPageItem item) {
  //   return TopBarPage(
  //     buildTopBar: item.buildTopBar,
  //     buildBody: item.buildBody,
  //     preferredBodyHeight: item.getPreferredBottomBarHeight(context),
  //     topBarFractionalHeight: item.getPreferredTopBarFractionalHeight(context),
  //     color: item.preferredBodyColor,
  //   );
  // }

  @override
  TopBarPageState createState() {
    return new TopBarPageState();
  }
}

class TopBarPageState extends State<TopBarPage>
    with SliverTopBarToContainerDelegate {
  final DataStream<double> topBarHeightStream = DataStream(0.0);

  @override
  void dispose() {
    super.dispose();
    topBarHeightStream.close();
  }

  @override
  Widget build(BuildContext context) {
    var hasBottomBarHeight = widget.preferredBodyHeight != null;
    var hasTopBarFractionalHeight = widget.topBarFractionalHeight != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        var totalHeight = constraints.maxHeight;
        var fractionalTopHeight =
            (1 - ((widget.preferredBodyHeight ?? 0) / totalHeight)) *
                totalHeight;
        var topBarHeight = hasBottomBarHeight
            ? fractionalTopHeight
            : (hasTopBarFractionalHeight
                ? widget.topBarFractionalHeight * totalHeight
                : null);
        var sliverTopBar = SliverTopBarToContainer(
          delegate: this,
          child: Container(
            child: widget.buildTopBar(context),
            height: topBarHeight,
          ),
        );
        var sliverBody = SliverToBoxAdapter(
          child: widget.isScrollable
              ? widget.buildBody(context)
              : StreamBuilder<double>(
                  initialData: topBarHeightStream.value,
                  stream: topBarHeightStream.valueObservable,
                  builder: (context, snapshot) {
                    var topBarHeight = snapshot.data ?? 0;
                    var bodyHeight = totalHeight - topBarHeight;
                    return Container(
                      child: widget.buildBody(context),
                      height: bodyHeight,
                    );
                  },
                ),
        );
        return Container(
          color: widget.color,
          child: CustomScrollView(
            physics: (widget.isScrollable == false ||
                    widget.preferredBodyHeight != null)
                ? NeverScrollableScrollPhysics()
                : ScrollPhysics(),
            slivers: [
              sliverTopBar,
              sliverBody,
            ],
          ),
        );
      },
    );
  }

  @override
  Function topBarHeightChanged(double height) {
    topBarHeightStream.value = height;
    return null;
  }
}
