import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:plasco/blocs/SelectedItemBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';

import 'package:plasco/custom_modules/bottom_sheets/BottomSheetWidget.dart';
import 'package:plasco/custom_modules/bottom_sheets/content/Location.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';

import 'package:plasco/models/location/location.dart';
import 'package:plasco/models/location/location_category.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';
import 'package:plasco/strings.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class NewLocationPageWidget extends StatefulWidget {
  final LocationCategory locationCategory;

  const NewLocationPageWidget({Key key, this.locationCategory})
      : super(key: key);

  @override
  _NewLocationPageWidgetState createState() =>
      _NewLocationPageWidgetState(this.locationCategory);
}

class _NewLocationPageWidgetState extends State<NewLocationPageWidget> {
  _NewLocationPageWidgetState(this.locationCategory);

  LocationCategory locationCategory;

  MyBloc httpBloc = MyBloc();
  SelectedItemBloc selectedItemBloc = SelectedItemBloc();
  TextEditingController locationPageWidgetNameController =
      TextEditingController();

  Future<bool> _willPopCallback() async {
    bool ret = true;
    await locator<Web>().post(
        LocationGetListEvent(locator<Constants>().locationsHttpBloc,''), context);

    return ret;
  }

  @override
  void initState() {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
    if (locationCategory.id != null) {
      Future.delayed(Duration.zero, () {
        locator<Web>()
            .post(LocationGetDetailsEvent(httpBloc, locationCategory), context);
      });
    } else {
      Future.delayed(Duration.zero, () {
        locator<Web>().post(
            LocationPrepareForAddEvent(httpBloc, locationCategory), context);
      });
    }

    selectedItemBloc.streamSelectedItem.listen((event) {
      var ff = '';

      Location location = event.data as Location;

      locator<Web>().post(
          LocationAddEvent(httpBloc, this.locationCategory, location), context);
    });
  }

