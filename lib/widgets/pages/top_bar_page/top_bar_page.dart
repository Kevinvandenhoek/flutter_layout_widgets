import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/widgets/pages/top_bar_page/sliver_top_bar/sliver_top_bar.dart';
import 'package:tf_layout_widgets/widgets/rx/stream_item.dart';

/// A [TopBarPageItem] is a page that has a top bar, which is similar to an [AppBar], but unlike the [AppBar] dynamically sizes to it's child's needs. It is recommended to see the Object that extends this behaviour as the widget controller, which controls the supplemented topbar and body.
abstract class TopBarPageItem {
  Widget buildBody(BuildContext context);

  //Widget buildTopBar(BuildContext context);

  Widget buildTopBarCenterView(BuildContext context) {
    return null;
  }

  Widget buildTopBarBottomView(BuildContext context) {
    return null;
  }

  double get preferredBodyHeight {
    return null;
  }

  double get preferredTopBarFractionalHeight {
    return null;
  }

  Color get preferredTopBarColor {
    return Colors.blue.shade200;
  }

  Color get preferredBodyColor {
    return Colors.grey.shade200;
  }

  bool get isScrollable {
    return false;
  }

  //TODO: pack the values below as 'CurvedBottomBarConfiguration'
  double get preferredTopBarAmplitude {
    return 1.0;
  }

  double get preferredTopBarWaveLerp {
    return 0.0;
  }

  double get preferredTopBarWaveOffset {
    return 1.0;
  }

  double get preferredTopBarWaveFrequency {
    return 1.0;
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
