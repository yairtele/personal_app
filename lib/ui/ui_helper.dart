import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch_states.dart';

class UIHelper {
  static MaterialStateProperty<Color?>? getAuditItemBackgroundColor(String athentoLifeCycleState){
    return MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      return athentoLifeCycleState == BatchStates.InfoPendiente ? Colors.yellow.shade100 : null;
    });
  }

}