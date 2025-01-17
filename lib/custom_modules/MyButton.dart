import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color_palette.dart';
import 'inputs/MyText.dart';

class MyButton extends StatelessWidget {
  final String text;
  final ButtonFillStyle buttonFill;
  final Function onPressed;

  MyButton({Key key, this.text, this.buttonFill, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle raisedButtonStyle = (buttonFill == ButtonFillStyle.White)
        ? ElevatedButton.styleFrom(
                side: BorderSide(
                  color: ColorPalette.Yellow1,
                ),
//shadowColor: Colors.transparent,
                primary: ColorPalette.White1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ))
            .copyWith(
                overlayColor: MaterialStateProperty.all<Color>(
                    ColorPalette.Yellow1.withOpacity(0.1)))
        : ElevatedButton.styleFrom(
//shadowColor: Colors.transparent,
            primary: ColorPalette.Yellow1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ));

    return ElevatedButton(
        autofocus: false,
        clipBehavior: Clip.none,
        style: raisedButtonStyle,
        onPressed: () {
          if (this.onPressed != null) this.onPressed();
        },
        child: MyText(
          text: this.text,
          textAlign: TextAlign.center,
          color: buttonFill == ButtonFillStyle.White
              ? ColorPalette.Yellow1
              : ColorPalette.White1,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ));
  }
}

enum ButtonFillStyle { Yellow, White }
