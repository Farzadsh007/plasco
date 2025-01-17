import 'dart:async';

import 'package:plasco/models/auth/user.dart';

abstract class HttpBloc {
  dispose();

  add(dynamic event);

  HttpBloc();
}

class AuthEnterBloc extends HttpBloc {
  final _authEnterNoStreamController = StreamController<bool>.broadcast();

  StreamSink<bool> get authEnterNoSink => _authEnterNoStreamController.sink;

  Stream<bool> get streamAuthEnterNo => _authEnterNoStreamController.stream;

  @override
  dispose() {
    _authEnterNoStreamController.close();
  }

  @override
  add(dynamic event) {
    authEnterNoSink.add(event);
  }
}

class ProfileBloc extends HttpBloc {
  final _StreamController = StreamController<User>.broadcast();

  StreamSink<User> get sink => _StreamController.sink;

  Stream<User> get stream => _StreamController.stream;

  @override
  dispose() {
    _StreamController.close();
  }

  @override
  add(dynamic event) {
    sink.add(event);
  }
}

class MyBloc extends HttpBloc {
  final _StreamController = StreamController<dynamic>.broadcast();

  StreamSink<dynamic> get sink => _StreamController.sink;

  Stream<dynamic> get stream => _StreamController.stream;

  @override
  dispose() {
    _StreamController.close();
  }

  @override
  add(dynamic event) {
    sink.add(event);
  }
}
