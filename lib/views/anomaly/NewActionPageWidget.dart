import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/DatePicker.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class NewActionPageWidget extends StatefulWidget {
  final int anomalyId;

  const NewActionPageWidget({Key key, this.anomalyId}) : super(key: key);

  @override
  _NewActionPageWidgetState createState() =>
      _NewActionPageWidgetState(this.anomalyId);
}

class _NewActionPageWidgetState extends State<NewActionPageWidget> {
  _NewActionPageWidgetState(this.anomalyId);

  int anomalyId;
  MyBloc httpBloc = MyBloc();
  ActionItem action = ActionItem();
  TextEditingController newActionPageWidgetTitleController =
      TextEditingController();
  TextEditingController newActionPageWidgetDetailController =
      TextEditingController();

  final _deadlineStreamController = StreamController<deadlineType>.broadcast();

  StreamSink<deadlineType> get deadlineSink => _deadlineStreamController.sink;

  Stream<deadlineType> get streamDeadline => _deadlineStreamController.stream;

  final _refreshGroupStreamController = StreamController<HttpEvent>.broadcast();

  StreamSink<HttpEvent> get refreshGroupSink =>
      _refreshGroupStreamController.sink;

  Stream<HttpEvent> get streamRefreshGroup =>
      _refreshGroupStreamController.stream;

