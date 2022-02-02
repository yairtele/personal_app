class SpAthentoServices {
  static UserInfo getUserInfo(String user_name_or_uuid) {
    final user_info = UserInfo(idNumber: '20-3658479-5', userName: 'juan@retail.com', firstName: 'Juan', lastName: 'Pérez');
    if (user_info.idNumber == '') {
      throw Exception('El usuario $user_name_or_uuid no tiene el CUIT de retailer cargado en su perfil de Athento' );
    }

    return user_info;
  }

  static List<Batch> getBatches(){
    return [
      Batch(retailReference: 'HQ-1234', description: 'Electrodomésticos LG'),
      Batch(retailReference: 'GH-468', description: 'De todo un poco'),
      Batch(retailReference: '', description: 'Pequeños de Phillips'),
      Batch(retailReference: 'HQ-45286', description: 'Electrodomésticos LG'),
      Batch(retailReference: '', description: 'Devolución urgente'),
      Batch(retailReference: 'FF-761365', description: ''),
      Batch(retailReference: 'P-15651', description: 'La nada misma'),
      Batch(retailReference: 'RO-89654', description: 'Puras porquerías todas rotas'),
      Batch(retailReference: 'PP-1756', description: ''),
      Batch(retailReference: '', description: 'De todo un poco'),
    ];
  }
}

class Batch {
  Batch({this.retailReference, this.description});
  String retailReference;
  String description;
}

class UserInfo{
  UserInfo({this.uuid, this.idNumber, this.userName, this.firstName, this.lastName, this.email});
  String uuid;
  String idNumber;
  String userName;
  String firstName;
  String lastName;
  String email;
}
/*
 {
  "uuid": "a058298f-c902-43d0-b262-619057c55f66",
  "username": "adrian.scotto.newsan",
  "email": "adrian.scotto@socialpath.com.ar",
  "first_name": "Adrián",
  "last_name": "Scotto",
  "is_active": true,
  "date_joined": "2021-11-01T16:55:41+01:00",
  "phone_number": "",
  "is_accepted": true,
  "identification_number": "1234",
  "language": "en",
  "avatar": null,
  "defaulthome": null,
  "default_serie": null,
  "show_animations": true
}
* */