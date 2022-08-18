class SpFunctionsUtils {

  static DateTime parseLastSellDate(String dateString){
    final rx = RegExp(r'(\d+)/(\d+)\/(\d+)');
    final match = rx.firstMatch(dateString);
    if(match != null) { //Formato dd/mm/yyyy
      dateString = '${match.group(3)}-${match.group(2)}-${match.group(1)}';
    }

    return DateTime.parse(dateString);
  }

  static double parseProductPrice(String priceString) {
    var cleanedPriceString = priceString;
    final decimalSeparatorRx = RegExp(r'([,\.])\d+$');
    final matches = decimalSeparatorRx.allMatches(priceString);
    final decimalSeparator = matches.length > 0 ? matches.first.group(1) : null;
    if(decimalSeparator != null){
      if(priceString.split(decimalSeparator).length == 2){
        cleanedPriceString = priceString.replaceAll(RegExp('[^0-9$decimalSeparator]'), '').replaceAll(',', '.');
      }
      else {
        cleanedPriceString = priceString.replaceAll(RegExp('[^0-9]'), '');
      }
    }

    return double.parse(cleanedPriceString);
  }//TODO: YAYO: Comentar cuando se habilite ws
}