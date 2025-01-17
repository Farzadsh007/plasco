import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plasco/custom_modules/CrossPlatformSvg.dart';
import 'package:plasco/custom_modules/LoadImage.dart';
import 'package:plasco/services/constants.dart';

import '../../color_palette.dart';
import '../../locator.dart';

class Group {
  int id;
  String name;
  List<String> members;
  int total_members;

  Group();

  Future<Group> fromJson(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'] : -1;
    name = json['name'] != null ? json['name'] : '';

    members = json['members'] != null
        ? await Future.wait((json['members'] as List)
            .map((e) async => e['logo'] != null
                ? locator<Constants>().ImageServerIP +
                    await locator<Constants>().decrypt(e['logo'])
                : '')
            .toList())
        : [];
    total_members = json['total_members'] != null ? json['total_members'] : 0;
    return this;
    var ff = '';
  }

  List<Widget> getGroupImage() {
    List<Widget> ret = [];
    if (members.length > 0) {
      ret.add(
        Container(
          alignment: Alignment.centerRight,
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1, color: ColorPalette.White1)),
          child: members[0] != ''
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: LoadImage.load(
                      url: members[0],
                      height: 40,
                      width: 40,
                      fit: BoxFit.fitHeight))
              : Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: ColorPalette.Gray3),
                  child: CrossPlatformSvg.asset(
                      assetPath: 'assets/vectors/Icons/AvatarPlaceHolder.svg',
                      height: 40,
                      width: 40,
                      fit: BoxFit.fitHeight)),
        ),
      );
      if (members.length > 1) {
        for (int i = 1; i < members.length; i++) {
          ret.add(Positioned(
            left: 32.0 * (i),
            child: Container(
                alignment: Alignment.centerRight,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1, color: ColorPalette.White1)),
                child: members[i] != ''
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(40.0),
                        child: LoadImage.load(
                            url: members[i],
                            height: 40,
                            width: 40,
                            fit: BoxFit.fitHeight))
                    : Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: ColorPalette.Gray3),
                        child: CrossPlatformSvg.asset(
                            assetPath:
                                'assets/vectors/Icons/AvatarPlaceHolder.svg',
                            height: 40,
                            width: 40,
                            fit: BoxFit.fitHeight),
                      )),
          ));
        }
      }
    } else {
      ret.add(Container());
    }
    return ret;
  }
}
