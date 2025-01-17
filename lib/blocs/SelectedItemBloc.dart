import 'dart:async';

import 'package:plasco/models/DropDownItem.dart';

class SelectedItemBloc {
  final _selectedItemStreamController = StreamController<DropDownItem>();

  StreamSink<DropDownItem> get selectedItemSink =>
      _selectedItemStreamController.sink;

  Stream<DropDownItem> get streamSelectedItem =>
      _selectedItemStreamController.stream;

  SelectedItemBloc();

  select(DropDownItem item) {
    selectedItemSink.add(item);
  }

  dispose() {
    _selectedItemStreamController.close();
  }
}
