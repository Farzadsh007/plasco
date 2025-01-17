import 'dart:async';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plasco/blocs/ChooseFileBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/MyButton.dart';
import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/ChooseFile.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/Location.dart';
import 'package:plasco/custom_modules/inputs/ChoosePhoto.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/anomaly/anomaly.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';
import 'NewActionPageWidget.dart';
import 'ViewAnomalyPageWidget.dart';

class NewAnomalyPageWidget extends StatefulWidget {


  const NewAnomalyPageWidget({Key key }) : super(key: key);
  @override
  _NewAnomalyPageWidgetState createState() => _NewAnomalyPageWidgetState( );
}

class _NewAnomalyPageWidgetState extends State<NewAnomalyPageWidget> {
  _NewAnomalyPageWidgetState( );
  MyBloc httpBloc = MyBloc();

  List<Uint8List> files = [];
  Anomaly anomaly = Anomaly();
  final ChooseFileBloc chooseFileBloc = ChooseFileBloc();
  TextEditingController newAnomalyPageWidgetTitleController =
      TextEditingController();
  TextEditingController newAnomalyPageWidgetDetailController =
      TextEditingController();

  final _riskStreamController = StreamController<riskType>.broadcast();

  StreamSink<riskType> get riskSink => _riskStreamController.sink;

  Stream<riskType> get streamRisk => _riskStreamController.stream;

  final _refreshFilesStreamController = StreamController<bool>.broadcast();

  StreamSink<bool> get refreshFilesSink => _refreshFilesStreamController.sink;

