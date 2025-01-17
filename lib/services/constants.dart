import 'dart:async';
import 'dart:convert';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cryptography/cryptography.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
//import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plasco/blocs/http/HttpBloc.dart';
import 'package:plasco/custom_modules/SnackbarWidget.dart';
import 'package:plasco/models/auth/user.dart';
import 'package:plasco/models/company/company.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plasco/models/auth/enums.dart';
class Constants {
  String AccessToken = '';
  String RefreshToken = '';
  String DeviceID = '';
  String UserName = '';
  String Name = '';
  String Family = '';
  String MyPhone = '';
  String MyCountryCode = '';
  String UserID;
int Role=role.not_access.index;

  String site_id = '';
  String site_name = '';

  bool IsLoggedIn = false;
  Uint8List MyThumbImg;

  String ServerIP = 'gateway.plascoapp.com';
  String ImageServerIP = 'http://gateway.plascoapp.com';
  List<int> AES_SECRET_KEY = 'Qs#yNTUghY%VZwa9!wvXyKrvVP2yVkFq'.codeUnits;
  List<int> AES_IV_KEY = "1bKN13B8p\$KUszAb".codeUnits;
  final hmac = Hmac.sha256();
  SharedPreferences prefs;
  MyBloc profileHttpBloc = MyBloc();
  MyBloc memberShipHttpBloc = MyBloc();
  MyBloc locationsHttpBloc = MyBloc();
  MyBloc anomalyListHttpBloc = MyBloc();
  MyBloc actionListHttpBloc = MyBloc();
  MyBloc companyListHttpBloc = MyBloc();
  MyBloc personListHttpBloc = MyBloc();
  MyBloc relatedCompanyListHttpBloc = MyBloc();
  MyBloc viewAnomalyHttpBloc = MyBloc();

  Uint8List addIcon;
  Uint8List selectIcon;

  FirebaseMessaging  messaging = FirebaseMessaging.instance;

  var fireBaseToken ;
  DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

  AndroidDeviceInfo build;
//  PackageInfo packageInfo;

  static Constants _instance = new Constants.internal();

  Constants.internal() {
    //  SharedPreferences.setMockInitialValues({});

    setPref();
  }

  setPref() async {
    prefs = await SharedPreferences.getInstance();
    await getData();
    if (addIcon == null)
      addIcon =
          await getBytesFromAsset('assets/vectors/Icons/Location.png', 50);
    if (selectIcon == null)
      selectIcon = await getBytesFromAsset('assets/vectors/Icons/Logo.png', 50);

  //  packageInfo = await PackageInfo.fromPlatform();
      fireBaseToken= await  messaging.getToken();
      build = await deviceInfoPlugin.androidInfo;
  }

  Future<bool> getData() async {
    prefs = await SharedPreferences.getInstance();

    AccessToken = prefs.getString("AccessToken") ?? '';
    RefreshToken = prefs.getString("RefreshToken") ?? '';
    IsLoggedIn = AccessToken != '';
    UserName = prefs.getString("UserName") ?? '';
    Name = prefs.getString("Name") ?? '';
    Family = prefs.getString("Family") ?? '';
    UserID = prefs.getString("UserID");
    Role=prefs.getInt("Role");

    DeviceID = prefs.getString("DeviceID");
    MyCountryCode = prefs.getString("MyCountryCode") ?? '';
    MyPhone = prefs.getString("MyPhone") ?? '';

    site_id = prefs.getString("site_id") ?? '';
    site_name = prefs.getString("site_name") ?? '';

    return IsLoggedIn;
  }

  factory Constants() => _instance;

  encrypt(msg) async {
    var data = utf8.encode(msg).toList();

    final mac = await hmac.calculateMac(
      data,
      secretKey: SecretKey(AES_SECRET_KEY),
    );
    var ret = await AesCbc.with256bits(macAlgorithm: hmac).encrypt(
      data,
      secretKey: SecretKey(AES_SECRET_KEY),
      nonce: this.AES_IV_KEY,
    );

    List<int> lst = [];
    lst.addAll(ret.cipherText);
    // lst.addAll(mac.bytes);
    return base64Encode(lst);
  }

