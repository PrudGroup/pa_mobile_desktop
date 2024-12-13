
class Locale {

  String lang;
  String symbol;

  Locale({required this.lang, required this.symbol});
}

final List<Locale> locales = [
  Locale(lang : "Afrikaans", symbol: "af"),
  Locale(lang : "Albanian", symbol: "sq"),
  Locale(lang : "Arabic", symbol: "ar"),
  Locale(lang : "Azerbaijani", symbol: "az"),
  Locale(lang : "Basque", symbol: "eu"),
  Locale(lang : "Bengali", symbol: "bn"),
  Locale(lang : "Belarusian", symbol: "be"),
  Locale(lang : "Bulgarian", symbol: "bg"),
  Locale(lang : "Catalan", symbol: "ca"),
  Locale(lang : "Chinese", symbol: "zh-CN"),
  Locale(lang : "Chinese Traditional", symbol: "zh-TW"),
  Locale(lang : "Croatian", symbol: "hr"),
  Locale(lang : "Czech", symbol: "cs"),
  Locale(lang : "Danish", symbol: "da"),
  Locale(lang : "Dutch", symbol: "nl"),
  Locale(lang : "English", symbol: "en"),
  Locale(lang : "American English", symbol: "enUs"),
  Locale(lang : "Esperanto", symbol: "eo"),
  Locale(lang : "Estonian", symbol: "et"),
  Locale(lang : "Filipino", symbol: "tl"),
  Locale(lang : "Finnish", symbol: "fi"),
  Locale(lang : "French", symbol: "fr"),
  Locale(lang : "Galician", symbol: "gl"),
  Locale(lang : "Georgian", symbol: "ka"),
  Locale(lang : "German", symbol: "de"),
  Locale(lang : "Greek", symbol: "el"),
  Locale(lang : "Gujarati", symbol: "gu"),
  Locale(lang : "Haitian Creole", symbol: "ht"),
  Locale(lang : "Hebrew", symbol: "iw"),
  Locale(lang : "Hindi", symbol: "hi"),
  Locale(lang : "Hungarian", symbol: "hu"),
  Locale(lang : "Icelandic", symbol: "is"),
  Locale(lang : "Indonesian", symbol: "id"),
  Locale(lang : "Irish", symbol: "ga"),
  Locale(lang : "Italian", symbol: "it"),
  Locale(lang : "Japanese", symbol: "ja"),
  Locale(lang : "Kannada", symbol: "kn"),
  Locale(lang : "Korean", symbol: "ko"),
  Locale(lang : "Latin", symbol: "la"),
  Locale(lang : "Latvian", symbol: "lv"),
  Locale(lang : "Lithuanian", symbol: "lt"),
  Locale(lang : "Macedonian", symbol: "mk"),
  Locale(lang : "Malay", symbol: "ms"),
  Locale(lang : "Maltese", symbol: "mt"),
  Locale(lang : "Norwegian", symbol: "no"),
  Locale(lang : "Persian", symbol: "fa"),
  Locale(lang : "Polish", symbol: "pl"),
  Locale(lang : "Portuguese", symbol: "pt"),
  Locale(lang : "Romanian", symbol: "ro"),
  Locale(lang : "Russian", symbol: "ru"),
  Locale(lang : "Serbian", symbol: "sr"),
  Locale(lang : "Slovak", symbol: "sk"),
  Locale(lang : "Slovenian", symbol: "sl"),
  Locale(lang : "Spanish", symbol: "ex"),
  Locale(lang : "Swahili", symbol: "sw"),
  Locale(lang : "Swedish", symbol: "sv"),
  Locale(lang : "Tamil", symbol: "ta"),
  Locale(lang : "Telugu", symbol: "te"),
  Locale(lang : "Thai", symbol: "th"),
  Locale(lang : "Turkish", symbol: "tr"),
  Locale(lang : "Ukrainian", symbol: "uk"),
  Locale(lang : "Urdu", symbol: "ur"),
  Locale(lang : "Vietnamese", symbol: "vi"),
  Locale(lang : "Welsh", symbol: "cy")
];

List<String> getLang(){
  List<String> langs = [];
  for (var lang in locales) {
    langs.add(lang.lang);
  }
  return langs;
}

List<String> langLocales = getLang();

String getSymbol(String lang){
  String symbol = '';
  symbol = locales.firstWhere((lan) => lan.lang.toLowerCase() == lang.toLowerCase()).symbol;
  return symbol;
}
