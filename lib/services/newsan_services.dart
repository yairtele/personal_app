import 'dart:convert';

import 'package:navigation_app/config/cache.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/sp_ws/sp_ws.dart';
import 'package:navigation_app/utils/sp_functions_utils.dart';

class NewsanServices {

  static Future<Map<String, dynamic>> getProductFullInfo(String productFileSearchKey, String productFileSearchValue) async {

    final userInfo = await Cache.getUserInfo();

    final headers=<String, String>{
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'auth-key': ''//Configuration.ebsWSToken
    };

    final jsonRequestBody=<String, dynamic>{};
    jsonRequestBody['codigoEan']='';
    jsonRequestBody['codigoComercial']='';
    jsonRequestBody[productFileSearchKey] = productFileSearchValue;
    jsonRequestBody['cuit'] = userInfo!.idNumber;

    final response = await SpWS.post(
        '',//Configuration.ebsWSUrl,
        parameters: {}, headers: headers,
        body: jsonRequestBody);

    const Converter<List<int>, String> _responseDecoder = Utf8Decoder();
    final jsonResponse = jsonDecode(_responseDecoder.convert(response.bodyBytes));
    final jsonResponseData = jsonResponse['data'];

    final responseData = getResponseData(jsonResponseData);
    return responseData;
  }

  static Map<String, dynamic> getResponseData(Map<String, dynamic> jsonResponseData){
    final jsonResponseBody = <String, dynamic>{};

    final productMasterInfo = ProductMasterInfo.create(
      ean: jsonResponseData['codigoEan']!,
      commercialCode: jsonResponseData['codigoComercial']!,
      sku: jsonResponseData['codigoSku']!,
      description: jsonResponseData['descripcion']!,
      brand: jsonResponseData['marca']!,
      legalEntity: jsonResponseData['juridica']!,
      businessUnit: jsonResponseData['negocio']!,
    );

    var productSalesInfo = null;
    try{
      productSalesInfo = ProductSalesInfo.create(
        lastSellDate: SpFunctionsUtils.parseLastSellDate(
            jsonResponseData['fecha']!),
        price: jsonResponseData['precio']!,
        retailAccount: jsonResponseData['cuenta']!,
      );
    }catch(e){}

    jsonResponseBody['productMasterInfo'] = productMasterInfo;
    jsonResponseBody['productSalesInfo'] = productSalesInfo;

    return jsonResponseBody;
  }

}