import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navigation_app/services/athento/binary_file_info.dart';
import 'package:navigation_app/services/athento/sp_athento_services.dart';
import 'package:navigation_app/services/business/business_exception.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/product_photo.dart';
import 'package:navigation_app/services/business/business_services.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:navigation_app/utils/ui/sp_ui.dart';
import 'package:navigation_app/utils/ui/working_indicator_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';

class  ProductDetails extends StatefulWidget {
  final Product product;
  const ProductDetails({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsState createState() =>  _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Future<ScreenData<Product, Map<String, BinaryFileInfo?>>> _localData;
  Map<String, BinaryFileInfo?> _takenPictures = {};

  @override
  void initState(){
    super.initState();
    _localData = ScreenData<Product, Map<String, BinaryFileInfo?>>(dataGetter: _getProductPhotos).getScreenData(dataGetterParam: widget.product);
  }
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final product = widget.product;
    final newProductDetails = this;

    return FutureBuilder<ScreenData<Product, Map<String, BinaryFileInfo?>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<Product, Map<String, BinaryFileInfo?>>> snapshot) {

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data!;
            _takenPictures = data.data!;
            final EAN = product.EAN;
            final _EAN = TextEditingController(text:EAN);
            final descripcion = product.description;
            final _descripcion = TextEditingController(text:descripcion);
            final reference = product.retailReference;
            final _reference = TextEditingController(text:reference);

            widget = Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey,
                title: Text(
                  'Producto ${product.retailReference}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => appState.currentAction =
                        PageAction(state: PageState.addPage, pageConfig: SettingsPageConfig),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => appState.currentAction =
                        PageAction(state: PageState.addPage, pageConfig: NewReturnPageConfig),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    onPressed:(){
                    launch('https://newsan.athento.com/accounts/login/?next=/dashboard/');
                  }
                    ,icon: Image.asset(
                      'assets/images/boton_athento.png',
                      height: 40.0,width: 40.0,),
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
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 30,
                        enabled: false,
                        controller: _EAN,
                        decoration: const InputDecoration(
                          hintText: '-',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'EAN:',style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
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
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 50,
                        enabled: false,
                        controller: _descripcion,
                        decoration: const InputDecoration(
                          hintText: '-',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Descripcion:',style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
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
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.send,
                        maxLength: 50,
                        enabled: false,
                        controller: _reference,
                        decoration: const InputDecoration(
                          hintText: '-',
                          label: Text.rich(
                              TextSpan(
                                children: <InlineSpan>[
                                  WidgetSpan(
                                    child: Text(
                                        'Referencia:',style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                    ),
                Container(
                    child: SpUI.buildProductThumbnailsGridView(state: newProductDetails, photos:  _takenPictures)
                  /*GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(photos[0].label),
                          color: Colors.grey[500],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(photos[1].label),
                          color: Colors.grey[600],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(photos[2].label),
                          color: Colors.grey[700],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(photos[3].label),
                          color: Colors.grey[800],
                        ),
                      ],
                    )*/,
                   ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(100,0,100,0),
                    child: Container(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    try{
                                      WorkingIndicatorDialog().show(context, text: 'Actualizando producto...');
                                      //TODO: Ver qué le tengo que pasar. Únicamente sirve para guardar fotos, ya que EAN y Descripcion no se pueden modificar
                                      //await _updateProduct(product);
                                      //appState.currentAction = PageAction(state: PageState.addPage, page: DetailsPageConfig);
                                      _showSnackBar('Producto actualizado con éxito');
                                    }
                                    on BusinessException catch (e){
                                      _showSnackBar(e.message);
                                    }
                                    on Exception catch (e){
                                      _showSnackBar('Ha ocurrido un error inesperado al actualizar el producto: $e');
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
                      ),
                  )
                  ],
                )
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
                      Opacity(
                        opacity: 1,
                        child: CircularProgressIndicator(backgroundColor: Colors.grey),
                      ),
                      Padding(
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

  Future<Map<String, BinaryFileInfo?>> _getProductPhotos(Product? product) async {
    final productPhotos = await BusinessServices.getPhotosByProductUUID(product!.uuid!);

    //final returnValue = Future.delayed(const Duration(milliseconds: 100), () => productPhotos);
    //return returnValue;

    return productPhotos;
  }

  void _showSnackBar(String message){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

