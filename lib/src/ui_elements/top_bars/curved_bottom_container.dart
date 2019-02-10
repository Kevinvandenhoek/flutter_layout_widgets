import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/pages/top_bar_page/top_bar_page.dart';
import 'package:tf_layout_widgets/src/ui_elements/clippers/curved_bottom_clipper.dart';

class CurvedBottomContainer extends StatelessWidget {
  final double amplitude;
  final double waveLerp;
  final double waveOffset;
  final double waveFrequency;
  final Decoration decoration;
  final Color color;
  final Widget child;

  CurvedBottomContainer({
    this.decoration,
    this.color,
    this.amplitude = 1.0,
    this.waveLerp = 0.0,
    this.waveOffset = 0.0,
    this.waveFrequency = 1.0,
    this.child,
  }) : assert(decoration != null ? color == null : true);

  static CurvedBottomContainer from(CurvedTopBarPreferences preferences,
      Widget centerView, Widget bottomView, Function onBackButtonPressed) {
    return CurvedBottomContainer(
      amplitude: preferences.preferredTopBarAmplitude,
      waveLerp: preferences.preferredTopBarWaveLerp,
      waveFrequency: preferences.preferredTopBarWaveFrequency,
      waveOffset: preferences.preferredTopBarWaveOffset,
      color: preferences.preferredTopBarColor,
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
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
