
import 'dart:typed_data';

import 'package:plasco/custom_modules/bottom_sheets/content/Location.dart';
import 'package:plasco/models/DropDownItem.dart';
import 'package:plasco/models/HttpResponse.dart';
import 'package:plasco/models/action/action.dart';
import 'package:plasco/models/action/answer.dart';
import 'package:plasco/models/anomaly/anomaly.dart';
import 'package:plasco/models/auth/enums.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/company/company.dart';
import 'package:plasco/models/group/group.dart';
import 'package:plasco/models/group/group_detail.dart';
import 'package:plasco/models/location/location.dart';
import 'package:plasco/models/location/location_category.dart';
import 'package:plasco/models/update/update.dart';
import 'package:plasco/services/constants.dart';

import '../../locator.dart';
import '../../strings.dart';
import 'HttpBloc.dart';

abstract class HttpEvent {
  // HttpEvent(HttpBloc httpBloc);
  String url();

  HttpEnum mode();

  Map<String, dynamic> toJson();

  bool hasHeader() {
    return false;
  }

  void setResponse(PlascoHttpResponse response);

  List<Uint8List> files();
}

enum HttpEnum { Get, Post, Put, Delete }

//******************************************************************************
class GetServerTimeEvent extends HttpEvent {
  HttpBloc bloc;

  GetServerTimeEvent(this.bloc);

