class Province {
  int id;
  String name;
  List<String> cities = [];

  Province();

  Province.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? json['id'] : -1;
    name = json['name'] != null ? json['name'] : '';
    cities = json['provinces'] != null ? json['provinces'] as List<String> : [];
  }
}
