class Update {
  String needs_update;
  String file;

  Update();

  Update.fromJson(Map<String, dynamic> json) {
    needs_update = json['needs_update'] != null ? json['needs_update'] : '';
    file = json['file'] != null ? json['file'] : '';
  }
}