  Stream<bool> get streamRefreshFiles => _refreshFilesStreamController.stream;
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
      if (event is int ) {

       await locator<Web>().post(AnomalyGetListEvent(locator<Constants>().anomalyListHttpBloc,''), context);

       Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewAnomalyPageWidget(
          anomalyId: event,
            )));
      }
    });

    chooseFileBloc.streamChooseFile.listen((event) {
      this.files.add(event);
      refreshFilesSink.add(true);
    });
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    chooseFileBloc.dispose();
    httpBloc.dispose();
    _riskStreamController.close();
    _refreshFilesStreamController.close();
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
                                  text: Strings.NewAnomalyPageWidget_new,
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
                                SizedBox(height: 16),
                                Center(
                                    child: Column(
                                  children: [
                                    SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: StreamBuilder(
                                            stream: streamRefreshFiles,
                                            builder: (context,
                                                AsyncSnapshot<bool> snapshot) {
                                              List<Widget> children = [];

                                              if (files.length < 4) {
                                                children
                                                    .add(addNewImageWidget());
                                              }
                                              for (Uint8List file in files) {
                                                children
                                                    .add(addImageWidget(file));
                                              }

                                              return Row(
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  children: children);
                                            })),
                                    SizedBox(height: 16),
                                    MyText(
                                      text: Strings
                                          .NewAnomalyPageWidget_max_pictures,
                                      textAlign: TextAlign.center,
                                      color: ColorPalette.Gray1,
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                    )
                                  ],
                                )),
                                SizedBox(height: 24),
                                MyTextFormField(
                                  controller:
                                      newAnomalyPageWidgetTitleController,
                                  text: Strings.NewAnomalyPageWidget_detail,
                                  hint: Strings.NewAnomalyPageWidget_detail,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.text,
                                  maxLength: 100,
                                  maxLines: 2,validator:AnomalyTitleValidator(5)
                                ),
                                SizedBox(height: 24),
                                MyDropDownFormField(
                                  selected: null,
                                  httpEvent: DropDownGetRelatedCompanyEvent(),
                                  bottomSheetTitle: Strings
                                      .BottomSheetWidgetRelatedCompany_title,
                                  text: Strings.NewAnomalyPageWidget_subFactory,
                                  hint: Strings.NewAnomalyPageWidget_subFactory,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  onChange: (newValue) {
                                    anomaly.target = newValue.id;
                                  },
                                ),
                                SizedBox(height: 24),
                                MyDropDownFormField(
                                  httpEvent: DropDownCityMapEvent.withEnum(
                                      mapForEnum.Select),
                                  bottomSheetTitle:
                                      Strings.BottomSheetWidget_Location_title,
                                  text: Strings.NewAnomalyPageWidget_location,
                                  hint: Strings.NewAnomalyPageWidget_location,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  onChange: (newValue) {
                                    anomaly.location =
                                        int.parse(newValue.data['locationId']);
                                    anomaly.location_category =
                                        int.parse(newValue.data['categoryId']);
                                  },
                                ),
                                SizedBox(height: 24),
                                MyDropDownFormField(
                                  selected: null,
                                  httpEvent: DropDownGetAnomalyCategoryEvent(),
                                  bottomSheetTitle:
                                      Strings.NewAnomalyPageWidget_category,
                                  text: Strings.NewAnomalyPageWidget_category,
                                  hint: Strings.NewAnomalyPageWidget_category,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  onChange: (newValue) {
                                    anomaly.category = newValue.id;
                                  },
                                ),
                                SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: MyText(
                                    text: Strings.NewAnomalyPageWidget_Risk,
                                    textAlign: TextAlign.right,
                                    color: ColorPalette.Gray1,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 8),
                                StreamBuilder(
                                    stream: streamRisk,initialData: riskType.Low,
                                    builder: (context,
                                        AsyncSnapshot<riskType> snapshot) {
                                      riskType risk = riskType.None;
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        risk = snapshot.data;
                                        if(anomaly.risk_type==null){

                                          anomaly.risk_type = riskType.Low;
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
                                                    riskSink.add(riskType.Low);
                                                    anomaly.risk_type =
                                                        riskType.Low;
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: risk !=
                                                                    riskType.Low
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
                                                              .NewAnomalyPageWidget_Risk_low,
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
                                                  onTap: () {
                                                    riskSink
                                                        .add(riskType.Moderate);
                                                    anomaly.risk_type =
                                                        riskType.Moderate;
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: risk !=
                                                                    riskType
                                                                        .Moderate
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
                                                              .NewAnomalyPageWidget_Risk_medium,
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
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  onTap: () {
                                                    riskSink.add(riskType.High);
                                                    anomaly.risk_type =
                                                        riskType.High;
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: risk !=
                                                                    riskType
                                                                        .High
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
                                                              .NewAnomalyPageWidget_Risk_high,
                                                          textAlign:
                                                              TextAlign.center,
                                                          color:
                                                              ColorPalette.Red1,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ))),
                                            )
                                          ]);
                                    }),
                                SizedBox(height: 24),
                                MyTextFormField(
                                  controller:
                                      newAnomalyPageWidgetDetailController,
                                  text: Strings.NewAnomalyPageWidget_details,
                                  hint: Strings.NewAnomalyPageWidget_details,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  counterFontSize: 10,
                                  textAlign: TextAlign.right,
                                  keyboardType: TextInputType.text,
                                  maxLength: 400,
                                  maxLines: 4,
                                ),
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
                                      text: Strings.NewAnomalyPageWidget_cancel,
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
                                        text: Strings.NewAnomalyPageWidget_send,
                                        buttonFill: ButtonFillStyle.Yellow,
                                        onPressed: () {
                                          if( _formKey.currentState.validate()){
                                            this.anomaly.title =
                                                newAnomalyPageWidgetTitleController
                                                    .text;
                                            this.anomaly.description =
                                                newAnomalyPageWidgetDetailController
                                                    .text;

                                            this.anomaly.files = this.files;
                                            locator<Web>().post(
                                                AnomalyAddEvent(
                                                    httpBloc, this.anomaly),
                                                context);
                                          }

                                        })),
                              )
                            ],
                          ),
                        )
                      ])))))),
    );
  }

  addNewImageWidget() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ChoosePhoto(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              //enableDrag: false,//enable drag false only for map
              builder: (context) {
                return BottomSheetWidget(
                  title: Strings.BottomSheetWidget_ChooseFile_title,
                  content: ChooseFileWidget(
                      chooseFileBloc: chooseFileBloc, enableEdit: true),
                );
              });
        },
      ),
    );
  }

  addImageWidget(Uint8List file) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          // width: 136,
          height: 136,
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ExtendedImage.memory(
                    file,
                    fit: BoxFit.cover,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: (ExtendedImageState state) {
                      return GestureConfig(
                        //you must set inPageView true if you want to use ExtendedImageGesturePageView
                        inPageView: true,
                        initialScale: 1.0,
                        minScale: 1.0,
                        maxScale: 5.0,
                        animationMaxScale: 6.0,
                        initialAlignment: InitialAlignment.center,
                      );
                    },
                  )),
              Positioned(
                  left: 0,
                  top: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          this.files.remove(file);

                          refreshFilesSink.add(true);
                        },
                        child: Container(
                            clipBehavior: Clip.antiAlias,
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: CrossPlatformSvg.asset(
                                assetPath: 'assets/vectors/Icons/WithBG.svg',
                                height: 24,
                                width: 24,
                                fit: BoxFit.fitHeight))),
                  ))
            ],
          )),
    );
  }
}
