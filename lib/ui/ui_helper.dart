import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch_states.dart';

class UIHelper {
  static MaterialStateProperty<Color?>? getAuditItemBackgroundColor(String athentoLifeCycleState){
    return MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
      return athentoLifeCycleState == BatchStates.InfoPendiente ? Colors.yellow.shade100 : null;
    });
  }

  static EdgeInsets get  formFieldContainerPadding => const EdgeInsets.only(top: 5, bottom: 0, left: 15, right: 15) ;
  static EdgeInsets get  formFieldContainerMargin => const EdgeInsets.only(top: 8) ;
  static EdgeInsets get  buttonPadding => const EdgeInsets.fromLTRB(5, 0, 5, 0) ;

  static MaterialColor? getStateColor(String state){
    final colors = {
      BatchStates.Draft: Colors.grey,
      BatchStates.Enviado: Colors.blue,
      BatchStates.EnProceso: Colors.deepOrange,
      BatchStates.InfoPendiente: Colors.yellow,
      BatchStates.InfoEnviada: Colors.deepOrange,
    };

    return colors[state];
  }
}