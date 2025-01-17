import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plasco/custom_modules/Loading.dart';

class PleaseWaitDialog extends StatefulWidget {
  PleaseWaitDialog({Key key}) : super(key: key);

  @override
  _PleaseWaitDialogState createState() => _PleaseWaitDialogState();
}

class _PleaseWaitDialogState extends State<PleaseWaitDialog> {
  _PleaseWaitDialogState();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: SimpleDialog(backgroundColor: Colors.transparent, children: [
          Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[Loading()]))
        ]));
  }
}
