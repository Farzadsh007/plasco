import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/services/constants.dart';
import 'package:shamsi_date/extensions.dart';
import '../action/action.dart';
import '../../color_palette.dart';
import '../../locator.dart';

class Anomaly {
  int id;
  String title;
  String description;

// int site;
  int target;
  Company sub_siteCompany;
  Company user_site;
  anomalyStatus status;
  riskType risk_type;
  int location_category;
  String location_category_title;
  int location;
  String location_title;
  DateTime created_at;
  List<String> images;
  User creator;
  int category;

  String category_name = '';
  List<ActionItem> actions;

  List<Uint8List> files;

  Anomaly();

  Future<Anomaly> fromJson(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'] : -1;
    title = json['title'] != null ? json['title'] : '';
    description = json['description'] != null ? json['description'] : '';
    //site = json['site'] != null ? json['site'] : -1;
    sub_siteCompany = json['target'] != null
        ? await Company().fromJson(json['target'])
        : null;
    user_site= json['user_site'] != null
        ? await Company().fromJson(json['user_site'])
        : null;
    status = json['status'] != null
        ? anomalyStatus.values.firstWhere((i) => i.index == json['status'])
        : null;

    risk_type = json['risk_type'] != null
        ? riskType.values.firstWhere((i) => i.index == json['risk_type'])
        : null;
    location_category_title =
        json['location_category'] != null ? json['location_category'] : '';
    location_title = json['location'] != null ? json['location'] : '';
    created_at =
        json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null;
    images = json['images'] != null
        ? await Future.wait((json['images'] as List)
            .map((e) async =>
                locator<Constants>().ImageServerIP +
                await locator<Constants>().decrypt(e))
            .toList())
        : null;
    creator =
        json['creator'] != null ? await User().fromJson(json['creator']) : null;
    actions = json['actions'] != null
        ? await Future.wait((json['actions'] as List)
            .map((e) async => await ActionItem().fromJson(e))
            .toList())
        : [];

    category_name = json['category'] != null ? json['category']['name'] : '';
    return this;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'user_site': locator<Constants>().getSite_id(),
        'target': target,
        'risk_type': risk_type.index,
        'location_category': location_category,
        'location': location,
        'category': category
      };

  String getFarsiDate() {
    String ret = '';
    if (created_at != null) {
      Jalali jalali = Jalali.fromDateTime(created_at);

      ret = jalali.formatter.yyyy +
          '/' +
          jalali.formatter.mm +
          '/' +
          jalali.formatter.dd +
          '  -  ' +
          created_at.hour.toString().padLeft(2, '0') +
          ':' +
          created_at.minute.toString().padLeft(2, '0');
    }
    return ret;
  }

  Widget getLabel() {
    Widget ret = Container();
    Color color;
    String title = '';
    switch (this.status) {
      case anomalyStatus.open:
        title = ' باز ';
        color = ColorPalette.Red1;

        break;
      case anomalyStatus.closed:
        title = 'بسته';
        color = ColorPalette.Green1;
        break;
      case anomalyStatus.pending:
        title = 'در حال بررسی';
        color = ColorPalette.Yellow1;
        break;
    }

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

  Widget getRiskLabel() {
    Widget ret = Container();
    Color color;
    String title = '';
    switch (this.risk_type) {
      case riskType.Low:
        title = 'پایین';
        color = ColorPalette.Green1;
        break;
      case riskType.Moderate:
        title = 'متوسط';
        color = ColorPalette.Yellow1;
        break;
      case riskType.None:
        break;
      case riskType.High:
        title = 'بالا';
        color = ColorPalette.Red1;
        break;
    }

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

  Widget getSubSiteLabel() {
    Widget ret = Container();
Company _site;

    if (user_site!=null && locator<Constants>().getSite_id()!='' && locator<Constants>().getSite_id()==user_site.id.toString() ){
      _site=sub_siteCompany;
    }

    if (sub_siteCompany!=null && locator<Constants>().getSite_id()!='' && locator<Constants>().getSite_id()==sub_siteCompany.id.toString() ){
      _site=user_site;
    }


    if (_site!=null && locator<Constants>().getSite_id()!='' && locator<Constants>().getSite_id()!=_site.id.toString() ) {
      ret =  Container(
        alignment: Alignment.centerRight,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: _site.site_logo != ''
            ? ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LoadImage.load(
                url: _site.site_logo,
                height: 24,
                width: 24,
                fit: BoxFit.fitHeight))
            : ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Center(
                child: SvgPicture.asset(
                    'assets/vectors/Icons/image.svg',
                    width: 24,
                    height: 24))),
      );
    }
    return ret;
  }
}
