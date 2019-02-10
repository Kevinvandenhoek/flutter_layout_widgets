import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';
import 'package:tf_layout_widgets/src/ui_elements/clippers/curved_bottom_clipper.dart';
import 'package:tf_layout_widgets/src/ui_elements/top_bars/top_bar.dart';

class CurvedTopBar extends StatelessWidget {
  final double amplitude;
  final double waveLerp;
  final double waveOffset;
  final double waveFrequency;
  final Decoration decoration;
  final Color color;
  final Function onBackButtonPressed;
  final Widget centerView;
  final Widget bottomView;

  CurvedTopBar({
    this.centerView,
    this.bottomView,
    this.decoration,
    this.color,
    this.amplitude = 1.0,
    this.waveLerp = 0.0,
    this.waveOffset = 0.0,
    this.waveFrequency = 1.0,
    this.onBackButtonPressed,
  })  : assert(decoration != null ? color == null : true),
        assert(onBackButtonPressed != null);

  static CurvedTopBar from(CurvedTopBarPreferences preferences,
      Widget centerView, Widget bottomView, Function onBackButtonPressed) {
    return CurvedTopBar(
      amplitude: preferences.preferredTopBarAmplitude,
      waveLerp: preferences.preferredTopBarWaveLerp,
      waveFrequency: preferences.preferredTopBarWaveFrequency,
      waveOffset: preferences.preferredTopBarWaveOffset,
      color: preferences.preferredTopBarColor,
      centerView: centerView,
      bottomView: bottomView,
      onBackButtonPressed: onBackButtonPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          var clipper = CurvedBottomClipper(
            amplitude: amplitude,
            waveLerp: waveLerp,
            waveOffset: waveOffset,
            waveFrequency: waveFrequency,
          );
          var expectedSize =
              clipper.getExpectedCircleSize(constraints.maxWidth).abs();
          return ClipPath(
            clipper: clipper,
            child: Container(
              color: color,
              decoration: decoration,
              child: Container(
                margin: EdgeInsets.only(bottom: expectedSize),
                child: TopBar(
                  onBackButtonPressed: onBackButtonPressed,
                  centerView: centerView,
                  bottomView: bottomView,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
