
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/gift_denomination.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../constants.dart';
import '../models/reloadly.dart';

class GiftCardNotifier extends ChangeNotifier {
  static final GiftCardNotifier _giftCardNotifier = GiftCardNotifier._internal();
  static get giftCardNotifier => _giftCardNotifier;

  factory GiftCardNotifier(){
    return _giftCardNotifier;
  }

  List<CartItem> cartItems = [];
  List<GiftProduct> products = [];
  int presentSelectedProductId = 0;
  GiftSearchCriteria? lastGiftSearch;
  Denomination? selectedDenMap;


  void updateSelectedDenMap(Denomination den){
    selectedDenMap = den;
    notifyListeners();
  }

  void changeSelectedProduct(int id){
    presentSelectedProductId = id;
    notifyListeners();
  }

  Future<void> updateLastGiftSearch(GiftSearchCriteria search) async {
    lastGiftSearch = search;
    await saveSearchCriteriaToCache();
    notifyListeners();
  }

  Future<void> saveSearchCriteriaToCache() async {
    if(lastGiftSearch != null){
      Map<String, dynamic> criteria = lastGiftSearch!.toJson();
      await myStorage.addToStore(key: "lastGiftSearch", value: criteria);
    }
  }

  Future<void> saveCartToCache() async {
    List<Map<String, dynamic>> items = [];
    if(cartItems.isNotEmpty){
      for(CartItem item in cartItems){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "cartItems", value: items);
    }
  }

  Future<void> saveGiftibleCountriesToCache() async {
    List<Map<String, dynamic>> items = [];
    if(giftibleCountries.isNotEmpty){
      for(ReloadlyCountry item in giftibleCountries){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "giftibleCountries", value: items);
    }
  }

  Future<void> saveGiftCategoriesToCache() async {
    List<Map<String, dynamic>> items = [];
    if(giftCategories.isNotEmpty){
      for(GiftCategory item in giftCategories){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "giftCategories", value: items);
    }
  }

  Future<void> saveProductsToCache() async {
    List<Map<String, dynamic>> items = [];
    if(products.isNotEmpty){
      for(GiftProduct item in products){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "giftProducts", value: items);
    }
  }

  void getCartFromCache(){
    dynamic giftCart = myStorage.getFromStore(key: "cartItems");
    if(giftCart != null){
      List<dynamic> items = giftCart;
      if(items.isNotEmpty){
        for (dynamic item in items) {
          cartItems.add(CartItem.fromJson(item));
        }
      }
    }
  }

