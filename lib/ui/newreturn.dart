//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:navigation_app/router/ui_pages.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../app_state.dart';
import 'package:thumbnailer/thumbnailer.dart';

bool EAN = false;
bool MOD = false;
PickedFile imageFile;
//FilePickerResult imageFile;
String _ruta ;
var _controller = TextEditingController();
final ImagePicker _picker = ImagePicker();
var _barcodeReader = FlutterBarcodeSdk();
bool perUnity = true;
var _loadReturn;
var _quantity;
XFile _quantityImage;

var type;
class NewReturn extends StatefulWidget {
  const NewReturn({Key key}) : super(key: key);

  @override
  State<NewReturn> createState() => _NewReturn();
}

class _NewReturn extends State<NewReturn> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.grey,
          title: const Text(
            'Nuevo Ingreso',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
        body: LayoutBuilder(
            builder: (BuildContext context,
                BoxConstraints viewportConstraints) {
              return SingleChildScrollView( //SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //Text('ID Lote Retail: '),
                      CheckboxListTile(
                        title: Text('EAN'),
                        value: EAN,
                        onChanged: (newValue) {
                          setState(() {
                            EAN = newValue;
                            MOD = false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      CheckboxListTile(
                        title: Text('MOD'),
                        value: MOD,
                        onChanged: (newValue2) {
                          setState(() {
                            MOD = newValue2;
                            EAN = false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, //  <-- leading Checkbox
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(15),
                        child: TextField(
                          autofocus: true,
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.send,
                          maxLength: 30,
                          decoration: InputDecoration(
                              hintText: 'EAN/MOD',
                              helperText: 'Ej: 939482'
                          ),
                          onChanged: (value) {
                            if (int
                                .parse(value)
                                .isEven) {
                              setState(() {
                                perUnity = true;
                              });
                            } else {
                              setState(() {
                                perUnity = false;
                              });
                            }
                          },
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(15),
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Buscar'),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 8),
                          padding: EdgeInsets.all(15),
                          //child: Scaffold(
                              //body: SafeArea(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          'Descripcion: Producto X!\nModelo: ABC123 Juridica: Ejemplo',
                                          style: const TextStyle(fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey),
                                        ),
                                        perUnity ?
                                        Container(
                                          margin: EdgeInsets.only(top: 8),
                                          padding: EdgeInsets.all(30),
                                          child: TextField(
                                              autofocus: true,
                                              keyboardType: TextInputType.text,
                                              textInputAction: TextInputAction.send,
                                              maxLength: 30,
                                              decoration: InputDecoration(
                                                  labelText: 'Código Interno de Producto',
                                                  helperText: 'Ej: AEF54216CV'
                                              ),
                                              onChanged: (value) {
                                                //_quantity = value;
                                              }
                                            //},
                                          ),
                                        ) :
                                        Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 8),
                                                padding: EdgeInsets.all(30),
                                                child: TextField(
                                                  autofocus: true,
                                                  keyboardType: TextInputType.text,
                                                  textInputAction: TextInputAction.send,
                                                  maxLength: 10,
                                                  decoration: InputDecoration(
                                                      labelText: 'Cantidad',
                                                      helperText: 'Ej: 12'
                                                  ),
                                                  onChanged: (value) {
                                                    _quantity = value;
                                                  }
                                                  //},
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 8),
                                                padding: EdgeInsets.all(15),
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    var temp_quant_image = await _picker.pickImage(source: ImageSource.gallery);
                                                    setState(() =>
                                                        _quantityImage = temp_quant_image
                                                    );
                                                  },
                                                  child: const Text('Cargar foto\n(opcional)'),
                                                  style: ElevatedButton.styleFrom(
                                                        primary: Colors.grey,
                                                        textStyle: TextStyle(
                                                            fontSize: 14,
                                                            //fontWeight: FontWeight.bold,
                                                            color: Colors.white
                                                        )
                                                  )
                                                ),
                                              ),
                                              /*const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 7),
                                                child: Text(
                                                  '(opcional)',
                                                  overflow: TextOverflow.clip,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),*/
                                              Thumbnail(
                                                dataResolver: () async {
                                                  return (await DefaultAssetBundle.of(context)
                                                      .load(_quantityImage.path.replaceAll('blob:', '')))
                                                      .buffer
                                                      .asUint8List();
                                                  },
                                                mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                                                widgetSize: 100,
                                              ),
                                            ]
                                          ),
                              ]),
                              //)
                          //)
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        padding: EdgeInsets.all(15),
                        child: ElevatedButton(
                          onPressed: () =>
                          appState.currentAction =
                              PageAction(state: PageState.pop,
                                  page: NewBatchPageConfig),
                          //devolver a new batch anterior
                          child: const Text('Confirmar'),
                        ),
                      ),
/*            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageFile == null
                            ? AssetImage('assets/images/logo_blanco.png')
                            : FileImage(File(imageFile.path)),
                        fit: BoxFit.cover)),
              ),
            ),*/
                      ListTile(
                          leading: const Icon(
                            Icons.photo_library,
                          ),
                          onTap: () async {
                            if (kIsWeb) {
                              /*final tmpFile = await getImage(1);
                setState(() async {
                  imageFile = tmpFile;
                  var fileBytes = await imageFile.readAsBytes();
                  //print('Path: ' + imageFile.files.single.path);
                  //metodo no soportado en Flutter web, buscar otra libreria
                  List<BarcodeResult> results = await _barcodeReader.decodeFileBytes(fileBytes);
                  print('Barcode: ' + results[0].toString());
                  _controller.text = results[0].toString();
                });*/
                            } else {
                              if (Platform.isAndroid || Platform.isIOS) {
                                setState(() async {
                                  final barcode = await BarcodeScanner.scan();
                                  _controller.text = barcode.rawContent;
                                });
                              }
                            }
                          }
                      ),
                    ],
                  ),
                ),
              );
            }
        ));
  }
}
Future getImage(int type) async {
  final pickedImage = await ImagePicker().getImage(
      source: type == 1 ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50);
  return pickedImage;
}