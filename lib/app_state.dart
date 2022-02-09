import 'package:flutter/material.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    logout();
    if (_loggedIn || false) {
      _currentAction = PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
    } else {
      _currentAction = PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    }
    notifyListeners();
  }

  Future<bool> login() async{
    final tokenInfo = await UserServices.login(emailAddress, password);


    await Cache.saveUserName(emailAddress); //TODO: usar o no await?
    await Cache.saveTokenInfo(tokenInfo); //TODO: usar o no await?

    _loggedIn = true;
    Cache.saveLoginState(loggedIn);//TODO: usar o no await? En el código original no lo usaba
    if(_loggedIn){
      _currentAction = PageAction(state: PageState.replaceAll, page: ListItemsPageConfig);
      notifyListeners();
    }

    return _loggedIn;
  }

  void logout() {
    _loggedIn = false;
    Cache.saveLoginState(loggedIn); //TODO: usar o no await? En el código original no lo usaba
    _currentAction = PageAction(state: PageState.replaceAll, page: LoginPageConfig);
    notifyListeners();
  }



  void getLoggedInState() async {

    _loggedIn = await Cache.getLoggedInState();
    if (_loggedIn == null) {
      _loggedIn = false;
    }
  }
}
