import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CurvedBottomClipper extends CustomClipper<Path> {
  final double amplitude;
  final double circleFraction;
  final double strideResolution = 5;
  final double waveLerp;
  final double waveOffset;
  final double waveFrequency;
  Size size;

  CurvedBottomClipper(
      {@required this.amplitude,
      this.circleFraction = 0.3,
      this.waveLerp = 0.0,
      this.waveOffset = 0.0,
      this.waveFrequency = 1.0})
      : assert(circleFraction <= 1.0),
        assert(1 >= waveLerp && waveLerp >= 0);

  double getExpectedCircleSize(double expectedWidth) {
    return (circleDeltaHeightFraction *
        ((expectedWidth * 0.5) / circleFraction) *
        amplitude);
  }

  double get circleDeltaHeightFraction {
    return _circleSampleYFraction(0.0) - _circleSampleYFraction(0.5);
  }

  double get circleYFractionReachMin {
    return min(_circleSampleYFraction(0.0), _circleSampleYFraction(0.5));
  }

  @override
  getClip(Size size) {
    this.size = size;
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(0.0, 0.0);
    double circleFractionSmallestY = circleYFractionReachMin;
    double circleDeltaHeight = getExpectedCircleSize(size.width);
    double waveHeight = circleDeltaHeight.abs();
    int fragments = (size.width / strideResolution).round();
    for (int i = 0; i <= fragments; i++) {
      double fraction = i.toDouble() / fragments.toDouble();
      double xPos = (fraction) * size.width;
      double circleY = _getCircleY(
        fraction,
        circleFractionSmallestY,
        circleDeltaHeight,
      );
      double waveY = _getWaveY(fraction, waveHeight);
      path.lineTo(xPos, waveLerp * waveY + (1 - waveLerp) * circleY);
    }

    path.close();
    return path;
  }

  double _getWaveY(double fraction, double waveHeight) {
    return size.height - _waveSampleYFraction(fraction) * waveHeight;
  }

  double _getCircleY(double fraction, double fractionCompensationY,
      double circleDeltaHeightY) {
    double yFractionCircle =
        _circleSampleYFraction(fraction) - fractionCompensationY;
    double yPosCircle =
        yFractionCircle * ((size.width * 0.5) / circleFraction) * amplitude;
    double yPosCircleFinal =
        (size.height - max(circleDeltaHeightY, 0.0)) - yPosCircle;
    return yPosCircleFinal;
  }

  double _waveSampleYFraction(double fraction) {
    var frequency = waveFrequency * fraction * pi * 2;
    var baseOffset = 0.5 * pi;
    var cosValue = cos(frequency + baseOffset + waveOffset * pi);
    var lerpValue = cosValue * 0.5 + 0.5;
    return lerpValue;
  }

  /// A (co)sine wave is not circular, so we'll have to go with some pythagorean mathematics to create a truly circular bend
  double _circleSampleYFraction(double fraction) {
    var radius = 1.0;
    var lerpA = circleFraction;
    var lerpB = 1.0 - circleFraction;
    var samplePos = (lerpB / 2) + fraction * lerpA;
    //print("samplePos for $fraction is $samplePos");
    var aanliggend = radius - samplePos * radius * 2.0;
    if (aanliggend == 0) return 1;
    var phi = acos(aanliggend / radius);
    var overstaand = tan(phi) * aanliggend;
    return overstaand;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
    if (oldClipper is CurvedBottomClipper) {
      return oldClipper.amplitude != amplitude || oldClipper.size != size;
    } else {
      return true;
    }
  }
}
