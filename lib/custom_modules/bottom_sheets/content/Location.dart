import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plasco/blocs/SelectedItemBloc.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/inputs/MyDropDownFormField.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/custom_modules/inputs/MyTextFormField.dart';
import 'package:plasco/custom_modules/inputs/validator.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/location/location.dart';
import 'package:plasco/models/location/location_category.dart';
import 'package:plasco/services/constants.dart';
import 'package:plasco/services/web.dart';

import '../../../locator.dart';
import '../../../strings.dart';
import '../../MyButton.dart';

class LocationWidget extends StatefulWidget {
  LocationWidget({Key key, this.selectedItemBloc, this.forEnum})
      : super(key: key);

  final SelectedItemBloc selectedItemBloc;
  final mapForEnum forEnum;

  @override
  _LocationWidgetState createState() =>
      _LocationWidgetState(this.selectedItemBloc, this.forEnum);
}

class _LocationWidgetState extends State<LocationWidget> {
  _LocationWidgetState(this.selectedItemBloc, this.forEnum);

  mapForEnum forEnum;
  SelectedItemBloc selectedItemBloc;

  TextEditingController locationNameController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controller;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(33, 51),
    zoom: 5.0,
  );

  final _DragStreamController = StreamController<String>.broadcast();

  StreamSink<String> get sinkDrag => _DragStreamController.sink;

  Stream<String> get streamDrag => _DragStreamController.stream;
  final MarkerId markerIdDrag = MarkerId('drag');
  Marker markerDrag;
  LatLng latLngDrag;

  Map<String, String> selectedLocation = {
    'title': '',
    'categoryId': null,
    'locationId': null
  };
  MyBloc httpBloc = MyBloc();
  final GlobalKey<FormState> _formKey = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    markerDrag = Marker(
      markerId: markerIdDrag,
      icon: BitmapDescriptor.fromBytes(locator<Constants>().addIcon),
      position: LatLng(33, 51),
      infoWindow:
          InfoWindow(title: 'Move map to select a location', snippet: ''),
    );
    latLngDrag = markerDrag.position;
    if (forEnum != mapForEnum.Select) markers[markerIdDrag] = markerDrag;

    httpBloc.stream.listen((event) {
      if (event != null && event is LocationCategory) {
        String categoryTitle = event.title;
        List<Marker> _markersList = [];
        MarkerId _firstMarkerID;
        for (Location item in event.locations) {
          MarkerId _markerID = MarkerId(item.id.toString());
          if (_firstMarkerID == null) _firstMarkerID = _markerID;
          Marker _marker = Marker(
            markerId: _markerID,
            draggable: false,
            icon: BitmapDescriptor.fromBytes(locator<Constants>().selectIcon),
            onTap: () {
              sinkDrag.add(item.title);

              this.selectedLocation['title'] =
                  categoryTitle + ' - ' + item.title;
              this.selectedLocation['categoryId'] = event.id.toString();
              this.selectedLocation['locationId'] = item.id.toString();
            },
            position: LatLng(item.lat, item.lng),
            infoWindow: InfoWindow(title: item.title, snippet: ''),
          );
          _markersList.add(_marker);
          setState(() {
            markers[_markerID] = _marker;
          });
        }
        controller.moveCamera(
            CameraUpdate.newLatLngBounds(getBounds(_markersList), 50));
        Future.delayed(Duration(seconds: 1))
            .then((value) => controller.showMarkerInfoWindow(_firstMarkerID));
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _DragStreamController.close();
    httpBloc.dispose();
    super.dispose();
  }

  LatLngBounds getBounds(List<Marker> markers) {
    var lngs = markers.map<double>((m) => m.position.longitude).toList();
    var lats = markers.map<double>((m) => m.position.latitude).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    LatLngBounds bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );

    return bounds;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,child:Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (forEnum == null || forEnum == mapForEnum.Select)
          MyDropDownFormField(
            httpEvent: DropDownGetMapCategoryListEvent(),
            bottomSheetTitle: Strings.BottomSheetWidget_Location_title,
            text: Strings.BottomSheetWidget_Location_title,
            hint: Strings.BottomSheetWidget_Location_hint,
            fontWeight: FontWeight.normal,
            fontSize: 12,
            onChange: (newValue) async {
              LocationCategory category = newValue.data as LocationCategory;
              setState(() {
                markers.removeWhere((key, value) => value != null);
              });
              if (category != null &&
                  category.locations != null &&
                  category.locations.length > 0) {
                locator<Web>()
                    .post(LocationGetDetailsEvent(httpBloc, category), context);
              }
            },
          ),
        SizedBox(
          height: 8.0,
        ),
        (forEnum == mapForEnum.New)
            ? MyTextFormField(
                controller: locationNameController,
                text: Strings.BottomSheetWidget_Location_title,
                hint: Strings.BottomSheetWidget_Location_title,
                fontWeight: FontWeight.normal,
                fontSize: 12,
                counterFontSize: 10,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.name,
                maxLength: 20,validator:LocationNameValidator(5)
              )
            : StreamBuilder(
                stream: streamDrag,
                initialData: forEnum != mapForEnum.Select
                    ? 'Lat:${latLngDrag.latitude} Lng:${latLngDrag.longitude}'
                    : 'هیچ مکانی انتخاب نشده است!',
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    return MyText(
                      text: snapshot.data,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      textAlign: TextAlign.right,
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
        SizedBox(
          height: 24,
        ),
        Container(
            height: 343,
            child: GoogleMap(
              mapType: MapType.normal,
              onCameraMove: forEnum == mapForEnum.Select
                  ? null
                  : (position) {
                      latLngDrag = position.target;
                      Marker updatedMarker = markerDrag.copyWith(
                        positionParam: position.target,
                      );
                      setState(() {
                        markers[markerDrag.markerId] = updatedMarker;
                      });

                      sinkDrag.add(
                          'Lat:${latLngDrag.latitude} Lng:${latLngDrag.longitude}');
                    },
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              markers: Set<Marker>.of(markers.values),
              onMapCreated: (GoogleMapController controller) async {
                _controller.complete(controller);
                this.controller = await _controller.future;
              },
            )),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: FractionallySizedBox(
                  //alignment: Alignment.centerRight,
                  widthFactor: 1,
                  child: MyButton(
                      text: Strings.BottomSheetWidget_Location_cancel,
                      buttonFill: ButtonFillStyle.White,
                      onPressed: () {
                        Navigator.pop(context);
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
                        text: Strings.BottomSheetWidget_Location_send,
                        buttonFill: ButtonFillStyle.Yellow,
                        onPressed: () async {
                          switch (this.forEnum) {
                            case mapForEnum.New:
                              if( _formKey.currentState.validate()){
                              Location location = Location();
                              location.title = this.locationNameController.text;
                              location.lat = latLngDrag.latitude;
                              location.lng = latLngDrag.longitude;
                              selectedItemBloc.select(new DropDownItem(
                                  0, location.title, location));
                              Navigator.pop(context);
                              }
                              break;
                            case mapForEnum.Select:
                              if( _formKey.currentState.validate()){
                              selectedItemBloc.select(new DropDownItem(
                                  0,
                                  this.selectedLocation['title'],
                                  this.selectedLocation));
                              Navigator.pop(context);
                              }
                              break;
                            case mapForEnum.Drag:
                              selectedItemBloc.select(new DropDownItem(
                                  0, "انتخاب شد!", latLngDrag));
                              Navigator.pop(context);
                              break;

                          }

                        })),
              )
            ],
          ),
        )
      ],
    ));
  }
}

enum mapForEnum { New, Select, Drag }