  @override
  String url() {
    return '/server_time';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    DateTime now;
    if (response.statusCode == 200) {
      now = DateTime.parse(response.body['current']).toLocal();
    }
    bloc.add(now);
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
//******************************************************************************
class CheckUpdateEvent extends HttpEvent {
  HttpBloc bloc;

  CheckUpdateEvent(this.bloc);

  @override
  String url() {
    return '/app-version';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'app_version':Strings.appVersionCode, //locator<Constants>().packageInfo.version,
      'platform': 'Android'
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    Update update;
    if (response.statusCode == 200) {
      update = Update.fromJson(response.body);
    }
    bloc.add(update);
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
//******************************************************************************
class FireBaseEvent extends HttpEvent {
  HttpBloc bloc;

  FireBaseEvent(this.bloc);

  @override
  String url() {
    return '/fcm/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {




      var build =   locator<Constants>().build;


    return {
      "registration_id":locator<Constants>().fireBaseToken,
      "mobile_serial_number":  build.androidId,
      "os_name": 'Android',
      "os_version":build.version.sdkInt.toString(),
      "app_version":Strings.appVersionCode,
      "build_number":build.androidId,
      "brand":build.brand
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {

    if (response.statusCode == 201) {
      bloc.add(true);
    }
  }
  @override
  List<Uint8List> files() {
    return null;
  }
}

//******************************************************************************
class AuthEnterNoEvent extends HttpEvent {
  String phone_number;
  HttpBloc bloc;

  AuthEnterNoEvent(this.bloc, this.phone_number) {
    locator<Constants>().setMyPhone(this.phone_number);
  } //;// : super(httpBloc);

  @override
  String url() {
    return '/account/api/v1/user_otp';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phone_number,
    };
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (bloc != null) bloc.add(response.statusCode == 200);
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthVerifyNoEvent extends HttpEvent {
  String phone_number;
  String otp;
  HttpBloc bloc;

  AuthVerifyNoEvent(this.bloc, this.phone_number, this.otp);

  @override
  String url() {
    return '/account/api/v1/user_otp/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'phone_number': phone_number,
      'otp': otp,
    };
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {
      locator<Constants>().setAccessToken(response.body['token']['access']);
      locator<Constants>().setRefreshToken(response.body['token']['refresh']);
      locator<Constants>().setIsLoggedIn(true);
      bloc.add(true);
    }
    if (response.statusCode == 404) {
      bloc.add(false);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthAccountInfoEvent extends HttpEvent {
  String first_name;
  String last_name;
  String otp;
  String national_code;
  HttpBloc bloc;

  AuthAccountInfoEvent(this.bloc, this.first_name, this.last_name, this.otp,
      this.national_code);

  @override
  String url() {
    return '/account/api/v1/register/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'first_name': first_name,
      'last_name': last_name,
      'mobile_number': locator<Constants>().MyPhone,
      'otp_code': otp,
      'national_code': national_code
    };
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {
      locator<Constants>().setAccessToken(response.body['access']);
      locator<Constants>().setRefreshToken(response.body['refresh']);
      locator<Constants>().setName(first_name);
      locator<Constants>().setFamily(last_name);
      locator<Constants>().setIsLoggedIn(true);
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthLogOutEvent extends HttpEvent {
  HttpBloc bloc;

  AuthLogOutEvent(this.bloc);

  @override
  String url() {
    return '/account/api/v1/user_logout/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'refresh': locator<Constants>().getRefreshToken()};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 205) {
      locator<Constants>().setAccessToken('');
      locator<Constants>().setRefreshToken('');
      locator<Constants>().setName('');
      locator<Constants>().setFamily('');
      locator<Constants>().setIsLoggedIn(false);
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthGetProfileEvent extends HttpEvent {
  User user;
  HttpBloc bloc;

  AuthGetProfileEvent(this.bloc, this.user);

  @override
  String url() {
    return '/account/api/v1/user_membership_profile';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return user == null ? null : {'id': user.id};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      User user = await User().fromJson(response.body['data']);
      bloc.add(user);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthUpdateProfileShipEvent extends HttpEvent {
  User user;

  HttpBloc bloc;

  AuthUpdateProfileShipEvent(this.bloc, this.user);

  @override
  String url() {
    return '/account/api/v1/user_membership_profile/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return user != null
        ? user.toJson()
        : null; // {'first_name': user.first_name, 'last_name': user.last_name};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 202) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this.user != null && this.user.image != null) {
      List<Uint8List> ret = [];
      ret.add(this.user.image);
      return ret;
    } else {
      return null;
    }
  }
}

class AuthGetMemberShipEvent extends HttpEvent {
  HttpBloc bloc;

  AuthGetMemberShipEvent(this.bloc);

  @override
  String url() {
    return '/site/api/v1/membership/user/active-site/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {
      DropDownItem site = DropDownItem(
          response.body['site_id'], response.body['organization_name'], null);
      locator<Constants>().setSite_id(site.id.toString());
      locator<Constants>().setSite_name(site.value.toString());
      locator<Constants>().setUserID(response.body['user_id'].toString());
      locator<Constants>().setRole(response.body['role']);
      bloc.add(site);
    } else {
      DropDownItem site =
      DropDownItem(-1, Strings.MainPageWidget_choose_company, null);
      locator<Constants>().setSite_id('');
      locator<Constants>().setSite_name('');
      bloc.add(site);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthUpdateMemberShipEvent extends HttpEvent {
  DropDownItem site;
  HttpBloc bloc;

  AuthUpdateMemberShipEvent(this.bloc, this.site);

  @override
  String url() {
    return '/site/api/v1/membership/user/active-site/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'site_id': site.id.toString()};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 202) {
      locator<Constants>().setUserID(response.body['user_id'].toString());
      locator<Constants>().setRole(response.body['role']);
      bloc.add(this.site);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AuthCreateUpdateProfileShipEvent extends HttpEvent {
  User user;

  HttpBloc bloc;

  AuthCreateUpdateProfileShipEvent(this.bloc, this.user);

  @override
  String url() {
    return '/site/api/v1/membership/user/create-update/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return user != null
        ? user.toJson()
        : null; // {'first_name': user.first_name, 'last_name': user.last_name};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this.user != null && this.user.image != null) {
      List<Uint8List> ret = [];
      ret.add(this.user.image);
      return ret;
    } else {
      return null;
    }
  }
}

//******************************************************************************
class CompanyGetListEvent extends HttpEvent {
   HttpBloc bloc;
  String q;
  CompanyGetListEvent(this.bloc, this.q);

  @override
  String url() {
    return '/site/api/v1/lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return q.isNotEmpty
        ? {
      'q': q,
    }
        : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    List<Company> companies;
    if (response.statusCode == 200) {
      List<Company> companies = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Company().fromJson(i))
              .toList());

      bloc.add(companies);
    } else {
      companies = [];
      bloc.add(companies);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class CompanyGetMyListEvent extends HttpEvent {
  HttpBloc bloc;

  CompanyGetMyListEvent(this.bloc);

  @override
  String url() {
    return '/site/api/v1/owner-lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<Company> companies = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Company().fromJson(i))
              .toList());

      bloc.add(companies);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class CompanyGetDetailsEvent extends HttpEvent {
  int site_id;
  HttpBloc bloc;

  CompanyGetDetailsEvent(this.bloc, this.site_id);

  @override
  String url() {
    return '/site/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': site_id.toString(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      Company company = await Company().fromJson(response.body);

      bloc.add(company);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class CompanyAddNewEvent extends HttpEvent {
  Company _company;
  HttpBloc bloc;

  CompanyAddNewEvent(this.bloc, this._company);

  @override
  String url() {
    return '/site/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return _company.toJson();
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this._company != null && this._company.image != null) {
      List<Uint8List> ret = [];
      ret.add(this._company.image);
      return ret;
    } else {
      return null;
    }
  }
}

class CompanyUpdateEvent extends HttpEvent {
  Company _company;
  HttpBloc bloc;

  CompanyUpdateEvent(this.bloc, this._company);

  @override
  String url() {
    return '/site/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return _company.toJson();
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this._company != null && this._company.image != null) {
      List<Uint8List> ret = [];
      ret.add(this._company.image);
      return ret;
    } else {
      return null;
    }
  }
}

class CompanyRequestMemberShipEvent extends HttpEvent {
  Company company;
  HttpBloc bloc;

  CompanyRequestMemberShipEvent(this.bloc, this.company);

  @override
  String url() {
    return '/site/api/v1/membership/user/request/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return company.toJsonForRequest();
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

//******************************************************************************
class DropDownProvinceGetContentEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownProvinceGetContentEvent();

  @override
  String url() {
    return '/account/api/v1/cities/list';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['name'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownCityGetContentEvent extends HttpEvent {
  int _province = -1;
  HttpBloc bloc = new MyBloc();

  DropDownCityGetContentEvent();

  int get province => _province;

  set province(int value) {
    _province = value;
  }

  @override
  String url() {
    return '/account/api/v1/cities/list';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = ((response.body['data'] as List)
          .where((element) => element['id'] == this._province)
      as Map<String, dynamic>)['provinces']
          .map((i) => DropDownItem(0, i.toString(), null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownCityMapEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();
  mapForEnum forEnum = mapForEnum.Drag;

  DropDownCityMapEvent();

  DropDownCityMapEvent.withEnum(this.forEnum);

  setForEnum(mapForEnum forEnum) {
    this.forEnum = forEnum;
  }

  getForEnum() {
    return this.forEnum;
  }

  @override
  String url() {
    return '';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      /*  List<DropDownItem> list=  ((response.body['data'] as List).where((element) => element['id']==this._province) as Map<String,dynamic>)['provinces'].map((i)  =>  DropDownItem(0, i)).toList();

      bloc.add(list);*/
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetCompanyTypeEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetCompanyTypeEvent();

  @override
  String url() {
    return '/site/api/v1/site_type/list';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['site_type'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetWorkingFieldEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetWorkingFieldEvent();

  @override
  String url() {
    return '/site/api/v1/site-scope/list';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['title'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetUnitEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetUnitEvent();

  @override
  String url() {
    return '/site/api/v1/department/list/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['title'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetJobTitleEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetJobTitleEvent();

  @override
  String url() {
    return '/site/api/v1/job_title/lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['title'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetPermissionEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetPermissionEvent();

  @override
  String url() {
    return ' ';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    List<DropDownItem> list = [];
    for (var value in role.values) {
      switch (value) {
        case role.admin:
          list.add(DropDownItem(value.index, 'ادمین', null));
          break;
        case role.has_inspector:
          list.add(DropDownItem(value.index, 'بازرس', null));
          break;
        case role.executive:
          list.add(DropDownItem(value.index, 'مجری', null));
          break;
        case role.not_access:
          list.add(DropDownItem(value.index, 'عدم دسترسی', null));
          break;
      }
    }

    bloc.add(list);
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetAnomalyCategoryEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetAnomalyCategoryEvent();

  @override
  String url() {
    return '/anomaly/api/v1/anomalies/category/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['name'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownCommunicationTypeEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownCommunicationTypeEvent();

  @override
  String url() {
    return '/site/api/v1/stake-holder/stake-holder-type/lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<DropDownItem> list = (response.body['data'] as List)
          .map((i) => DropDownItem(i['id'], i['type'], null))
          .toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetRelatedCompanyEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetRelatedCompanyEvent();

  @override
  String url() {
    return '/site/api/v1/stake-holder/stake_holder_down_site/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<Company> companies = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Company().fromJson(i))
              .toList());

      bloc.add(companies);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetMapCategoryListEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();

  DropDownGetMapCategoryListEvent();

  @override
  String url() {
    return '/site/api/v1/location/category/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<LocationCategory> locations = (response.body['data'] as List)
          .map((i) => LocationCategory.fromJson(i))
          .toList();

      List<DropDownItem> list =
      (locations).map((i) => DropDownItem(i.id, i.title, i)).toList();

      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class DropDownGetRelatedGroupEvent extends HttpEvent {
  HttpBloc bloc = new MyBloc();
  int site_id;

  DropDownGetRelatedGroupEvent(this.site_id);

  @override
  String url() {
    return '/site/api/v1/group/lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': site_id.toString(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    List<DropDownItem> list = [];
    if (response.statusCode == 200) {
      List<Group> groups = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Group().fromJson(i))
              .toList());
      List<DropDownItem> list =
      groups.map((i) => DropDownItem(i.id, i.name, null)).toList();

      bloc.add(list);
    } else {
      bloc.add(list);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

//******************************************************************************
class PersonGetListEvent extends HttpEvent {
  HttpBloc bloc;
String q;
  PersonGetListEvent(this.bloc,this.q);

  @override
  String url() {
    return '/site/api/v1/membership/user/active-site/list/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return q.isNotEmpty
        ? {
      'q': q,
    }
        : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<User> users = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => User().fromJson(i))
              .toList());

      bloc.add(users);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class PersonExistEvent extends HttpEvent {
  String national_code;
  HttpBloc bloc;

  PersonExistEvent(this.bloc, this.national_code);

  @override
  String url() {
    return '/account/api/v1/user_existence/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'national_code': national_code,
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      User user = await User().fromJson(response.body['data']);

      bloc.add(user);
    } else if (response.statusCode == 404) {
      bloc.add(null);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class PersonAddNewEvent extends HttpEvent {
  User user;

  HttpBloc bloc;

  PersonAddNewEvent(this.bloc, this.user);

  @override
  String url() {
    return '/site/api/v1/membership/add/new_user/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return user != null ? user.toJson() : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this.user != null && this.user.image != null) {
      List<Uint8List> ret = [];
      ret.add(this.user.image);
      return ret;
    } else {
      return null;
    }
  }
}

class PersonAddNewMembershipEvent extends HttpEvent {
  User user;

  HttpBloc bloc;

  PersonAddNewMembershipEvent(this.bloc, this.user);

  @override
  String url() {
    return '/site/api/v1/membership/add/exist/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return user != null ? user.toJson() : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this.user != null && this.user.image != null) {
      List<Uint8List> ret = [];
      ret.add(this.user.image);
      return ret;
    } else {
      return null;
    }
  }
}

class PersonApproveRequestEvent extends HttpEvent {
  Company _company;
  User _user;
  HttpBloc bloc;

  PersonApproveRequestEvent(this.bloc, this._company,this._user);

  @override
  String url() {
    return '/site/api/v1/membership/user/request/acceptation/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return _company.toJsonForApproveRequest(_user);
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {

      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
class  PersonRemoveRequestEvent extends HttpEvent {
  User _user;
  HttpBloc bloc;

  PersonRemoveRequestEvent(this.bloc, this._user);

  @override
  String url() {
    return '/site/api/v1/membership/user/request/acceptation/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return { 'id': _user.id.toString(),

      'status':'1'};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {

      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
//******************************************************************************
class GroupGetListEvent extends HttpEvent {
  HttpBloc bloc;
  String q;
  GroupGetListEvent(this.bloc,this.q);

  @override
  String url() {
    return '/site/api/v1/group/lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }



  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(), if(q.isNotEmpty)'q': q,
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<Group> groups = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Group().fromJson(i))
              .toList());

      bloc.add(groups);
    } else {
      List<Group> groups = [];
      bloc.add(groups);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupGetParticipantsListEvent extends HttpEvent {
  int group_id;
  HttpBloc bloc;

  GroupGetParticipantsListEvent(this.bloc, this.group_id);

  @override
  String url() {
    return '/site/api/v1/group/detail';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'group_id': this.group_id.toString(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      GroupDetail detail =
      await (GroupDetail().fromJson(response.body['data']));

      bloc.add(detail);
    } else {
      GroupDetail detail;
      bloc.add(detail);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupAddMemberEvent extends HttpEvent {
  GroupDetail group;
  List<User> users;
  HttpBloc bloc;

  GroupAddMemberEvent(this.bloc, this.group, this.users);

  @override
  String url() {
    return '/site/api/v1/group/member/add/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'group_id': group.id.toString(),
      'site': locator<Constants>().getSite_id(),
      'members': users.map((e) => e.id).toList()
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupRemoveMemberEvent extends HttpEvent {
  GroupDetail group;
  User removeUser;
  HttpBloc bloc;

  GroupRemoveMemberEvent(this.bloc, this.group, this.removeUser);

  @override
  String url() {
    return '/site/api/v1/group/member/remove/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Delete;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'group_id': group.id.toString(),
      'site': locator<Constants>().getSite_id(),
      'members': [removeUser.id].toList()
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 202) {
      this.group.members.removeWhere((element) => element.id == removeUser.id);
      bloc.add(this.group);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupAddEvent extends HttpEvent {
  GroupDetail group;
  HttpBloc bloc;

  GroupAddEvent(this.bloc, this.group);

  @override
  String url() {
    return '/site/api/v1/group/add/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': group.name,
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      group.id = response.body['id'];
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupGetMembersForEditEvent extends HttpEvent {
  List<User> currentUsers;
  HttpBloc bloc;

  GroupGetMembersForEditEvent(this.bloc, this.currentUsers);

  @override
  String url() {
    return '/site/api/v1/membership/user/active-site/list/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<User> users = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => User().fromJson(i))
              .toList());

      users.map((element) {
        bool exist =
            currentUsers.indexWhere((current) => current.id == element.id) !=
                -1;
        element.selected = exist;
        element.alreadyExistInGroup = exist;

        return element;
      }).toList();
      bloc.add(users);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupGetMembersForAddEvent extends HttpEvent {
  HttpBloc bloc;

  GroupGetMembersForAddEvent(this.bloc);

  @override
  String url() {
    return '/site/api/v1/membership/user/active-site/list/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<User> users = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => User().fromJson(i))
              .toList());

      bloc.add(users);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class GroupSelectMembersForAddEvent extends HttpEvent {
  List<User> users;
  HttpBloc bloc;

  GroupSelectMembersForAddEvent(this.bloc, this.users);

  @override
  String url() {
    return '';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    bloc.add(users);
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
//******************************************************************************

class LocationGetListEvent extends HttpEvent {
  HttpBloc bloc;
String q;
  LocationGetListEvent(this.bloc,this.q);

  @override
  String url() {
    return '/site/api/v1/location/category/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return q.isNotEmpty
        ? {
      'q': q,
    }
        : null;
  }
 /* @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(),
    };
  }*/

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    List<LocationCategory> locations;
    if (response.statusCode == 200) {
      locations = (response.body['data'] as List)
          .map((i) => LocationCategory.fromJson(i))
          .toList();
      bloc.add(locations);
    } else {
      locations = [];
      bloc.add(locations);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationGetDetailsEvent extends HttpEvent {
  HttpBloc bloc;
  LocationCategory locationCategory;

  LocationGetDetailsEvent(this.bloc, this.locationCategory);

  @override
  String url() {
    return '/site/api/v1/location/category/detail/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': locationCategory.id.toString(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      LocationCategory locations = LocationCategory.fromJson(response.body);

      bloc.add(locations);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationPrepareForAddEvent extends HttpEvent {
  LocationCategory locationCategory;

  HttpBloc bloc;

  LocationPrepareForAddEvent(this.bloc, this.locationCategory);

  @override
  String url() {
    return ' ';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    bloc.add(locationCategory);
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationCategoryAddEvent extends HttpEvent {
  LocationCategory locationCategory;
  HttpBloc bloc;

  LocationCategoryAddEvent(this.bloc, this.locationCategory);

  @override
  String url() {
    return '/site/api/v1/location/category/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site': locator<Constants>().getSite_id(),
      'title': this.locationCategory.title,
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      this.locationCategory.id = response.body['id'];

      bloc.add(locationCategory);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationCategoryRenameEvent extends HttpEvent {
  //todo

  String title;
  HttpBloc bloc;

  LocationCategoryRenameEvent(this.bloc, this.title);

  @override
  String url() {
    return '/site/api/v1/location/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site': locator<Constants>().getSite_id(),
      'title': this.title,
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      int categoryId = response.body['id'];

      bloc.add(categoryId);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationCategoryRemoveEvent extends HttpEvent {
  List<LocationCategory> currentList;
  LocationCategory removeLocation;
  HttpBloc bloc;

  LocationCategoryRemoveEvent(this.bloc, this.currentList, this.removeLocation);

  @override
  String url() {
    return '/account/api/v1/site/location/category/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Delete;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'site_location_category_id': removeLocation.id};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 202) {
      currentList.removeWhere((element) => element.id == removeLocation.id);

      bloc.add(currentList); //hazf shod
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationAddEvent extends HttpEvent {
  LocationCategory locationCategory;
  Location location;
  HttpBloc bloc;

  LocationAddEvent(this.bloc, this.locationCategory, this.location);

  @override
  String url() {
    return '/site/api/v1/location/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'location_category_id': locationCategory.id,
      'title': location.title,
      'lat': location.lat,
      'lng': location.lng,
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      location.id = response.body['id'];
      locationCategory.locations.add(location);
      bloc.add(locationCategory);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class LocationRemoveEvent extends HttpEvent {
  LocationCategory locationCategory;
  Location location;
  HttpBloc bloc;

  LocationRemoveEvent(this.bloc, this.locationCategory, this.location);

  @override
  String url() {
    return '/site/api/v1/location/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Delete;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'site_location_id': location.id};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 202) {
      locationCategory.locations
          .removeWhere((element) => element.id == location.id);

      bloc.add(locationCategory); //hazf shod
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

//******************************************************************************
class RelatedCompanyGetListEvent extends HttpEvent {
  HttpBloc bloc;
String q;
  RelatedCompanyGetListEvent(this.bloc,this.q);

  @override
  String url() {
    return '/site/api/v1/stake-holder/lists/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return q.isNotEmpty
        ? {
      'q': q,
    }
        : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<Company> companies = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Company().fromJson(i))
              .toList());

      bloc.add(companies);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class RelatedCompanyGetHolderListEvent extends HttpEvent {
  HttpBloc bloc;
String q;
  RelatedCompanyGetHolderListEvent(this.bloc,this.q);

  @override
  String url() {
    return '/site/api/v1/stake-holder/site/list/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return q.isNotEmpty
        ? {
      'q': q,
    }
        : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<Company> companies = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Company().fromJson(i))
              .toList());

      bloc.add(companies);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class RelatedCompanyAddEvent extends HttpEvent {
  HttpBloc bloc;
  Company company;
  int connectionType;

  RelatedCompanyAddEvent(this.bloc, this.company, this.connectionType);

  @override
  String url() {
    return '/site/api/v1/stake-holder/request/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'destination_site': company.id,
      'stake_holder_type': connectionType
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class RelatedCompanyApproveRequestEvent extends HttpEvent {
  Company _company;
  HttpBloc bloc;

  RelatedCompanyApproveRequestEvent(this.bloc, this._company);

  @override
  String url() {
    return '/site/api/v1/stake-holder/request/acceptation/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id':_company.id.toString(),'status':'1'};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {

      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class RelatedCompanyRemoveRequestEvent extends HttpEvent {
  Company _company;
  HttpBloc bloc;

  RelatedCompanyRemoveRequestEvent(this.bloc, this._company);

  @override
  String url() {
    return '/site/api/v1/stake-holder/request/acceptation/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'id':_company.id.toString(),'status':'2'};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) {
    if (response.statusCode == 200) {

      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
//******************************************************************************
class AnomalyGetListEvent extends HttpEvent {
  HttpBloc bloc;
String q;
  AnomalyGetListEvent(this.bloc,this.q);

  @override
  String url() {
    return '/anomaly/api/v1/anomalies/list';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(),
     if(q.isNotEmpty) 'q': q

    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    List<Anomaly> anomalies;
    if (response.statusCode == 200) {
      anomalies = await Future.wait(
          (response.body['data'] == null ? [] : response.body['data'] as List)
              .map((i) => Anomaly().fromJson(i))
              .toList());

      bloc.add(anomalies);
    } else {
      anomalies = [];
      bloc.add(anomalies);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AnomalyAddEvent extends HttpEvent {
  HttpBloc bloc;
  Anomaly anomaly;

  AnomalyAddEvent(this.bloc, this.anomaly);

  @override
  String url() {
    return '/anomaly/api/v1/anomalies/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return anomaly.toJson();
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      bloc.add(response.body['id']);
    }
  }

  @override
  List<Uint8List> files() {
    if (this.anomaly != null && this.anomaly.files != null) {
      return this.anomaly.files;
    } else {
      return null;
    }
  }
}

class AnomalyAddActionEvent extends HttpEvent {
  HttpBloc bloc;
  ActionItem action;

  AnomalyAddActionEvent(this.bloc, this.action);

  @override
  String url() {
    return '/todo/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return action.toJson();
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AnomalyGetDetailsEvent extends HttpEvent {
  int anomaly_id;
  HttpBloc bloc;

  AnomalyGetDetailsEvent(this.bloc, this.anomaly_id);

  @override
  String url() {
    return '/anomaly/api/v1/anomalies/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'anomaly_id': anomaly_id.toString(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      Anomaly anomaly = await Anomaly().fromJson(response.body);

      bloc.add(anomaly);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AnomalyRemoveEvent extends HttpEvent {
  int anomaly_id;
  HttpBloc bloc;

  AnomalyRemoveEvent(this.bloc, this.anomaly_id);

  @override
  String url() {
    return '/anomaly/api/v1/anomalies/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Delete;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'anomaly_id': anomaly_id.toString()};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 202) {
      bloc.add(true); //hazf shod
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class AnomalyCloseEvent extends HttpEvent {
  int anomaly_id;
  HttpBloc bloc;

  AnomalyCloseEvent(this.bloc, this.anomaly_id);

  @override
  String url() {
    return '/anomaly/api/v1/anomalies/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'anomaly_id': anomaly_id.toString()};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 202) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

//******************************************************************************
class ActionGetListEvent extends HttpEvent {
  HttpBloc bloc;
  DateTime date;

  ActionGetListEvent(this.bloc, this.date );

  @override
  String url() {
    return '/todo/api/v1/list/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'site_id': locator<Constants>().getSite_id(),
      'date': date != null
          ? "${date.year.toString()}-${date.month.toString().padLeft(
          2, '0')}-${date.day.toString().padLeft(2, '0')}"
          : null
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<ActionItem> actions = await Future.wait(
          (response.body['data'] as List)
              .map((e) async => await ActionItem().fromJson(e))
              .toList());
      bloc.add(actions);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class ActionGetDetailsEvent extends HttpEvent {
  HttpBloc bloc;
  int action_id;

  ActionGetDetailsEvent(this.bloc, this.action_id);

  @override
  String url() {
    return '/todo/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'action_id': action_id.toString(),
    };
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      ActionItem action = await ActionItem().fromJson(response.body);

      bloc.add(action);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class ActionAddAnswerEvent extends HttpEvent {
  HttpBloc bloc;
  Answer answer;

  ActionAddAnswerEvent(this.bloc, this.answer);

  @override
  String url() {
    return '/todo/api/v1/answer/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Post;
  }

  @override
  Map<String, dynamic> toJson() {
    return answer.toJson();
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 201) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    if (this.answer != null && this.answer.files != null) {
      return this.answer.files;
    } else {
      return null;
    }
  }
}

class ActionGetAnswersEvent extends HttpEvent {
  HttpBloc bloc;
  ActionItem action;
String q;
  ActionGetAnswersEvent(this.bloc, this.action,this.q);

  @override
  String url() {
    return 'todo/api/v1/answer/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return action != null ? {'action_id': action.id.toString(),if(q.isNotEmpty) 'q':q} : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      List<Answer> answers = await Future.wait((response.body['data'] as List)
          .map((e) async => await Answer().fromJsonForAllAnswers(e))
          .toList());
      bloc.add(answers);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
class ActionGetAnswerEvent extends HttpEvent {
  HttpBloc bloc;
  Answer answer;

  ActionGetAnswerEvent(this.bloc, this.answer );

  @override
  String url() {
    return 'todo/api/v1/answer/detail/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Get;
  }

  @override
  Map<String, dynamic> toJson() {
    return answer != null ? {'id': answer.id.toString()} : null;
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 200) {
      Answer answer =   await Answer().fromJsonForAllAnswers(response.body );

      bloc.add(answer);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}

class ActionApproveEvent extends HttpEvent {
  ActionItem action;
  HttpBloc bloc;

  ActionApproveEvent(this.bloc, this.action);

  @override
  String url() {
    return '/todo/api/v1/';
  }

  @override
  HttpEnum mode() {
    return HttpEnum.Put;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'action_id': action.id.toString()};
  }

  @override
  bool hasHeader() {
    return true;
  }

  @override
  void setResponse(PlascoHttpResponse response) async {
    if (response.statusCode == 202) {
      bloc.add(true);
    }
  }

  @override
  List<Uint8List> files() {
    return null;
  }
}
