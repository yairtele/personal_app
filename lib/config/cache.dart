import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//TODO: ¿se debería usar await en todas las clases cliente cuando llamen a los métodos saveXXX?

class Cache{

  ///IMPORTANT: when adding new keys, check if they need to be cleared on new login, and add them to the 'keysToClearOnNewLogin' array
  static const _LOGGEDIN_KEY = 'LoggedIn';
  static const _TOKENINFO_KEY = 'TokenInfo';
  static const _USERINFO_KEY = 'UserInfo';
  static const _USERNAME_KEY = 'UserName';
  static const _USERPWD_KEY = 'UserPwd';
  static const _COMPANYNAME_KEY = 'CompanyName';
  static const _PRODUCTS_FILE_LAST_MODIFIED_DATE_KEY = 'ProductsFileLastModifiedDate';
  static const _SALES_FILE_LAST_MODIFIED_DATE_KEY = 'SalesFileLastModifiedDate';
  static const _RULES_FILE_LAST_MODIFIED_DATE_KEY = 'RulesFileLastModifiedDate';

  ///IMPORTANT: when adding new keys, check if they need to be cleared on new login, and add them to the 'keysToClearOnNewLogin' array
  static const keysToClearOnNewLogin = [
    _LOGGEDIN_KEY,
    _TOKENINFO_KEY,
    _USERINFO_KEY,
    _USERNAME_KEY,
    _USERPWD_KEY,
    _COMPANYNAME_KEY
  ];


  static Future<SharedPreferences> _getRepo() async{
    return SharedPreferences.getInstance();
  }

  static Future<void> saveLoginState(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_LOGGEDIN_KEY, loggedIn);
  }

  static Future<bool?> getLoggedInState() async {
    final prefs = await _getRepo();
    return  prefs.getBool(_LOGGEDIN_KEY);
  }

  static Future<void> saveTokenInfo(TokenInfo tokenInfo) async{
    final prefs = await _getRepo();
    prefs.setString(_TOKENINFO_KEY, tokenInfo.toJSONString());
  }

  static Future<TokenInfo?> getTokenInfo() async {
    final prefs = await _getRepo();
    final tokenInfoJsonString = prefs.getString(_TOKENINFO_KEY);
    return  tokenInfoJsonString != null ? TokenInfo.fromJSONString(tokenInfoJsonString) : null;
  }

  static Future<void> saveUserInfo(UserInfo userInfo) async{
    final prefs = await _getRepo();
    prefs.setString(_USERINFO_KEY, userInfo.toJSONString());
  }

  static Future<UserInfo?> getUserInfo() async{
    final prefs = await _getRepo();
    final userInfoJsonString = prefs.getString(_USERINFO_KEY);
    return userInfoJsonString != null ? UserInfo.fromJSONString(userInfoJsonString) : null;
  }

  static Future<void> saveUserName(String userName) async{
    final prefs = await _getRepo();
    prefs.setString(_USERNAME_KEY, userName);
  }

  static Future<String?> getUserName() async{
    final prefs = await _getRepo();
    return  prefs.getString(_USERNAME_KEY);
  }


  static Future<void> saveUserPassword(String password) async{
    final prefs = await _getRepo();
    prefs.setString(_USERPWD_KEY, password);
  }

  static Future<String?> getUserPassword() async{
    final prefs = await _getRepo();
    return  prefs.getString(_USERPWD_KEY);
  }


  static Future<void> saveCompanyName(String companyName) async{
    final prefs = await _getRepo();
    prefs.setString(_COMPANYNAME_KEY, companyName);
  }

  static Future<String?> getCompanyName() async{
    final prefs = await _getRepo();
    return  prefs.getString(_COMPANYNAME_KEY);
  }

  static Future<void> clearAll() async {
    final prefs = await _getRepo();

    for(final key in keysToClearOnNewLogin){
      prefs.remove(key);
    }
  }

  static Future<void> saveProductsFileLastModifiedDate(String lastModifiedDate) async{
    final prefs = await _getRepo();

    prefs.setString(_PRODUCTS_FILE_LAST_MODIFIED_DATE_KEY, lastModifiedDate);
  }

  static Future<String?> getProductsFileLastModifiedDate() async{
    final prefs = await _getRepo();

    return  prefs.getString(_PRODUCTS_FILE_LAST_MODIFIED_DATE_KEY);
  }

  static Future<void> saveSalesFileLastModifiedDate(String lastModifiedDate) async{
    final prefs = await _getRepo();

    prefs.setString(_SALES_FILE_LAST_MODIFIED_DATE_KEY, lastModifiedDate);
  }

  static Future<String?> getSalesFileLastModifiedDate() async{
    final prefs = await _getRepo();

    return  prefs.getString(_SALES_FILE_LAST_MODIFIED_DATE_KEY);
  }

  static Future<void> saveRulesFileLastModifiedDate(String lastModifiedDate) async{
    final prefs = await _getRepo();

    prefs.setString(_RULES_FILE_LAST_MODIFIED_DATE_KEY, lastModifiedDate);
  }

  static Future<String?> getRulesFileLastModifiedDate() async{
    final prefs = await _getRepo();

    return  prefs.getString(_RULES_FILE_LAST_MODIFIED_DATE_KEY);
  }

}
