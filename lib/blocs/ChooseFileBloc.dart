import 'dart:async';
import 'dart:typed_data';

class ChooseFileBloc {
  final _chooseFileStreamController = StreamController<Uint8List>.broadcast();

  StreamSink<Uint8List> get chooseFileSink => _chooseFileStreamController.sink;

  Stream<Uint8List> get streamChooseFile => _chooseFileStreamController.stream;

  ChooseFileBloc();

  addFile(Uint8List file) {
    chooseFileSink.add(file);
  }

  dispose() {
    _chooseFileStreamController.close();
  }
}
