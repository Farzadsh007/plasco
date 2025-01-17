class Location {
  int id;
  String title;
  double lat;
  double lng;

  Location();

  Location.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? json['id'] : null;
    title = json['title'] != null ? json['title'] : '';
    lat = json['lat'] != null ? double.parse(json['lat']) : null;
    lng = json['lng'] != null ? double.parse(json['lng']) : null;
  }
}
