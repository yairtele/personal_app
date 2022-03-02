import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';

class WorkingIndicatorDialog {
  static final WorkingIndicatorDialog _singleton =
  WorkingIndicatorDialog._internal();
  BuildContext _context;

  factory WorkingIndicatorDialog() {
    return _singleton;
  }

  WorkingIndicatorDialog._internal();

  void show(BuildContext context, {String text = 'Loading...'}) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              backgroundColor: Colors.white,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 16, right: 16),
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(text),
                      )
                    ],
                  ),
                )
              ] ,
            ),
          );
        }
    );
  }

  void dismiss() {
    Navigator.of(_context).pop();
  }
}