import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../router/ui_pages.dart';
final returns = List<String>.generate(10, (i) => 'Producto $i');

class DetailsReturn extends StatelessWidget {
  final int id;
  const DetailsReturn(this.id);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey,
        title: Text(
          'Solicitud $id',
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: returns.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${returns[index]}'
              ),
              onTap: () {
                appState.currentAction = PageAction(
                    state: PageState.addWidget,
                    widget: DetailsReturn(index),
                    page: DetailsReturnPageConfig);
              },
            );
          },
        ),
      ),
    );
  }
}
