import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';

import '../../strings.dart';
import 'MyText.dart';

class ChoosePhoto extends StatelessWidget {
  final Function onPressed;

  const ChoosePhoto({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            onTap: () {
              if (this.onPressed != null) this.onPressed();
            },
            child: DottedBorder(
                padding: EdgeInsets.all(8),
                radius: Radius.circular(16),
                color: ColorPalette.Gray2,
                borderType: BorderType.RRect,
                strokeWidth: 1,
                dashPattern: [4, 4],
                strokeCap: StrokeCap.square,
                child: Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    color: ColorPalette.Gray3,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: ColorPalette.Gray2,
                          ),
                          Positioned(
                            right: 0,
                            top: -4,
                            child: Container(
                                decoration: BoxDecoration(
                                  color: ColorPalette.Yellow1,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  border: Border.all(
                                      color: ColorPalette.White1, width: 2),
                                ),
                                child: Icon(Icons.add,
                                    size: 16, color: ColorPalette.White1)),
                          )
                        ],
                      ),
                      MyText(
                        text: Strings.Input_choose_photo_title,
                        textAlign: TextAlign.right,
                        color: ColorPalette.Gray1,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      )
                    ],
                  ),
                ))));
  }
}
