import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
final photos = List<String>.generate(4, (i) => 'Foto $i');

class DetailProduct extends StatelessWidget {
  final int id;
  const DetailProduct(this.id);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: Text(
          'Producto $id',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        actions: [
          Text(
            '\nBienvenido, ${appState.userInfo.firstName}!\nCUIT: ${appState.userInfo.idNumber}',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => appState.currentAction =
                PageAction(state: PageState.addPage, page: SettingsPageConfig),
          ),
          RaisedButton.icon(onPressed:(){
            launch('https://newsan.athento.com/accounts/login/?next=/dashboard/');
          }
            ,icon: Image.network('https://pbs.twimg.com/profile_images/1721100976/boton-market_sombra24_400x400.png'),
            label: Text(''),
            color: Colors.grey,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${photos[index]}'
              ),
              onTap: () {
                //appState.currentAction = PageAction(
                  //  state: PageState.addWidget,
                    //widget: DetailProduct(index),
                    //page: DetailProductPageConfig);
              },
            );
          },
        ),
      ),
    );
  }
}
