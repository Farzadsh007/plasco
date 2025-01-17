import 'dart:typed_data';

import 'package:plasco/models/auth/user.dart';
import 'package:plasco/services/constants.dart';
import 'package:shamsi_date/extensions.dart';

import '../../locator.dart';

class Answer {
  int id;
  int total;
  String title;
  String description;

  DateTime created_at;
  List<String> images;
  User creator;

  int action_id;
  List<Uint8List> files;

  Answer();

  Future<Answer> fromJson(Map<String, dynamic> json) async {
    total = json['total'] != null ? json['total'] : 0;
    if (json['last'] != null) {
      dynamic last = json['last'];
      id = last['id'] != null ? last['id'] : -1;
      title = last['title'] != null ? last['title'] : '';
      created_at = last['created_at'] != null
          ? DateTime.parse(last['created_at']).toLocal()
          : null;
      images = last['images'] != null
          ? await Future.wait((last['images'] as List)
              .map((e) async =>
                  locator<Constants>().ImageServerIP +
                  await locator<Constants>().decrypt(e))
              .toList())
          : [];

      creator = last['creator'] != null
          ? await User().fromJson(last['creator'])
          : null;
    }
    return this;
  }

  Future<Answer> fromJsonForAllAnswers(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'] : -1;
    title = json['title'] != null ? json['title'] : '';
    created_at =
        json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : null;
    images = json['images'] != null
        ? await Future.wait((json['images'] as List)
            .map((e) async =>
                locator<Constants>().ImageServerIP +
                await locator<Constants>().decrypt(e))
            .toList())
        : [];

    creator =
        json['creator'] != null ? await User().fromJson(json['creator']) : null;

    return this;
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'action_id': action_id,
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

/*Widget getDoneLabel() {
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
  }*/

}
