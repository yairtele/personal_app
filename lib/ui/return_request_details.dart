import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/product_details.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';

class  ReturnRequestDetails extends StatefulWidget {
  final ReturnRequest returnRequest;
  const ReturnRequestDetails({Key key, @required this.returnRequest}) : super(key: key);

  @override
  _ReturnRequestDetailsState createState() =>  _ReturnRequestDetailsState();
}

class  _ReturnRequestDetailsState extends State<ReturnRequestDetails> {

  Future<ScreenData<ReturnRequest, List<Product>>> _localData;

  @override
  void initState(){
    super.initState();
    _localData = ScreenData<ReturnRequest, List<Product>>(dataGetter: _getProducts).getScreenData(dataGetterParam: widget.returnRequest);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final returnRequest = widget.returnRequest;
    return FutureBuilder<ScreenData<ReturnRequest, List<Product>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<ReturnRequest, List<Product>>> snapshot) {

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data;
            final products = data.data;
            //List<bool> selected = List<bool>.generate(products.length, (int index) => false);
            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
                title: Text(
                  'Solicitud ${returnRequest.retailReference}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                actions: [
                  Text(
                    '\nBienvenido, ${data.userInfo.firstName}!\nCUIT: ${data.userInfo.idNumber}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => appState.currentAction =
                        PageAction(state: PageState.addPage, page: SettingsPageConfig),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => appState.currentAction =
                        PageAction(state: PageState.addPage, page: NewReturnPageConfig),
                  ),
                  RaisedButton.icon(onPressed:(){
                    launch('https://newsan.athento.com/accounts/login/?next=/dashboard/');
                  }
                    ,icon: Image.network(
                      'https://pbs.twimg.com/profile_images/1721100976/boton-market_sombra24_400x400.png',
                      height: 40.0,width: 40.0,),
                    label: Text(''),
                    color: Colors.grey,
                  ),
                ],
              ),

              body: SafeArea(
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text('Productos:'),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    products.length,
                        (int index) => DataRow(
                      cells: <DataCell>[DataCell(ListTile(isThreeLine: true,
                          leading: const Icon(Icons.workspaces_filled,color: Colors.grey,),
                          title: Text('EAN: ${products[index].EAN}',
                              style: const TextStyle(fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          subtitle: Text('${products[index].description}\n\n\n'),
                        ),onTap: () {
                        appState.currentAction = PageAction(
                            state: PageState.addWidget,
                            widget: ProductDetails(product: products[index]),
                            page: DetailProductPageConfig);})],
                      //selected: selected[index],
                    ),
                  ),
                  //onTap: () {
                ),
              ),
            );
          } else if (snapshot.hasError) {
            widget = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  )
                ],
              ),
            );
          } else {
            widget = Center(
                child: Stack(
                    children: <Widget>[
                      const Opacity(
                        opacity: 1,
                        child: CircularProgressIndicator(backgroundColor: Colors.grey),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Cargando...',style: TextStyle(color: Colors.grey,height: 4, fontSize: 9)),
                      )
                    ]
                )
            );
          }
          return widget;
        }
    );

  }

  Future<List<Product>> _getProducts(ReturnRequest batch) {
    throw Exception('No implementado');
  }

}