  Future<String> decrypt(String msg) async {
    var data = Base64Decoder().convert(msg);

    final mac = await hmac.calculateMac(
      data,
      secretKey: SecretKey(AES_SECRET_KEY),
    );
    SecretBox secretBox = new SecretBox(data, nonce: AES_IV_KEY, mac: mac);
    var ret = await AesCbc.with256bits(macAlgorithm: Hmac.sha256()).decrypt(
      secretBox,
      secretKey: SecretKey(AES_SECRET_KEY),
    );

    return String.fromCharCodes(ret);
  }

  getIsLoggedIn() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    IsLoggedIn = prefs.getString("AccessToken") != '';
  }

  Future<bool> setIsLoggedIn(bool value) async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    IsLoggedIn = value;
    return IsLoggedIn;
  }

  String getSite_id() {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    site_id = prefs.getString("site_id") ?? '';

    return site_id;
  }

  Future<bool> setSite_id(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    site_id = value;
    return prefs.setString("site_id", value);
  }

  String getSite_name() {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    site_name = prefs.getString("site_name") ?? '';

    return site_name;
  }

  Future<bool> setSite_name(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    site_name = value;
    return prefs.setString("site_name", value);
  }

  String getAccessToken() {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    AccessToken = prefs.getString("AccessToken") ?? '';
    return 'Bearer ' + AccessToken;
  }

  Future<bool> setAccessToken(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    AccessToken = value;
    return prefs.setString("AccessToken", value);
  }

  String getRefreshToken() {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    RefreshToken = prefs.getString("RefreshToken") ?? '';
    return RefreshToken;
  }

  Future<bool> setRefreshToken(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    RefreshToken = value;
    return prefs.setString("RefreshToken", value);
  }

  getName() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    Name = prefs.getString("Name") ?? '';
  }

  Future<bool> setName(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    Name = value;
    return prefs.setString("Name", value);
  }

  getFamily() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    Family = prefs.getString("Family") ?? '';
  }

  Future<bool> setFamily(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    Family = value;
    return prefs.setString("Family", value);
  }

  getUserName() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();

    UserName = prefs.getString("UserName") ?? '';
  }

  Future<bool> setUserName(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserName = value;
    return prefs.setString("UserName", value);
  }

  getMyPhone() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();

    MyPhone = prefs.getString("MyPhone") ?? '';
  }

  Future<bool> setMyPhone(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    MyPhone = value;
    return prefs.setString("MyPhone", value);
  }

  getMyCountryCode() async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();

    MyCountryCode = prefs.getString("MyCountryCode") ?? '';
  }

  Future<bool> setMyCountryCode(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    MyCountryCode = value;
    return prefs.setString("MyCountryCode", value);
  }

  getUserID() async {
    //   final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserID = prefs.getString("UserID") ?? '';
    var gg = '';
  }

  Future<bool> setUserID(String value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserID = value;
    return prefs.setString("UserID", value);
  }
 role getRole()  {
    //   final SharedPreferences prefs = await SharedPreferences.getInstance();
   var _role=prefs.getInt("Role");
    return  _role!=null?role.values.firstWhere((i) => i.index == _role) : role.not_access;

  }
  Future<bool> setRole(int value) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    Role = value;
    return prefs.setInt("Role", value);
  }

  bool hasAccess(BuildContext context, AccessEnum accessEnum, User creator,Company company)  {
 bool _access=false;
    var _role=prefs.getInt("Role");
    role _myRole=  _role!=null?role.values.firstWhere((i) => i.index == _role,orElse:()=> role.not_access ) : role.not_access;
switch (_myRole){

  case role.admin:
    if(accessEnum==AccessEnum.closeAnomaly || accessEnum==AccessEnum.deleteAnomaly){
      if(getSite_id()==company.id.toString()){
        _access= true;
      }else{
        _access= false;
      }
    }else{
      _access= true;
    }

    break;
  case role.has_inspector:
   switch(accessEnum){

     case AccessEnum.newAnomaly:
       _access= true;
       break;
     case AccessEnum.newAction:
     _access= getSite_id()==company.id.toString();
       break;
     case AccessEnum.closeAnomaly:

     case AccessEnum.closeAction:

     case AccessEnum.deleteAnomaly:
     _access= (getSite_id()==company.id.toString() && this.UserID==creator.id);
       break;
         default:
         _access=false;
         break;
   }
    break;
  case role.executive:
    case role.not_access:
  _access= false;
    break;
}
if(!_access){
  SnackBarWidget.buildErrorSnackBar(context, "شما دسترسی لازم را ندارید!");
}
return _access;
  }



  /* setProfile(String UserName, String Name, Uint8List Img) async {
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    this.UserName = UserName;
    this.Name = Name;

    prefs.setString("UserName", UserName);
    prefs.setString("Name", Name);

    User me = new User();
    me.id = this.UserID;
    me.Name = Name;

    me.ThumbImg = Img;
    me.Phone = MyPhone;
    me.CountryCode = MyCountryCode;
    profile_sink.add(me);
    if (!kIsWeb) {
      io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String path = appDocDirectory.path + "/thumb.png";
      if (Img != null) {
        io.File file = io.File(path);
        await file.writeAsBytes(Img);
      }else{
        io.File file = io.File(path);
        if(file.existsSync())await file.delete();
      }
    } else {
     if(Img!=null) prefs.setString("WebProfile", base64.encode(Img));
    }

    return true;
  }

  Future<Uint8List> getWebProfileImage() async {
    var ret;

    var base64Img = prefs.getString("WebProfile");
    if (base64Img != null) {
      ret = base64.decode(base64Img);
    }
    return ret;
  }

  getProfile() async {
    User me;
    if (kIsWeb) {
      //me = await locator<Dao>().getUser(locator<Constants>().UserID);

      me = new User();
      me.Name = Name;
      me.Family = Family;
      me.Phone = MyPhone;
      me.ThumbImg = await getWebProfileImage();
    } else {
      Directory appDocDirectory = await getApplicationDocumentsDirectory();
      String path = appDocDirectory.path + "/thumb.png";
      me = new User();
      me.Name = Name;
      me.Family = Family;
      me.Phone = MyPhone;
      File file = File(path);
      if (file.existsSync()) {
        me.ThumbImg = file.readAsBytesSync();
      }
    }

    profile_sink.add(me);
  }*/

  Future<bool> checkPermission(
      PermissionDialogEnum permissionDialogEnum) async {
    bool ret = false;

    switch (permissionDialogEnum) {
      case PermissionDialogEnum.camera:
        ret = await Permission.camera.status.isGranted;

        break;
      case PermissionDialogEnum.storage:
        ret = await Permission.storage.status.isGranted;

        break;
      case PermissionDialogEnum.location:
        ret = await Permission.location.status.isGranted;

        break;
    }
    return ret;
  }

  Future<void> requestPermission(
      PermissionDialogEnum permissionDialogEnum) async {
    switch (permissionDialogEnum) {
      case PermissionDialogEnum.camera:
        await Permission.camera.request();

        break;
      case PermissionDialogEnum.storage:
        await Permission.storage.request();

        break;
      case PermissionDialogEnum.location:
        await Permission.location.request();

        break;
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}

enum GoogleMapIcon { Main, Add }
enum PermissionDialogEnum { camera, storage, location }
enum AccessEnum{
  newAnomaly,newAction,closeAnomaly,closeAction,deleteAnomaly
,addPerson,editProfile,
  addCompany,editCompany,
  addRelatedCompany,
  addGroup,editGroup,
  addLocation,editLocation,
  approveButtons


}
