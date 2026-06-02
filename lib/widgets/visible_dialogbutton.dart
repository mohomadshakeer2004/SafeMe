import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class VisibleDialogButton extends DialogButton {
  VisibleDialogButton(
      {required this.stream,
      required this.child,
      this.height = 40.0,
      required this.color,
      required this.onPressed})
      : super(child: child, onPressed: onPressed);
  final Stream<bool> stream;
  final Widget child;
  final double height;
  final Color color;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: this.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Visibility(
              visible: snapshot.data!,
              child: DialogButton(
                child: this.child,
                onPressed: this.onPressed,
                height: this.height,
                color: this.color,
              ));
        });
  }
}
