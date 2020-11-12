import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyFrame extends StatelessWidget {

  Widget child;
  Color color = Colors.white;

  MyFrame({this.child, this.color, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var s = MediaQuery.of(context).size;
      var w = min(constrains.maxWidth, s.width);
      var h = min(constrains.maxHeight, s.height - Theme.of(context).textTheme.headline4.fontSize);


      var aspectRatio = w/h;
      if (w > 600 && h > 600) {
        if (aspectRatio > 15 / 9) {
          w *= 0.9;
        } else if (aspectRatio > 4 / 3) {
          w *= 0.9;
        } else if (aspectRatio < 1/2) {
          w *= 0.98;
        } else {
          w *= 0.96;
        }
      } else {
        w *= 0.96;
      }

      return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color
          ),
          child: SizedBox(
          width: w,
          height: h,
          child: child));
      });
  }
}