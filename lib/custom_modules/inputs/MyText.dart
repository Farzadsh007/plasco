import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final Color color;
  final FontWeight fontWeight;
  final double fontSize;
  final int maxLines;

  const MyText(
      {Key key,
      this.text,
      this.textAlign,
      this.color,
      this.fontWeight,
      this.fontSize,
      this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          this.text,
          overflow: TextOverflow.ellipsis,
          maxLines: this.maxLines != null ? this.maxLines : 1,
          textAlign: this.textAlign != null ? this.textAlign : TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: this.color,
            fontFamily: 'IRANSansMobile',
            fontSize: this.fontSize,
            letterSpacing: 0,
            fontWeight: this.fontWeight,
          ),
        ));
  }
}
