import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tf_layout_widgets/src/ui_elements/buttons/button.dart';

class TopBar extends StatelessWidget {
  final Decoration decoration;
  final Color color;
  final Function onBackButtonPressed;
  final Widget centerView;
  final Widget bottomView;

  final double buttonContainerSize = 60;

  TopBar({
    this.color,
    this.decoration,
    this.onBackButtonPressed,
    this.centerView,
    this.bottomView,
  })  : assert(decoration != null ? color == null : true),
        assert(onBackButtonPressed != null);

  @override
  Widget build(BuildContext context) {
    var row = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Button(
          child: _buildSquareButtonContainer(
            child: Container(
              color: Colors.transparent,
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
          onPressed: () {
            onBackButtonPressed();
          },
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: centerView ?? Container(),
              ),
              Container(child: _buildSquareButtonContainer()),
            ],
          ),
        ),
      ],
    );
    var safeAreaInsets = MediaQuery.of(context).padding;
    return Container(
      decoration: decoration,
      margin: EdgeInsets.only(
        top: safeAreaInsets.top,
        left: safeAreaInsets.left,
        right: safeAreaInsets.right,
      ),
      child: Column(
        children: [row, bottomView ?? Container()],
      ),
    );
  }

  Widget _buildSquareButtonContainer({Widget child}) {
    return Container(
      child: child,
      width: buttonContainerSize,
      height: buttonContainerSize,
    );
  }
}
