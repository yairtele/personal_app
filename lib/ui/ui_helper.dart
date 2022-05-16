import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch_states.dart';

class UIHelper {
  static MaterialStateProperty<Color?>? getAuditItemBackgroundColor(String athentoLifeCycleState){
    return MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      return athentoLifeCycleState == BatchStates.InfoPendiente ? Colors.yellow.shade100 : null;
    });
  }

  static EdgeInsets get  formFieldContainerPadding => const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15) ;
  static EdgeInsets get  formFieldContainerMargin => const EdgeInsets.only(top: 8) ;

}