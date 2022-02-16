class Product {
  String EAN;
  String retailReference;
  String commercialCode;
  String description;
  List<String> photos;
  DateTime lastSell;

  Product({this.EAN, this.retailReference, this.commercialCode, this.description, this.lastSell, this.photos});
}
