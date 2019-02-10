import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Widget child;
  final Function onPressed;

  Button({@required this.child, this.onPressed}) : assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: child, onTap: onPressed);
  }
}
