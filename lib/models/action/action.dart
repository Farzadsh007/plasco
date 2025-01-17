import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/company/company.dart';
import 'package:shamsi_date/extensions.dart';
import 'package:plasco/services/constants.dart';
import '../../color_palette.dart';
import 'answer.dart';
import '../../locator.dart';
class ActionItem {
  int id;
  int anomaly;
  String title;
  String description;

  //int sub_site;
  Company site;

  actionStatus status;
  Company sub_siteCompany;
  Company user_site;
  int site_location_category;
  String location_category_title;
  int site_location;
  String location_title;
  int group;
  String group_title = '';
  bool immediately=false;
  DateTime deadline;

  bool expired=false;
  DateTime created_at;
  List<String> images;
  User creator;
  Answer answers;

  List<Uint8List> files;

  ActionItem();

  Future<ActionItem> fromJson(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'] : -1;
    anomaly=json['anomaly'] != null ? json['anomaly'] : -1;
    title = json['title'] != null ? json['title'] : '';
    description = json['description'] != null ? json['description'] : '';

    site = json['site'] != null ? await Company().fromJson(json['site']) : null;
    status = json['status'] != null
        ? actionStatus.values.firstWhere((i) => i.index == json['status'])
        : null;

    location_category_title =
        json['location_category'] != null ? json['location_category'] : '';
    location_title = json['location'] != null ? json['location'] : '';
    group = json['group'] != null ? json['group'] : -1;
    group_title = json['group_title'] != null ? json['group_title'] : '';

    immediately = json['immediately'] != null ? json['immediately'] : false;
    deadline =
        json['deadline'] != null ? DateTime.parse(json['deadline']).toLocal() : null;
    expired = json['expired'] != null ? json['expired'] : false;

    created_at =
        json['created_at'] != null ? DateTime.parse(json['created_at']) .toLocal(): null;
    creator =
        json['creator'] != null ? await User().fromJson(json['creator']) : null;

    answers = json['answers'] != null
        ? await Answer().fromJson(json['answers'])
        : null;
    sub_siteCompany = json['target'] != null
        ? await Company().fromJson(json['target'])
        : null;
    user_site= json['user_site'] != null
        ? await Company().fromJson(json['user_site'])
        : null;
    return this;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'group': group,
        'anomaly': anomaly,
        'immediately': immediately,
        'deadline':
            "${deadline.year.toString()}-${deadline.month.toString().padLeft(2, '0')}-${deadline.day.toString().padLeft(2, '0')}",
      };

  String getFarsiCreateDate() {
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

  String getFarsiDeadLineDate() {
    String ret = '';
    if (deadline != null) {
      Jalali jalali = Jalali.fromDateTime(deadline);

      ret = jalali.formatter.yyyy +
          '/' +
          jalali.formatter.mm +
          '/' +
          jalali.formatter.dd;
    }
    return ret;
  }

  Widget getDoneLabel() {
    Widget ret = Container();
    Color color;
    String title = '';
    switch (this.status) {
      case actionStatus.complete:
        title = 'تایید شده';
        color = ColorPalette.Green1;
        break;
      case actionStatus.not_complete:
        title = 'انجام نشده';
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

  Widget getImmediatelyLabel() {
    Color color = ColorPalette.Red1;
    String title = 'فوری';

    return Container(
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
