import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class MultipartMessageBuilder {

  final List<MessagePart> _parts = <MessagePart>[];
  late String  _boundaryString;

  MultipartMessageBuilder(){
    const uuid = Uuid();

    final fullBoundary = '------WebKitFormBoundary-' + uuid.v4();
    final maxLength = (fullBoundary.length < 70) ? fullBoundary.length : 70;

    _boundaryString = ('------WebKitFormBoundary-' + uuid.v4()).substring(0, maxLength); // Primeros 70 caracteres
  }

  String getBoundaryString(){
    return _boundaryString;
  }

  void addPart (Map<String, String>  partHeaders, String partContent){

    _parts.add(MessagePart(headers: partHeaders, content: partContent));
  }

  String build(){
    var message = getBoundaryString() ;
    for(var i=0; i < _parts.length; i++ ){
      message += '\n' + _getPartHeadersString(_parts[i].headers) + '\n\n' +
          _parts[i].content + '\n' +
          getBoundaryString();
    }
    return message;
  }

  String _getPartHeadersString(Map<String, String> headersJson){
    var headersString = '';
    var sep = '';
    for (final propName in headersJson.keys){
      headersString += sep + propName + ': ' + headersJson[propName]!;
      sep = '\n';
    }
    return headersString;
  }
}

class MessagePart {
  Map<String, String> headers;
  String content;

  MessagePart({required this.headers, required this.content});
}