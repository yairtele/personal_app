import 'package:flutter/material.dart';
import 'package:navigation_app/services/business/product.dart';
import 'package:navigation_app/services/business/product_photo.dart';
import 'package:navigation_app/ui/screen_data.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';



class  ProductDetails extends StatefulWidget {
  final Product product;
  const ProductDetails({Key key, @required this.product}) : super(key: key);

  @override
  _ProductDetailsState createState() =>  _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  Future<ScreenData<Product, List<ProductPhoto>>> _localData;

  @override
  void initState(){
    super.initState();
    _localData = ScreenData<Product, List<ProductPhoto>>(dataGetter: _getProductPhotos).getScreenData(dataGetterParam: widget.product);
  }
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final product = widget.product;

    return FutureBuilder<ScreenData<Product, List<ProductPhoto>>>(
        future: _localData,
        builder: (BuildContext context, AsyncSnapshot<ScreenData<Product, List<ProductPhoto>>> snapshot) {

          Widget widget;
          if (snapshot.hasData) {
            final data = snapshot.data;
            final photos = data.data;
            final EAN = product.EAN;
            final _EAN = TextEditingController(text:EAN);
            final descripcion = product.description;
            final _descripcion = TextEditingController(text:descripcion);

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
                    child: GridView.count(
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
                    ),
                   ),
                  Container(
                    child: ElevatedButton(
                            onPressed: () => appState.currentAction = PageAction(state: PageState.addPage, page: DetailsPageConfig),
                            child: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                            primary: Colors.green[400],
                              )
                            ),
                      ),
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

  Future<List<ProductPhoto>> _getProductPhotos(Product product) {
    final productPhotos = [
      ProductPhoto(label: 'Frente'),
      ProductPhoto(label: 'Dorso'),
      ProductPhoto(label: 'Accesorios'),
      ProductPhoto(label: 'Embalaje'),
    ];

    final returnValue = Future.delayed(const Duration(milliseconds: 100), () => productPhotos);
    return returnValue;
  }
}

