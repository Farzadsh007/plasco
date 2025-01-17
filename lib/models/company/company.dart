import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plasco/custom_modules/SnackbarWidget.dart';
import 'package:plasco/custom_modules/inputs/MyText.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/constants.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class Company {
  int id;
  String organization_name;
  String site_name;
  String project_name;

  String phone;
  String lat;
  String lng;
  companyStatus membership_status;
  stakeHolderStatus stake_holder_status;
  int site_type;
  String site_type_title;

  int site_scope;
  String site_scope_title;
  int department;
  String department_title;
  DateTime created_at;
  bool is_central_office = false;
  int job_title;
  String job_title_name;
  role user_role;
  String site_logo = '';
  List<User> personals;

  String stake_holder_type;
  int stake_holder_type_id;
  Uint8List image;
int source_site_id;
  Company();

  Future<Company> fromJson(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'] : -1;
    organization_name =
        json['organization_name'] != null ? json['organization_name'] : '';
    site_name = json['site_name'] != null ? json['site_name'] : '';
    project_name = json['project_name'] != null ? json['project_name'] : '';

    phone = json['phone'] != null ? json['phone'] : '';
    lat = json['lat'] != null ? json['lat'] : '';
    lng = json['lng'] != null ? json['lng'] : '';
    membership_status = json['membership_status'] != null
        ? companyStatus.values
            .firstWhere((i) => i.index == json['membership_status'])
        : null;
    stake_holder_status=json['stake_holder_status'] != null
        ? stakeHolderStatus.values
        .firstWhere((i) => i.index == json['stake_holder_status'])
        : null;
    site_type = json['site_type'] != null ? json['site_type'] : -1;
    site_type_title =
        json['site_type_title'] != null ? json['site_type_title'] : '';

    site_scope = json['site_scope'] != null ? json['site_scope'] : -1;
    site_scope_title =
        json['site_scope_title'] != null ? json['site_scope_title'] : '';

    department = json['department'] != null ? json['department'] : -1;
    department_title =
        json['department_title'] != null ? json['department_title'] : '';
    created_at =
        json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null;
    is_central_office =
        json['is_central_office'] != null ? json['is_central_office'] : false;
    job_title = json['job_title'] != null ? json['job_title'] : -1;
    job_title_name =
        json['job_title_name'] != null ? json['job_title_name'] : '';
    user_role = json['user_role'] != null
        ? role.values.firstWhere((i) => i.index == json['user_role'])
        : null;
    site_logo = json['site_logo'] != null
        ? locator<Constants>().ImageServerIP +
            await locator<Constants>().decrypt(json['site_logo'])
        : '';
    personals = json['personals'] != null
        ? await Future.wait((json['personals'] as List)
            .map((e) async => User().fromJson(e))
            .toList())
        : [];

    stake_holder_type = json['stake_holder_type'] != null
        ? json['stake_holder_type']['type']
        : '';
    stake_holder_type_id = json['stake_holder_type'] != null
        ? json['stake_holder_type']['id']
        : -1;

    source_site_id= json['source_site_id'] != null ? json['source_site_id'] : -2;
    return this;
    var ff = '';
  }

  Map<String, dynamic> toJson() => {
        'organization_name': organization_name,
        'site_name': organization_name, //todo
        'project_name': project_name,

        'phone': phone,
        'lat': lat,
        'lng': lng,

        'site_scope': site_scope.toString(),

        'is_central_office': is_central_office.toString(),
        'job_title': job_title.toString(),
        'user_role': user_role != null ? (user_role.index).toString() : null,
        'department': department.toString(),
        // 'site_logo': site_logo,
      };

  Map<String, String> toJsonForRequest() => {
        'site_id': id.toString(),
        'job_title': job_title.toString(),
        'department': department.toString(),
        'role': user_role.index.toString(),
      };

  Map<String, String> toJsonForApproveRequest(User user) => {
    'id': user.membership_id.toString(),
    'job_title': job_title.toString(),
    'department': department.toString(),
    'role': user_role.index.toString(),
    'status':'2'
  };



  Widget getLabel() {
    Widget ret = Container();
    Color color;
    String title = '';
    switch (this.membership_status) {
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

  Widget getStakeHolderLabel() {
    Widget ret = Container();
    Color color = ColorPalette.Yellow1;
    String title = '';
    switch (this.stake_holder_status) {
      case stakeHolderStatus.Active:
        color = ColorPalette.Green1;
        title = stake_holder_type;
        break;
      case stakeHolderStatus.Rejected:
        title = 'تایید نشده';
        color = ColorPalette.Red1;
        break;
      case stakeHolderStatus.Pending:
        if (locator<Constants>().getSite_id()!=source_site_id.toString() ) {
          title = '';
        }else{
          title = 'در حال بررسی';
        }


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

  bool canSendSiteRegistration(BuildContext context) {
    bool ret=true;
    String msg='';
    if(membership_status!=null){
      switch(membership_status){

        case companyStatus.Pending:
          msg='درخواست شما در حال بررسی است!';
          ret=false;
          break;
        case companyStatus.Rejected:

          ret=true;
          break;
        case companyStatus.Active:
          msg='شما عضو این کارگاه هستید.';
          ret=false;
          break;
        case companyStatus.Deactive:
          ret=true;
          break;
      }
    }
if(!ret){
  SnackBarWidget.buildErrorSnackBar(context, msg);
}

    return ret;
  }


  bool canSendStackHolderRegistration(BuildContext context) {
    bool ret=true;
    String msg='';
    if(stake_holder_status!=null){
      switch(stake_holder_status){

        case stakeHolderStatus.Pending:
          msg='درخواست شما در حال بررسی است!';
          ret=false;
          break;
        case stakeHolderStatus.Rejected:

          ret=true;
          break;
        case stakeHolderStatus.Active:
          msg='شما زیرمجموعه این کارگاه هستید.';
          ret=false;
          break;

      }
    }
    if(!ret){
      SnackBarWidget.buildErrorSnackBar(context, msg);
    }

    return ret;
  }


  Widget getRequestLabel(  {Null Function() onApprove, Null Function() onReject} ) {
    Widget ret = Container();

    if (this.stake_holder_status == stakeHolderStatus.Pending && locator<Constants>().getSite_id()!=source_site_id.toString() ) {
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
