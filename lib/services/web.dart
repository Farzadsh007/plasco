import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:plasco/blocs/http/HttpEvent.dart';
import 'package:plasco/custom_modules/PleaseWaitDialog.dart';
import 'package:plasco/custom_modules/SnackbarWidget.dart';
import 'package:plasco/models/HttpResponse.dart';
import 'package:plasco/views/auth/EnterNoWidget.dart';

import '../locator.dart';
import 'constants.dart';

class Web {
  static final Web _instance = Web.internal();

  factory Web() {
    return _instance;
  }

  // static SocketIO socketIO;

  Web.internal();

  Future<String> refreshToken(BuildContext context) async {
    try {
      Uri uri;
      Response response;
      String token = locator<Constants>().getAccessToken();
      uri = Uri.http(
          locator<Constants>().ServerIP, '/account/api/v1/user_refresh_token/');
      response = await http
          .post(uri,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': token
              },
              body: json
                  .encode({'refresh': locator<Constants>().getRefreshToken()}))
          .timeout(const Duration(seconds: 20), onTimeout: () async {
        return null;
      });
      if (response != null) {
        if (response.statusCode == 200) {
          // final String res = response.body;
          final String res = utf8.decode(response.bodyBytes);
          await locator<Constants>().setAccessToken(json.decode(res)['access']);
          return json.decode(res)['access'];
        } else if (response.statusCode == 401) {
          await locator<Constants>().setAccessToken('');
          await locator<Constants>().setRefreshToken('');
          await locator<Constants>().setName('');
          await locator<Constants>().setFamily('');
          await locator<Constants>().setIsLoggedIn(false);

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => EnterNoWidget()),
              (Route<dynamic> route) => false);
        }
        return 'signOut';
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> openDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PleaseWaitDialog();
        });
  }

  Future<void> post(HttpEvent httpEvent, BuildContext context) async {
    if (httpEvent is DropDownGetPermissionEvent ||
        httpEvent is GroupSelectMembersForAddEvent ||
        httpEvent is LocationPrepareForAddEvent) {
      httpEvent.setResponse(null);
    } else {
      /* CustomProgressDialog progressDialog = CustomProgressDialog(context,blur: 10);

       ///You can set Loading Widget using this function
       progressDialog.setLoadingWidget(Loading());


       progressDialog.show();*/

      await openDialog(context);

      /*   BuildContext dialogContext;
       showDialog(
           context: context,routeSettings: ,
           barrierDismissible: false,
           builder: (context) {
             dialogContext = context;
             return PleaseWaitDialog();
           });*/

      // String token = locator<Constants>().getAccessToken();

      try {
        Response response = await postContent(httpEvent);
        if (response != null && response.statusCode == 401) {
          if (httpEvent.hasHeader()) {
            //  Navigator.pop(context);
            var token = await refreshToken(context);
            if (token == 'signOut') {
              return;
            }
            response = await postContent(httpEvent);
          }
        }

        if (response != null) {
          // final String res = response.body;
          final String res = utf8.decode(response.bodyBytes);
          PlascoHttpResponse _response = PlascoHttpResponse.fromJson(
              json.decode(res), response.statusCode);
          httpEvent.setResponse(_response);
          if (_response.message != null && _response.message.isNotEmpty)
            SnackBarWidget.buildErrorSnackBar(context, _response.message);
        } else {
          SnackBarWidget.buildErrorSnackBar(context, "خطا در برقراری ارتباط");

          /*return {
          "body": null,
          "message": "خطا در برقراری ارتباط",
          "dev-message": null
        };*/
        }
        //  progressDialog.dismiss();
        Navigator.pop(context);
      } catch (e) {
        // progressDialog.dismiss();
        var ghgh = '';
        Navigator.pop(context);
        SnackBarWidget.buildErrorSnackBar(context, "خطا در برقراری ارتباط");
        /*return {
        "body": null,
        "message": "خطا در برقراری ارتباط",
        "dev-message": null
      };*/
      }
    }
  }

  Future<Response> postContent(HttpEvent httpEvent) async {
    String token = locator<Constants>().getAccessToken();

    Uri uri;
    Response response;

    switch (httpEvent.mode()) {
      case HttpEnum.Get:
        uri = Uri.http(
            locator<Constants>().ServerIP, httpEvent.url(), httpEvent.toJson());
        response = await http
            .get(uri,
                headers:
                    httpEvent.hasHeader() ? {'Authorization': token} : null)
            .timeout(const Duration(seconds: 30), onTimeout: () async {
          // Navigator.pop(dialogContext);

          return null;
        });
        break;
      case HttpEnum.Post:
        uri = Uri.http(locator<Constants>().ServerIP, httpEvent.url());
        if (httpEvent.files() != null && httpEvent.files().length > 0) {
          var request = new http.MultipartRequest("POST", uri);

          for (int i = 0; i < httpEvent.files().length; i++) {
            var image = http.MultipartFile.fromBytes(
                'image_' + (i + 1).toString(), httpEvent.files()[i],
                filename: 'image_' + (i + 1).toString() + '.jpg');
            request.files.add(image);
          }

          request.fields.addAll(httpEvent
              .toJson()
              .map((key, value) => MapEntry(key, value?.toString())));
          if (httpEvent.hasHeader())
            request.headers.addAll({'Authorization': token});

          response = await http.Response.fromStream(await request
              .send()
              .timeout(const Duration(seconds: 30), onTimeout: () async {
            // Navigator.pop(dialogContext);

            return null;
          }));
        } else {
          var header = {'Content-Type': 'application/json; charset=UTF-8'};
          if (httpEvent.hasHeader()) header.addAll({'Authorization': token});
          response = await http
              .post(uri, headers: header, body: json.encode(httpEvent.toJson()))
              .timeout(const Duration(seconds: 30), onTimeout: () async {
            // Navigator.pop(dialogContext);

            return null;
          });
        }

        break;
      case HttpEnum.Put:
        uri = Uri.http(locator<Constants>().ServerIP, httpEvent.url());
        if (httpEvent.files() != null && httpEvent.files().length > 0) {
          var request = new http.MultipartRequest("PUT", uri);

          for (int i = 0; i < httpEvent.files().length; i++) {
            var image = http.MultipartFile.fromBytes(
                'image_' + (i + 1).toString(), httpEvent.files()[i],
                filename: 'image_' + (i + 1).toString() + '.jpg');
            request.files.add(image);
          }

          request.fields.addAll(httpEvent
              .toJson()
              .map((key, value) => MapEntry(key, value?.toString())));
          if (httpEvent.hasHeader())
            request.headers.addAll({'Authorization': token});

          response = await http.Response.fromStream(await request
              .send()
              .timeout(const Duration(seconds: 30), onTimeout: () async {
            // Navigator.pop(dialogContext);

            return null;
          }));
        } else {
          response = await http
              .put(uri,
                  headers: httpEvent.hasHeader()
                      ? {
                          // 'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': token
                        }
                      : null,
                  body: httpEvent.toJson())
              .timeout(const Duration(seconds: 30), onTimeout: () async {
            // Navigator.pop(dialogContext);

            return null;
          });
        }
        break;
      case HttpEnum.Delete:
        uri = Uri.http(locator<Constants>().ServerIP, httpEvent.url());
        var header = {'Content-Type': 'application/json; charset=UTF-8'};
        if (httpEvent.hasHeader()) header.addAll({'Authorization': token});
        response = await http
            .delete(uri, headers: header, body: json.encode(httpEvent.toJson()))
            .timeout(const Duration(seconds: 30), onTimeout: () async {
          // Navigator.pop(dialogContext);

          return null;
        });
        break;
    }

    return response;
  }
}
