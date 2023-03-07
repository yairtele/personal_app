import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/business_services.dart';

class ScreenData<DataGetterParam, DataGetterReturn>{
  late final DataGetterReturn? data;
  late final UserInfo userInfo;
  Future<DataGetterReturn> Function(DataGetterParam? getterParam)? _dataGetter;

  ScreenData({Future<DataGetterReturn> Function(DataGetterParam? getterParam)? dataGetter}){
    _dataGetter = dataGetter;
  }

  //ScreenData()

  ScreenData._withData(this.userInfo, this.data);

  Future<ScreenData<DataGetterParam, DataGetterReturn>> getScreenData({DataGetterParam? dataGetterParam}) async{
    var userInfo = await Cache.getUserInfo();

    if(userInfo == null) {
      final userName = (await Cache.getUserName())!;
      userInfo = await BusinessServices.getUserInfo(userName);
      Cache.saveUserInfo(userInfo!);
    }

    // Obtener lista de lotes Draft (en principio) desde Athento
    var data = null;
    if(_dataGetter != null){
      data = await _dataGetter!(dataGetterParam);
    }

    return ScreenData._withData(userInfo, data);
  }


}