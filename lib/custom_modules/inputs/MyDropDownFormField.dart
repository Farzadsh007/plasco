import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plasco/blocs/SelectedItemBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/color_palette.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseItemWithSearch.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseRelatedCompany.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/Location.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/DropDownItem.dart';

class MyDropDownFormField extends StatefulWidget {
  final String text;
  final FontWeight fontWeight;
  final double fontSize;

  final String hint;
  final Function(DropDownItem newValue) onChange;

  final HttpEvent httpEvent;

  final String bottomSheetTitle;
  final DropDownItem selected;
//final DropDownValidator validator;
  const MyDropDownFormField(
      {Key key,
      this.text,
      this.fontWeight,
      this.fontSize,
      this.hint,
      this.onChange,
      this.httpEvent,
      @required this.bottomSheetTitle,
      this.selected,
      /*this.validator*/})
      : super(key: key);

  @override
  _MyDropDownFormFieldState createState() => _MyDropDownFormFieldState(
      this.text,
      this.fontWeight,
      this.fontSize,
      this.hint,
      this.onChange,
      this.httpEvent,
      this.bottomSheetTitle,
      this.selected,
      /*this.validator*/);
}

class _MyDropDownFormFieldState extends State<MyDropDownFormField> {
  String text;
  FontWeight fontWeight;
  double fontSize;

  String hint;
  Function(DropDownItem newValue) onChange;

  HttpEvent httpEvent;
  String bottomSheetTitle;
  SelectedItemBloc selectedItemBloc = SelectedItemBloc();
  //DropDownValidator validator;
  DropDownValidator validator=DropDownValidator();
  _MyDropDownFormFieldState(
      this.text,
      this.fontWeight,
      this.fontSize,
      this.hint,
      this.onChange,
      this.httpEvent,
      this.bottomSheetTitle,
      this.selected,
      /*this.validator*/);

  DropDownItem selected;
  var txt = TextEditingController();
  bool _hasError=false;
  String _error='';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (selected != null) {
      txt.text = selected.value;
    }
    selectedItemBloc.streamSelectedItem.listen((event) {
      selected = event;
      txt.text = event.value;

      if (onChange != null) onChange(event);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    selectedItemBloc.dispose();
    //httpEvent.bloc.dispose(); //todo remove bloc , you can change constructor of httpevent to inherit bloc for other classes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: txt, validator:this.httpEvent == null ?null: (text) {
              if(this.validator==null){
                return null;
              }else{
                if(this.validator.hasError(text)){
                  setState(() =>  _hasError=true);
                  _error=this.validator.getError();
                  return '';
                }else{
                  setState(() =>  _hasError=false);
                  return null;
                }
              }

            },
              style: TextStyle(
                  color: ColorPalette.Black1,
                  fontFamily: 'IRANSansMobile',
                  fontSize: this.fontSize,
                  letterSpacing: 0,
                  fontWeight: this.fontWeight,
                  height: 1),
              decoration: InputDecoration(
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: ColorPalette.Gray2,
                ),
                labelStyle: TextStyle(
                    color:_hasError?ColorPalette.Red1 : ColorPalette.Gray1,
                    fontFamily: 'IRANSansMobile',
                    fontSize: this.fontSize,
                    letterSpacing: 0,
                    fontWeight: this.fontWeight,
                    height: 1),
                hintStyle: TextStyle(
                    color: ColorPalette.Gray2,
                    fontFamily: 'IRANSansMobile',
                    fontSize: this.fontSize,
                    letterSpacing:
                        0 /*percentages not used in flutter. defaulting to zero*/,
                    fontWeight: this.fontWeight,
                    height: 1),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Gray2,
                      width: 1.0,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Gray2,
                      width: 1.0,
                    )), focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide: BorderSide(
                    color: ColorPalette.Red1,
                    width: 1.0,
                  )),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(
                      color: ColorPalette.Red1,
                      width: 1.0,
                    )),
                labelText:_hasError?_error: this.text,
                hintText: this.hint,
                enabled: false,
                contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              ),
              autofocus: false,
            )),
        Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  onTap: () {
                    if (this.httpEvent != null &&
                        (this.httpEvent is! DropDownCityGetContentEvent ||
                            (this.httpEvent is DropDownCityGetContentEvent &&
                                (this.httpEvent as DropDownCityGetContentEvent)
                                        .province !=
                                    -1))) {
                      Widget content = ChooseItemWithSearchWidget(
                        selectedItemBloc: this.selectedItemBloc,
                        httpEvent: this.httpEvent,
                        selected: selected,
                      );
                      if (httpEvent is DropDownCityMapEvent) {
                        content = LocationWidget(
                          selectedItemBloc: this.selectedItemBloc,
                          forEnum:
                              (httpEvent as DropDownCityMapEvent).getForEnum(),
                        );
                      } else if (httpEvent is DropDownGetRelatedCompanyEvent) {
                        content = ChooseRelatedCompanyWidget(
                          selectedItemBloc: this.selectedItemBloc,
                          httpEvent: this.httpEvent,
                          selected: selected,
                        );
                      }

                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          enableDrag: content is! LocationWidget,
                          //enable drag false only for map
                          builder: (context) {
                            return BottomSheetWidget(
                              title: this.bottomSheetTitle,
                              content: content,
                            );
                          });
                    }
                  },
                )))
      ],
    );
  }
}
