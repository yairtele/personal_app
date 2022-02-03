import 'package:flutter/material.dart';
import 'package:navigation_app/services/sp_athento_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/user_services.dart';
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
  bool _splashFinished = false;

  String companyName;

  bool get loggedIn  => _loggedIn;
  bool get splashFinished => _splashFinished;

  final cartItems = [];
  String emailAddress;
  String password;
  String description;
  String reference;
  PageAction _currentAction = PageAction();
  PageAction get currentAction => _currentAction;

  UserInfo userInfo = null;

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

  bool login() {
    UserServices.login(emailAddress, password);
    _loggedIn = true;
    saveLoginState(loggedIn);
    if(_loggedIn){
      _currentAction = PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
      notifyListeners();
    }

    return _loggedIn;

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