  @override
  void dispose() {
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    httpBloc.dispose();
    selectedItemBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* final locationPageWidgetCancel = MyButton(
        text: Strings.LocationPageWidget_cancel,
        buttonFill: ButtonFillStyle.White,
        onPressed: () {
          Navigator.of(context).pop();
        });
    final locationPageWidgetSend = MyButton(
        text: Strings.LocationPageWidget_send,
        buttonFill: ButtonFillStyle.Yellow,
        onPressed: () {
          if (this.locationCategory.id == null) {
            this.locationCategory.title = locationPageWidgetNameController.text;
            locator<Web>().post(
                LocationCategoryAddEvent(httpBloc, this.locationCategory),
                context);
          }
        });*/
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
          backgroundColor: ColorPalette.Background,
          body: SafeArea(
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
                                    child: StreamBuilder(
                                        stream: httpBloc.stream,
                                        builder: (context,
                                            AsyncSnapshot<dynamic> snapshot) {
                                          if (snapshot.hasData) {
                                            LocationCategory location = snapshot
                                                .data as LocationCategory;

                                            return MyText(
                                              text: location.id == null
                                                  ? Strings
                                                      .LocationPageWidget_new_title
                                                  : Strings
                                                          .LocationPageWidget_edit_title +
                                                      location.title,
                                              textAlign: TextAlign.center,
                                              color: ColorPalette.Gray1,
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                            );
                                          } else {
                                            return CircularProgressIndicator();
                                          }
                                        })),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    child: Icon(
                                      Icons.close,
                                      color: ColorPalette.Gray2,
                                    ),
                                    onTap: () async {
                                      await locator<Web>().post(
                                          LocationGetListEvent(
                                              locator<Constants>()
                                                  .locationsHttpBloc,''),
                                          context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorPalette.White1,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(children: [
                              /*  StreamBuilder(
                                  stream: httpBloc.stream,
                                  builder: (context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.hasData) {
                                      LocationCategory location =
                                          snapshot.data as LocationCategory;
                                      locationPageWidgetNameController.text =
                                          location.title != null
                                              ? location.title
                                              : '';
                                      return MyTextFormField(
                                        controller:
                                            locationPageWidgetNameController,
                                        text: Strings
                                            .LocationPageWidget_new_category_label,
                                        hint: Strings
                                            .LocationPageWidget_new_category_hint,
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        counterFontSize: 10,
                                        textAlign: TextAlign.right,
                                        keyboardType: TextInputType.name,
                                        maxLength: 20,
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  }),*/
                              SizedBox(height: 24),
                              Align(
                                alignment: Alignment.centerRight,
                                child: MyText(
                                  text: Strings
                                      .LocationPageWidget_this_category_locations_title,
                                  textAlign: TextAlign.right,
                                  color: ColorPalette.Black1,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              SizedBox(height: 24),
                              StreamBuilder(
                                  stream: httpBloc.stream,
                                  builder: (context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.hasData) {
                                      LocationCategory location =
                                          snapshot.data as LocationCategory;

                                      return Expanded(
                                        child: SingleChildScrollView(
                                            child: ListView.builder(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: location.locations !=
                                                        null
                                                    ? location.locations.length
                                                    : 0,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return getListItem(location
                                                      .locations[index]);
                                                })),
                                      );
                                    } else {
                                      return Expanded(child: Container());
                                    }
                                  }),
                              StreamBuilder(
                                  stream: httpBloc.stream,
                                  builder: (context,
                                      AsyncSnapshot<dynamic> snapshot) {
                                    if (snapshot.hasData) {
                                      LocationCategory location =
                                          snapshot.data as LocationCategory;
                                      if (location.id != null) {
                                        return Align(
                                            alignment: Alignment.centerLeft,
                                            child: FloatingActionButton(
                                                backgroundColor:
                                                    ColorPalette.Yellow1,
                                                onPressed: () {
                                                  if (locator<Constants>()
                                                      .getSite_id() !=
                                                      '' && locator<Constants>().hasAccess(context,AccessEnum.addLocation, null,null))
                                                  showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      enableDrag: false,
                                                      //enable drag false only for map
                                                      builder: (context) {
                                                        return BottomSheetWidget(
                                                          title: Strings
                                                              .BottomSheetWidget_Location_title,
                                                          content:
                                                              LocationWidget(
                                                            selectedItemBloc: this
                                                                .selectedItemBloc,
                                                            forEnum:
                                                                mapForEnum.New,
                                                          ),
                                                        );
                                                      });
                                                },
                                                tooltip: 'add',
                                                child: Icon(
                                                  Icons.add,
                                                  color: ColorPalette.White1,
                                                )));
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                  }),
                              /*Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Expanded(
                                      child: FractionallySizedBox(
                                        //alignment: Alignment.centerRight,
                                        widthFactor: 1,
                                        child: locationPageWidgetCancel,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Expanded(
                                      child: FractionallySizedBox(
                                          //alignment: Alignment.centerRight,
                                          widthFactor: 1,
                                          child: locationPageWidgetSend),
                                    )
                                  ],
                                ),
                              )*/
                            ]),
                          ),
                        )
                      ]))))),
    );
  }

  Widget getListItem(Location item) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: ColorPalette.Gray3,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            /* boxShadow: [
                  BoxShadow(
                      color: ColorPalette.Gray1.withOpacity(0.25),
                      offset: Offset(0, 0),
                      blurRadius: 4)
                ],*/
            /* border: Border.all(
                  color: ColorPalette.White1,
                  width: 1,
                ),*/
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              MyText(
                text: item.title,
                textAlign: TextAlign.right,
                color: ColorPalette.Black1,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
               Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        if (locator<Constants>()
                            .getSite_id() !=
                            '' && locator<Constants>().hasAccess(context,AccessEnum.editLocation, null,null))
                          locator<Web>().post(
                            LocationRemoveEvent(
                                httpBloc, this.locationCategory, item),
                            context);
                      },
                      child: CrossPlatformSvg.asset(
                          assetPath: 'assets/vectors/Icons/WithBG.svg',
                          height: 24,
                          width: 24,
                          fit: BoxFit.fitHeight)))
            ],
          ),
        ));
  }
}