  int relatedFactoryId=-1;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Future<bool> _willPopCallback() async {
    bool ret = true;

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    httpBloc.stream.listen((event) async{
      if (event == true) {
       await locator<Web>()
            .post(AnomalyGetDetailsEvent(locator<Constants>().viewAnomalyHttpBloc, this.anomalyId), context);

        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    httpBloc.dispose();
    _deadlineStreamController.close();
    _refreshGroupStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _willPopCallback,
        child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body: Form(
        key: _formKey,child:SafeArea(
              child: Container(
                  color: Colors.transparent,

                  // height: height /2,
                  child: Container(
                      decoration: BoxDecoration(
                        color: ColorPalette.White1,
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: <
                          Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                  width: 1, color: ColorPalette.Black3),
                            )),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child:
                                // SizedBox(width : 268),
                                Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                    child: MyText(
                                  text: Strings.NewActionPageWidget_title,
                                  textAlign: TextAlign.center,
                                  color: ColorPalette.Gray1,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                )),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.close,
                                      color: ColorPalette.Gray2,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorPalette.White1,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Column(children: [
                                MyTextFormField(
                                  controller:
                                      newActionPageWidgetTitleController,
                                  text: Strings.ViewActionPageWidget_detail,
                                  hint: Strings.ViewActionPageWidget_detail,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.text,
                                  maxLength: 100,maxLines: 2,validator:ActionTitleValidator(5)
                                ),
                                SizedBox(height: 24),
                                MyDropDownFormField(
                                  httpEvent: DropDownGetRelatedCompanyEvent(),
                                  bottomSheetTitle: Strings
                                      .BottomSheetWidgetRelatedCompany_title,
                                  text: Strings.ViewActionPageWidget_factory,
                                  hint: Strings.ViewActionPageWidget_choose,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  onChange: (newValue) {
                                    action.group = null;
                                    this.relatedFactoryId=newValue.id;
                                    refreshGroupSink.add(
                                        DropDownGetRelatedGroupEvent(
                                            newValue.id));
                                  },
                                ),
                                SizedBox(height: 24),
                                StreamBuilder(
                                    stream: streamRefreshGroup,
                                    initialData: null,
                                    builder: (context,
                                        AsyncSnapshot<HttpEvent> snapshot) {
                                      return MyDropDownFormField(
                                        key: Key(this.relatedFactoryId.toString()),
                                        httpEvent: snapshot.data,
                                        bottomSheetTitle: Strings
                                            .BottomSheetWidget_Account_groups,
                                        text:
                                            Strings.ViewActionPageWidget_group,
                                        hint:
                                            Strings.ViewActionPageWidget_choose,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        onChange: (newValue) {
                                          action.group = newValue.id;
                                        },
                                      );
                                    }),
                                SizedBox(height: 24),
                                MyTextFormField(
                                  controller:
                                      newActionPageWidgetDetailController,
                                  text: Strings.ViewActionPageWidget_details,
                                  hint: Strings.ViewActionPageWidget_details,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.text,
                                  maxLength: 400,
                                  maxLines: 4,
                                ),
                                SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: MyText(
                                    text: Strings.NewActionPageWidget_deadline,
                                    textAlign: TextAlign.right,
                                    color: ColorPalette.Gray1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 8),
                                StreamBuilder(
                                    stream: streamDeadline,initialData: deadlineType.today,
                                    builder: (context,
                                        AsyncSnapshot<deadlineType> snapshot) {
                                      deadlineType deadline =
                                          deadlineType.today;


                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        deadline = snapshot.data;
                                        if(action.deadline==null){

                                          action.deadline = DateTime.now();
                                        }
                                      }

                                      return Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  onTap: () {
                                                    deadlineSink.add(
                                                        deadlineType
                                                            .immediately);
                                                    action.immediately = true;
                                                    action.deadline =
                                                        DateTime.now();
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: deadline !=
                                                                    deadlineType
                                                                        .immediately
                                                                ? ColorPalette
                                                                    .Gray3
                                                                : ColorPalette
                                                                    .Yellow1,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8))),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color: ColorPalette
                                                                    .Red1
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4))),
                                                        child: MyText(
                                                          text: Strings
                                                              .NewActionPageWidget_urgent,
                                                          textAlign:
                                                              TextAlign.center,
                                                          color:
                                                              ColorPalette.Red1,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ))),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  onTap: () {
                                                    deadlineSink.add(
                                                        deadlineType.today);
                                                    action.immediately = false;
                                                    action.deadline =
                                                        DateTime.now();
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: deadline !=
                                                                    deadlineType
                                                                        .today
                                                                ? ColorPalette
                                                                    .Gray3
                                                                : ColorPalette
                                                                    .Yellow1,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8))),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color: ColorPalette
                                                                    .Yellow1
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4))),
                                                        child: MyText(
                                                          text: Strings
                                                              .NewActionPageWidget_today,
                                                          textAlign:
                                                              TextAlign.center,
                                                          color: ColorPalette
                                                              .Yellow1,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ))),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  onTap: () {
                                                    deadlineSink.add(
                                                        deadlineType.tomorrow);
                                                    action.immediately = false;
                                                    action.deadline =
                                                        DateTime.now().add(
                                                            Duration(days: 1));
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: deadline !=
                                                                    deadlineType
                                                                        .tomorrow
                                                                ? ColorPalette
                                                                    .Gray3
                                                                : ColorPalette
                                                                    .Yellow1,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8))),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color: ColorPalette
                                                                    .Green1
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4))),
                                                        child: MyText(
                                                          text: Strings
                                                              .NewActionPageWidget_tomorrow,
                                                          textAlign:
                                                              TextAlign.center,
                                                          color: ColorPalette
                                                              .Green1,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ))),
                                            ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  onTap: () async {
                                                    dynamic ret =
                                                        await showModalBottomSheet(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            //enableDrag: false,//enable drag false only for map
                                                            builder: (context) {
                                                              return BottomSheetWidget(
                                                                title: Strings
                                                                    .BottomSheetWidget_DatePicker_title,
                                                                content:
                                                                    DatePickerWidget(),
                                                              );
                                                            });

                                                    if (ret is bool) {
                                                      action.immediately =
                                                      false;
                                                      deadlineSink.add(
                                                          deadlineType.other);


                                                      action.deadline = null;
                                                    } else {
                                                      action.immediately =
                                                      false;
                                                      action.deadline =
                                                      ret['date'];
                                                      deadlineSink.add(
                                                          deadlineType.other);

                                                    }
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: deadline !=
                                                                    deadlineType
                                                                        .other
                                                                ? ColorPalette
                                                                    .Gray3
                                                                : ColorPalette
                                                                    .Yellow1,
                                                            width: 2,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8))),
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 8,
                                                                vertical: 2),
                                                        decoration: BoxDecoration(
                                                            color: ColorPalette
                                                                    .Gray1
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4))),
                                                        child: MyText(
                                                          text: action
                                                                      .deadline ==
                                                                  null
                                                              ? Strings
                                                                  .NewActionPageWidget_choose_date
                                                              : action
                                                                  .getFarsiDeadLineDate(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          color: ColorPalette
                                                              .Gray1,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ))),
                                            )
                                          ]);
                                    }),
                              ]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: FractionallySizedBox(
                                  //alignment: Alignment.centerRight,
                                  widthFactor: 1,
                                  child: MyButton(
                                      text: Strings.NewActionPageWidget_cancel,
                                      buttonFill: ButtonFillStyle.White,
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      }),
                                ),
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                    //alignment: Alignment.centerRight,
                                    widthFactor: 1,
                                    child: MyButton(
                                        text: Strings.NewActionPageWidget_send,
                                        buttonFill: ButtonFillStyle.Yellow,
                                        onPressed: () {
                                          if( _formKey.currentState.validate()){
                                            this.action.title =
                                                newActionPageWidgetTitleController
                                                    .text;
                                            this.action.description =
                                                newActionPageWidgetDetailController
                                                    .text;
                                            this.action.anomaly = this.anomalyId;
                                            locator<Web>().post(
                                                AnomalyAddActionEvent(
                                                    httpBloc, this.action),
                                                context);
                                          }

                                        })),
                              )
                            ],
                          ),
                        )
                      ]))))),
        ));
  }
}
