import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';

import '../../inputs/MyText.dart';

class WorkingFieldWidget extends StatefulWidget {
  WorkingFieldWidget(
      {Key key,
      })
      : super(key: key);



  @override
  _WorkingFieldWidgetState createState() => _WorkingFieldWidgetState(
      );
}

class _WorkingFieldWidgetState extends State<WorkingFieldWidget> {
  _WorkingFieldWidgetState( );


  int selectedRadio;

  Widget getListItem(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: MyText(
            text: 'Strings',
            textAlign: TextAlign.right,
            color: ColorPalette.Black1,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        )),
        Radio(
          activeColor: ColorPalette.Yellow1,
          value: index,
          groupValue: selectedRadio,
          onChanged: (val) {
            setState(() {
              selectedRadio = val;
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            height: 200,
            child: SingleChildScrollView(
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
                    shrinkWrap: true,
                    itemCount: 20,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (BuildContext context, int index) {
                      return getListItem(index);
                    }))),
      ],
    );
  }
}
