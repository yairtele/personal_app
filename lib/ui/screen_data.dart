import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/business_services.dart';

class ScreenData<DataGetterParam, DataGetterReturn>{
  DataGetterReturn data;
  UserInfo userInfo;
  String companyName;
  Future<DataGetterReturn> Function(DataGetterParam getterParam) _dataGetter;

  ScreenData({Future<DataGetterReturn> Function(DataGetterParam getterParam) dataGetter}){
    _dataGetter = dataGetter;
  }

  ScreenData._withData(this.userInfo, this.companyName, this.data);

  Future<ScreenData<DataGetterParam, DataGetterReturn>> getScreenData({DataGetterParam dataGetterParam}) async{
    // Obtener CUIT del usuario (del perfil de Athento)
    var userInfo = await Cache.getUserInfo();

    if(userInfo == null) {
      final userName = await Cache.getUserName();
      userInfo = await BusinessServices.getUserInfo(userName);
      Cache.saveUserInfo(userInfo);
    }

    // Obtener Razon social con el servicio de Newsan
    var companyName = await Cache.getCompanyName();
    if(companyName ==  null) {
      companyName = await BusinessServices.getCompanyName(userInfo.idNumber); // En el idNumber del perfil de athento se guarda l CUIT retail
      Cache.saveCompanyName(companyName);
    }

    // Obtener lista de lotes Draft (en principio) desde Athento
    var data = null;
    if(_dataGetter != null){
      data = await _dataGetter(dataGetterParam);
    }

    return ScreenData._withData(userInfo, companyName, data);
  }


}