

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router/ui_pages.dart';

const String LoggedInKey = 'LoggedIn';

enum PageState {
  none,
  addPage,
  addAll,
  addWidget,
  pop,
  replace,
  replaceAll
}

class PageAction {
  PageState state;
  PageConfiguration page;
  List<PageConfiguration> pages;
  Widget widget;

  PageAction({this.state = PageState.none, this.page = null, this.pages = null, this.widget = null});
}
class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  bool get loggedIn  => _loggedIn;
  bool _splashFinished = false;
  bool get splashFinished => _splashFinished;
  final cartItems = [];
  String emailAddress;
  String password;
  PageAction _currentAction = PageAction();
  PageAction get currentAction => _currentAction;
  set currentAction(PageAction action) {
    _currentAction = action;
    notifyListeners();
  }

  AppState() {
    getLoggedInState();
  }

  void resetCurrentAction() {
    _currentAction = PageAction();
  }

  void addToCart(String item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeFromCart(String item) {
    cartItems.add(item);
    notifyListeners();
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }

  void setSplashFinished() {
    _splashFinished = true;
    if (_loggedIn) {
      _currentAction = PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    } else {
      _currentAction = PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    }
    notifyListeners();
  }

  void login() {
    _loggedIn = true;
    saveLoginState(loggedIn);
    _currentAction = PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    saveLoginState(loggedIn);
    _currentAction = PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    notifyListeners();
  }

  void saveLoginState(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(LoggedInKey, loggedIn);
  }

  void getLoggedInState() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = prefs.getBool(LoggedInKey);
    if (_loggedIn == null) {
      _loggedIn = false;
    }
  }
}