class PlascoHttpResponse {
  Map<String, dynamic> body;
  String message;
  Map<String, dynamic> dev_message;
  int statusCode;

  PlascoHttpResponse(this.body, this.message, this.dev_message);

  PlascoHttpResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    body = json['body'];
    message = json['message'] != null ? json['message'] : '';
    dev_message = json['dev-message'] != null ? json['dev-message'] : null;
    this.statusCode = statusCode;
  }
}
