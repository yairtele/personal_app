import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/batch.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/return_request.dart';
import 'package:navigation_app/ui/batch_details.dart';
import 'package:navigation_app/ui/product_details.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
import 'newreturn.dart';

class  ReturnRequestDetails extends StatefulWidget {
  final ReturnRequest returnRequest;
  final Batch batch;
  const ReturnRequestDetails({Key? key, required this.batch, required this.returnRequest}) : super(key: key);

  @override
  _ReturnRequestDetailsState createState() =>  _ReturnRequestDetailsState();
}

class  _ReturnRequestDetailsState extends State<ReturnRequestDetails> {

  late Future<ScreenData<String, List<Product>>> _localData;

  @override
  void initState() {
    super.initState();
    _localData = ScreenData<String, List<Product>>(dataGetter: _getProducts)
        .getScreenData(dataGetterParam: widget.returnRequest.uuid);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final returnRequest = widget.returnRequest;

    return FutureBuilder<ScreenData<String, List<Product>>>(
        future: _localData,
        builder: (BuildContext context,
            AsyncSnapshot<ScreenData<String, List<Product>>> snapshot) {
          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final products = data.data!;
            final reference = returnRequest.retailReference;
            final _eanTextController = TextEditingController(
                text: returnRequest.EAN);
            final _reference = TextEditingController(text: reference);
            final cantidad = returnRequest.quantity;
            final _cantidad = TextEditingController(text: cantidad.toString());
            final descripcion = returnRequest.description;
            final _descripcion = TextEditingController(text: descripcion);
            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
                title: Text(
                  'Solicitud ${returnRequest.retailReference ??
                      returnRequest.description}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () =>
                    appState.currentAction =
                        PageAction(
                            state: PageState.addPage, pageConfig: SettingsPageConfig),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => //TODO: ver si se debe poder realizar una nueva devolución para los EAN no autitables, o cómo precargar los datos en la pantalla NewReturn
                    appState.currentAction =
                        PageAction(state: PageState.addPage,
                            widget: NewReturnScreen(batch: this.widget.batch, returnRequest: this.widget.returnRequest),
                            pageConfig: NewReturnPageConfig),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    onPressed: () {
                      launch(
                          'https://newsan.athento.com/accounts/login/?next=/dashboard/');
                    }
                    , icon: Image.asset(
                    'assets/images/boton_athento.png',
                    height: 40.0, width: 40.0,),
                    label: Text(''),
                  ),
                ],
              ),

              body: SafeArea(
                child: ListView(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        //enabled: false,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 50,
                        controller: _eanTextController,
                        decoration: const InputDecoration(
                          hintText: 'EAN',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'EAN:',
                                        style: const TextStyle(fontSize: 18.0,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ),
                    if(!returnRequest.isAuditable)
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(15),
                        child: TextField(
                          //enabled: false,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          maxLength: 50,
                          controller: _reference,
                          decoration: const InputDecoration(
                            hintText: 'Referencia Interna',
                            label: Text.rich(
                                TextSpan(
                                  children: <InlineSpan>[
                                    WidgetSpan(
                                      child: Text(
                                          'Referencia Interna:',
                                          style: const TextStyle(fontSize: 18.0,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        //enabled: false,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 50,
                        controller: _descripcion,
                        decoration: const InputDecoration(
                          hintText: 'Descripcion',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Descripcion:', style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        //enabled: false,
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 50,
                        controller: _cantidad,
                        decoration: const InputDecoration(
                          hintText: 'Unidades',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Unidades:', style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [ ElevatedButton(
                            onPressed: () async {
                              try{
                                WorkingIndicatorDialog().show(context, text: 'Actualizando Solicitud...');
                                await _updateReqReturn(returnRequest,_eanTextController.text,_reference.text,_descripcion.text,_cantidad.text);
                                _showSnackBar('Solicitud actualizada con éxito');
                              }
                              on BusinessException catch (e){
                                _showSnackBar(e.message);
                              }
                              on Exception catch (e){
                                _showSnackBar('Ha ocurrido un error inesperado al actualizar la solicitud: $e');
                              }
                              finally{
                                WorkingIndicatorDialog().dismiss();
                              }
                            },
                            child: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green[400],
                            )
                        ),
                          ElevatedButton(
                              onPressed: () async {
                                try {
                                  WorkingIndicatorDialog().show(
                                      context, text: 'Eliminando Solicitud...');
                                  await _deleteReqReturn(returnRequest);
                                  _showSnackBar(
                                      'Solicitud eliminada con éxito');
                                }
                                on BusinessException catch (e) {
                                  _showSnackBar(e.message);
                                }
                                on Exception catch (e) {
                                  _showSnackBar(
                                      'Ha ocurrido un error inesperado eliminando la solicitud: $e');
                                }
                                finally {
                                  WorkingIndicatorDialog().dismiss();
                                }
                              },
                              child: const Text('Borrar Solicitud'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              )
                          ),
                        ],
                      ),
                    ),
                    DataTable(
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text('Productos:'),
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        products.length,
                            (int index) =>
                            DataRow(
                              cells: <DataCell>[DataCell(
                                  ListTile(isThreeLine: true,
                                    leading: const Icon(Icons.workspaces_filled,
                                      color: Colors.grey,),
                                    title: Text(
                                        'Ref: ${products[index].retailReference ??
                                            '(sin referencia interna)' }'),
                                    subtitle: const Text(''),
                                  ), onTap: () {
                                appState.currentAction = PageAction(
                                    state: PageState.addWidget,
                                    widget: ProductDetails(
                                        product: products[index]),
                                    pageConfig: DetailProductPageConfig);
                              })
                              ],

                            ),
                      ),
                    ),
                  ],
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
                        child: CircularProgressIndicator(
                            backgroundColor: Colors.grey),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Cargando...', style: TextStyle(
                            color: Colors.grey, height: 4, fontSize: 9)),
                      )
                    ]
                )
            );
          }
          return widget;
        }
    );
  }

  Future<List<Product>> _getProducts(String? returnRequestUUID) async {
    final products = await BusinessServices.getProductsByReturnRequestUUID(
        returnRequestUUID!);

    return products;
  }

  Future<void> _deleteReqReturn(ReturnRequest req_return) async {
    await BusinessServices.deleteReqReturnByUUID(req_return.uuid!);
  }

  Future<void> _updateReqReturn(ReturnRequest req_return, String EAN,
      String reference, String description, String unities) async {
    await BusinessServices.updateReqReturn(
        req_return, EAN, reference, description, unities);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

