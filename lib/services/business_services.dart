import 'newsan_services.dart';
import 'sp_athento_services.dart';

class BusinessServices {

  static UserInfo getUserInfo(String user_name) {
    return SpAthentoServices.getUserInfo(user_name);
  }

  static String getCompanyName(String cuit) {
    return NewsanServices.getCompanyInfo(cuit);
  }

  static List<Batch> getBatches() {
    return SpAthentoServices.getBatches();
  }

}


