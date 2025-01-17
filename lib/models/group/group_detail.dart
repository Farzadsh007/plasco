import 'package:plasco/models/auth/user.dart';

class GroupDetail {
  int id;
  String name;
  List<User> members = [];

  GroupDetail();

  Future<GroupDetail> fromJson(Map<String, dynamic> json) async {
    id = json['id'] != null ? json['id'] : -1;
    name = json['name'] != null ? json['name'] : '';

    members = json['members'] != null
        ? await Future.wait((json['members'] as List)
            .map((e) async => User().fromJson(e))
            .toList())
        : [];

    return this;
    var ff = '';
  }
}
