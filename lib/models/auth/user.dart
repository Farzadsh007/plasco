import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/services/constants.dart';


import '../../color_palette.dart';
import '../../locator.dart';

import 'enums.dart';

class User {
  String id;
  String membership_id;
  String first_name;
  String last_name;
  role user_role;

  String mobile_number;
  String national_code;
  companyStatus status;

  /*status status ;
  job job_title ;*/
  String job_title_name;
  int job_title;
  String logo = '';

  bool selected = false;
  bool alreadyExistInGroup = false;
  Uint8List image;

  int department;

  String department_title;

  User();

  Future<User> fromJson(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'].toString() : '';
    membership_id= json['membership_id'] != null ? json['membership_id'].toString() : '';
    first_name = json['first_name'] != null ? json['first_name'] : '';
    last_name = json['last_name'] != null ? json['last_name'] : '';
    user_role = json['role'] != null
        ? role.values.firstWhere((i) => i.index == json['role'])
        : null;
    status = json['status'] != null
        ? companyStatus.values.firstWhere((i) => i.index == json['status'])
        : null;
    mobile_number = json['mobile_number'] != null ? json['mobile_number'] : '';
    national_code = json['national_code'] != null ? json['national_code'] : '';
    job_title_name =
        json['job_title_name'] != null ? json['job_title_name'] : '';
    job_title = json['job_title'] != null ? json['job_title'] : -1;
    department = json['department'] != null ? json['department'] : -1;
    department_title =
        json['department_title'] != null ? json['department_title'] : '';
    logo = json['logo'] != null
        ? locator<Constants>().ImageServerIP +
            await locator<Constants>().decrypt(json['logo'])
        : '';
    return this;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': first_name,
        'last_name': last_name,
        'job_title': job_title.toString(),
        'role': user_role != null ? (user_role.index).toString() : '',
        'department': department.toString(),
        'national_code': national_code,
        'mobile_number': mobile_number
        // 'site_logo': site_logo,
      };

  toggleSelected() {
    selected = !selected;
  }

  Widget getLabel() {
    Widget ret = Container();
    Color color;
    String title = '';
    switch (this.status) {
      case companyStatus.Active:
        color = ColorPalette.Green1;

        title = getRole();

        break;
      case companyStatus.Rejected:
        title = 'تایید نشده';
        color = ColorPalette.Red1;
        break;
      case companyStatus.Pending:
        title = 'در حال بررسی';
        color = ColorPalette.Yellow1;
        break;

      case companyStatus.Deactive:
        title = 'اتمام همکاری';
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

  String getRole() {
    String ret = '';
    switch (user_role) {
      case role.admin:
        ret = 'ادمین';
        break;
      case role.has_inspector:
        ret = 'بازرس';
        break;
      case role.executive:
        ret = 'مجری';
        break;
      case role.not_access:
        ret = 'عدم دسترسی';
    }

    return ret;
  }

  Widget getRequestLabel(  {Null Function() onApprove, Null Function() onReject} ) {
    Widget ret = Container();

    if (this.status == companyStatus.Pending) {
      ret = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
          color: Colors.transparent,
          child: InkWell(
          borderRadius: BorderRadius.circular( 32),
    onTap: () {
      onApprove();

    },child:

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: ColorPalette.Yellow1,
                  width: 1,
                )),
            padding: EdgeInsets.all(4.0),
            child: SvgPicture.asset('assets/vectors/Icons/check.svg',
                color: ColorPalette.Yellow1,
                height: 24,
                width: 24,
                fit: BoxFit.fitHeight),
          ))),
          SizedBox(
            width: 8,
          ),
          Material(
              color: Colors.transparent,
              child: InkWell(
              borderRadius: BorderRadius.circular( 32),
          onTap: () {
            onReject();


          },child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: ColorPalette.Gray2,
                  width: 1,
                )),
            padding: EdgeInsets.all(4.0),
            child: SvgPicture.asset('assets/vectors/Icons/close.svg',
                color: ColorPalette.Gray2,
                height: 24,
                width: 24,
                fit: BoxFit.fitHeight),
          )))
        ],
      );
    }
    return ret;
  }
}
