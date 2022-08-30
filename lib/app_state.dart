import 'dart:async';

import 'package:flutter/material.dart';
import 'config/cache.dart';
import 'services/user_services.dart';
import 'router/ui_pages.dart';



enum PageState {
  none,
  addPage,
  addAll,
  addWidget,
  pop,
  replace,
  replaceAll
}

class PageAction<TReturnValue> {
  PageState state;
  PageConfiguration? pageConfig;
  List<PageConfiguration>? pages;
  Widget? widget;
  Completer<TReturnValue>? returnValueCompleter;
  TReturnValue? returnValue;

  PageAction({this.state = PageState.none, this.pageConfig = null, this.pages, this.widget});
}
class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool _splashFinished = false;


  bool get loggedIn  => _loggedIn;
  bool get splashFinished => _splashFinished;

  final cartItems = [];

  //TODO: inicializar correctamente con null safety. O mejor, remover del AppState y pasar al Cache
  String username = '';
  String password = '';
  String description = '';
  String reference = '';
  String observation = '';
  String companyName = '';


  PageAction _currentAction = PageAction();
  PageAction get currentAction => _currentAction;

  set currentAction(PageAction action) {
    _currentAction = action;
    notifyListeners();
  }

  Future<TReturnValue?> waitCurrentAction<TReturnValue>(PageAction<TReturnValue> action) async{
    action.returnValueCompleter = Completer<TReturnValue>();
    _currentAction = action;
    notifyListeners();
    return action.returnValueCompleter!.future;
  }

  AppState() {
    getLoggedInState();
  }

  void resetCurrentAction() {
    _currentAction = PageAction();
  }


  void setSplashFinished() {
    _splashFinished = true;

    _currentAction = PageAction(state: PageState.replaceAll, pageConfig: LoginPageConfig);
    notifyListeners();
  }

  Future<bool> login() async{

    _loggedIn = await UserServices.login(username, password);

    await Cache.saveUserName(username);
    await Cache.saveUserPassword(password);

    Cache.saveLoginState(loggedIn);
    if(_loggedIn){
      _currentAction = PageAction(state: PageState.replaceAll, pageConfig: PresentationPageConfig);
      notifyListeners();
    }

    return _loggedIn;
  }

  Future<void> logout() async {
    _loggedIn = false;
    await Cache.clearAll();
    await Cache.saveLoginState(loggedIn);
    _currentAction = PageAction(state: PageState.replaceAll, pageConfig: LoginPageConfig);
    notifyListeners();
  }



  void getLoggedInState() async {
    _loggedIn = (await Cache.getLoggedInState()) ?? false;
  }

  void returnWith<TReturnValue>(TReturnValue value){

    _currentAction = PageAction<TReturnValue>(state: PageState.pop);
    _currentAction.returnValue = value;
    notifyListeners();
  }
}