  Future<FxRate?> getFxRate(String cur, double amount) async {
    String path = "fx-rate?currencyCode=$cur&amount=$amount";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      return FxRate.fromJson(result);
    }else{ return null; }
  }

  Future<RedeemInstruction?> getRedeemInstructions(String brandId) async {
    String path = "brands/$brandId/redeem-instructions";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      return RedeemInstruction.fromJson(result);
    }else{
      return null;
    }
  }

  Future<GiftTransaction?> getTransactionById(int transId) async {
    String path = "reports/transactions/$transId";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      return GiftTransaction.fromJson(result);
    }else{
      return null;
    }
  }

  Future<GiftTransaction?> makeOrder(GiftOrder order) async {
    String path = "orders";
    dynamic result = await makeRequest(path: path, isGet: false, data: order.toJson());
    if(result != null){
      return GiftTransaction.fromJson(result);
    }else{
      return null;
    }
  }

  Future<GiftRedeemCode?> getRedeemCode(int transId) async {
    String path = "orders/transactions/$transId/cards";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      return GiftRedeemCode.fromJson(result);
    }else{
      return null;
    }
  }

  Future<void> getGiftsByCountry(String iso) async {
    String path = "countries/$iso/products";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      products.clear();
      for(Map<String, dynamic> res in result){
        products.add(GiftProduct.fromJson(res));
      }
      await saveProductsToCache();
      notifyListeners();
    }
  }

  List<GiftProduct> getGiftsByCategory(int id) {
    if(products.isNotEmpty){
      List<GiftProduct> gifts = products.where((GiftProduct pro) => pro.category != null &&
          pro.category!.id != null && pro.category!.id == id).toList();
      return gifts;
    }else{
      return [];
    }
  }

  Future<void> getGiftCardToken() async {
    reloadlyGiftToken = await iCloud.getReloadlyToken(giftApiUrl);
  }

  void setDioHeaders(){
    giftDio.options.headers.addAll({
      "Content-Type": "application/json",
      "Accept": "application/com.reloadly.giftcards-v1+json",
      "Authorization": "$reloadlyGiftToken"
    });
  }

  Future<void> getGiftCategories() async {
    String path = "product-categories";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      for(Map<String, dynamic> res in result){
        giftCategories.add(GiftCategory.fromJson(res));
      }
    }
  }

  Future<void> getGiftCountries() async {
    String path = "countries";
    dynamic result = await makeRequest(path: path);
    if(result != null && result.isNotEmpty){
      for(Map<String, dynamic> res in result){
        giftibleCountries.add(ReloadlyCountry.fromJson(res));
      }
    }
  }

  ReloadlyCountry? getCountryByIso(String iso){
    if(iso.length == 2 && giftibleCountries.isNotEmpty){
      return giftibleCountries.firstWhere((ReloadlyCountry country) => country.isoName == iso);
    }else{
      return null;
    }
  }

  Future<PrudBalance?> getBalance() async {
    String path = "accounts/balance";
    dynamic res = await makeRequest(path: path);
    if(res != null){
      return PrudBalance(amount: res["balance"], currency: res["currencyCode"]);
    }else{
      return null;
    }
  }

  Future<bool> isBalanceSufficient(double baseAmount, String baseCur) async {
    PrudBalance? balance = await getBalance();
    if(balance != null){
      if(baseCur.toLowerCase() == balance.currency.toLowerCase()){
        return balance.amount >= baseAmount;
      }else{
        double convertedAmount = await currencyMath.convert(
          amount: baseAmount,
          quoteCode: balance.currency,
          baseCode: baseCur
        );
        return balance.amount >= convertedAmount;
      }
    }else{
      return false;
    }
  }

  Future<dynamic> makeRequest({required String path, bool isGet = true, Map<String, dynamic>? data}) async {
    if(reloadlyGiftToken == null) await getGiftCardToken();
    if(reloadlyGiftToken != null){
      setDioHeaders();
      String url = "$giftApiUrl/$path";
      Response res = isGet? (await giftDio.get(url)) : (await giftDio.post(url, data: data));
      debugPrint("Result: $res");
      return res.data;
    }
  }

  void getProductsFromCache(){
    dynamic giftPros = myStorage.getFromStore(key: "giftProducts");
    if(giftPros != null){
      List<dynamic> pros = giftPros;
      if(pros.isNotEmpty){
        products.clear();
        for (dynamic pro in pros) {
          products.add(GiftProduct.fromJson(pro));
        }
      }
    }
  }

  void getCountriesFromCache(){
    dynamic giftCountys = myStorage.getFromStore(key: "giftibleCountries");
    if(giftCountys != null){
      List<dynamic> countys = giftCountys;
      if(countys.isNotEmpty){
        for (dynamic co in countys) {
          giftibleCountries.add(ReloadlyCountry.fromJson(co));
        }
      }
    }
  }

  void getLastGiftSearchFromCache(){
    dynamic criteria = myStorage.getFromStore(key: "lastGiftSearch");
    if(criteria != null){
      lastGiftSearch = GiftSearchCriteria.fromJson(criteria);
    }
  }

  void getCategoriesFromCache(){
    dynamic giftCats = myStorage.getFromStore(key: "giftCategories");
    if(giftCats != null){
      List<dynamic> cats = giftCats;
      if(cats.isNotEmpty){
        for (dynamic cat in cats) {
          giftCategories.add(GiftCategory.fromJson(cat));
        }
      }
    }
  }

  Future<void> initGiftCard() async {
    try{
      getCountriesFromCache();
      getProductsFromCache();
      getCategoriesFromCache();
      getCartFromCache();
      getLastGiftSearchFromCache();
      notifyListeners();
    }catch(ex){
      debugPrint("GiftCardNotifier_initGiftCard Error: $ex");
    }
  }

  GiftCardNotifier._internal();
}

Dio giftDio = Dio(BaseOptions(validateStatus: (statusCode) {
  if(statusCode != null) {
    if (statusCode == 422) {
      return true;
    }
    if (statusCode >= 200 && statusCode <= 300) {
      return true;
    }
    return false;
  } else {
    return false;
  }
}));
final giftCardNotifier = GiftCardNotifier();
List<ReloadlyCountry> giftibleCountries = [];
List<GiftCategory> giftCategories = [];
String giftApiUrl = Constants.apiStatues == 'production'? "https://giftcards.reloadly.com" : "https://giftcards-sandbox.reloadly.com";
String? reloadlyGiftToken;
