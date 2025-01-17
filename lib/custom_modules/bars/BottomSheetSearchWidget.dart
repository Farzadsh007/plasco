import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/color_palette.dart';

import '../../strings.dart';

class BottomSheetSearchWidget extends StatefulWidget {
  final Function(String searchText) onSearch;

  const BottomSheetSearchWidget({Key key, this.onSearch})
      : super(key: key);

  @override
  _BottomSheetSearchWidgetState createState() =>
      _BottomSheetSearchWidgetState(this.onSearch);
}

class _BottomSheetSearchWidgetState
    extends State<BottomSheetSearchWidget> {
  _BottomSheetSearchWidgetState(this.onSearch);

  Function(String searchText) onSearch;

  TextEditingController controller = TextEditingController();

  void search() {
    if (this.onSearch != null /*&& controller.text.trim().isNotEmpty*/)
      this.onSearch.call(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return  Row(
          mainAxisSize: MainAxisSize.max,
          textDirection: TextDirection.rtl,
          children: [

            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    decoration: BoxDecoration(color: ColorPalette.White1,
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      border: Border.all(
                        color: ColorPalette.Gray1.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Material(
                            shape: CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Icon(
                                Icons.search,
                                color: ColorPalette.Gray2,
                              ),
                              onPressed: () {
                                search();
                              },
                            )),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: TextFormField(
                            controller: controller,
                            textInputAction: TextInputAction.search,
                            cursorHeight: 20,
                            textAlign: TextAlign.right,
                            onFieldSubmitted: (value) {
                              search();
                            },
                            style: TextStyle(
                                color: ColorPalette.Black1,
                                fontFamily: 'IRANSansMobile',
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                height: 1),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: ColorPalette.Gray2,
                                  fontFamily: 'IRANSansMobile',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                              hintText:
                                  Strings.BarTopAppBarWithSearchWidget_Search,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ))
                      ],
                    ),
                  )),
            )
          ])
   ;
  }
}
