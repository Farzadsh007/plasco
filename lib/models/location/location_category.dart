import 'package:flutter/widgets.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/location/location.dart';

import '../../color_palette.dart';

class LocationCategory {
  int id;
  String title;
  List<Location> locations = [];
  int total = 0;

  LocationCategory();

  LocationCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? json['id'] : null;
    title = json['title'] != null ? json['title'] : '';
    locations = json['locations'] != null
        ? (json['locations']['data'] as List)
            .map((location) => Location.fromJson(location))
            .toList()
        : [];

    total = json['locations'] != null ? json['locations']['total'] : 0;
  }

  String locationsTitle() {
    String ret = '';
    if (locations != null && locations.length > 0) {
      for (Location location in locations) {
        if (location != locations[locations.length - 1]) {
          ret += location.title + '، ';
        } else {
          ret += location.title;
        }
      }
    }

    return ret;
  }

  Widget getLocationCountLabel() {
    Widget ret = Container();
    Color color = ColorPalette.Green1;
    String title = total.toString() + ' مکان ';

    if (title != '') {
      ret = Container(
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(4))),
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
        child: MyText(
          text: title,
          textAlign: TextAlign.center,
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      );
    }
    return ret;
  }
}
