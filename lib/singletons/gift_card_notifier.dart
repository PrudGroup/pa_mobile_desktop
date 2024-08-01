
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
  List<CartItem> selectedItems = [];
  List<GiftTransactionDetails> transactions = [];
  GiftTransactionDetails? selectedTransDetail;
  bool selectedItemsPaid = false;
  String? selectedItemPaymentId;
  List<CartItem> failedItems = [];
  List<CartItem> unsavedGifts = [];
  List<GiftTransaction> unsavedTrans = [];
  bool cartCanListen = true;

  void selectAllItems(){
    selectedItems = [...cartItems];
    cartCanListen = true;
    notifyListeners();
  }

  void updateCartListener(bool status){
    cartCanListen = status;
    notifyListeners();
  }

  void selectTransactionDetail(GiftTransactionDetails detail){
    selectedTransDetail = detail;
    notifyListeners();
  }

  void updateTransactions(List<GiftTransactionDetails> trans){
    transactions = trans;
    notifyListeners();
  }

  void addToTransactions(GiftTransactionDetails tran){
    transactions.add(tran);
    notifyListeners();
  }

  void unselectAllItems(){
    selectedItems = [];
    cartCanListen = true;
    notifyListeners();
  }

  Future<void> changeCartItem(int quantity, int itemIndex) async {
    CartItem item = cartItems[itemIndex];
    int presentQuant = item.quantity;
    item.grandTotal = (item.grandTotal/presentQuant) * quantity;
    item.quantity = quantity;
    item.totalDiscount = (item.totalDiscount/presentQuant) * quantity;
    item.amount = (item.amount/presentQuant) * quantity;
    item.charges = (item.charges/presentQuant) * quantity;
    cartItems[itemIndex] = item;
    changeItemInSelectedItems(item);
    await saveCartToCache();
  }

  Future<void> clearAllSavePaymentDetails() async {
    unsavedTrans = [];
    unsavedGifts = [];
    failedItems = [];
    selectedItemPaymentId = null;
    selectedItemsPaid = false;
    cartCanListen = true;
    myStorage.lStore.remove("unsavedGifts");
    myStorage.lStore.remove("unsavedTrans");
    myStorage.lStore.remove("failedItems");
    myStorage.lStore.remove("selectedItemPaymentId");
    myStorage.lStore.remove("selectedItemsPaid");
  }

  void changeItemInSelectedItems(CartItem newItem){
    int index = selectedItems.indexOf(newItem);
    if(index >= 0){
      selectedItems[index] = newItem;
      cartCanListen = true;
      notifyListeners();
    }
  }

  void addToSelectedItems(CartItem item){
    int found = selectedItems.indexWhere((CartItem ite) => ite.beneficiary?.fullName == item.beneficiary?.fullName
        && ite.beneficiary?.email == item.beneficiary?.email &&
        ite.product.productId == item.product.productId);
    if(found == -1) {
      selectedItems.add(item);
      cartCanListen = true;
      notifyListeners();
    }
  }

  Future<bool> checkIfItemExist(CartItem item) async{
    List<CartItem> found = cartItems.where((CartItem ite) => (ite.beneficiary!.fullName.toLowerCase() == item.beneficiary!.fullName.toLowerCase()) &&
        (ite.product.productId == item.product.productId)).toList();
    return found.isNotEmpty;
  }

  Future<void> addItemToCart(CartItem item) async {
    debugPrint("Cart: ${item.product.productId} | ${item.beneficiary?.email} | ${item.beneficiary?.fullName}");
    await checkIfItemExist(item).then((bool found) async {
      if(found) debugPrint("Found: $found");
      if(!found) {
        cartItems.add(item);
        await saveCartToCache();
        notifyListeners();
      }
    });
  }

  Future<void> addItemsToCart(List<CartItem> items) async {
    if(items.isNotEmpty){
      cartItems.addAll(items);
      await saveCartToCache();
      notifyListeners();
    }
  }

  Future<void> removeItemFromFailedItems(CartItem item) async {
    failedItems.remove(item);
    await saveFailedItemToCache();
    notifyListeners();
  }

  Future<void> removeItemFromUnsavedTrans(GiftTransaction item) async {
    unsavedTrans.remove(item);
    await saveUnsavedTransToCache();
    notifyListeners();
  }

  Future<void> addItemsToFailedItems(List<CartItem> items) async {
    if(items.isNotEmpty){
      failedItems.addAll(items);
      await saveFailedItemToCache();
      notifyListeners();
    }
  }

  Future<void> addItemsToUnsavedTrans(List<GiftTransaction> items) async {
    if(items.isNotEmpty){
      unsavedTrans.addAll(items);
      await saveUnsavedTransToCache();
      notifyListeners();
    }
  }

  Future<void> addItemsToUnsavedGifts(List<CartItem> items) async {
    if(items.isNotEmpty){
      unsavedGifts.addAll(items);
      await saveUnsavedGiftsToCache();
      notifyListeners();
    }
  }

  Future<void> updateItemsArePaidFor(bool paid, String payId) async {
    selectedItemsPaid = paid;
    selectedItemPaymentId = payId;
    await saveSelectedItemsPaidToCache();
    notifyListeners();
  }

  Future<void> removeItemFromCart(CartItem item) async {
    cartItems.remove(item);
    await saveCartToCache();
    notifyListeners();
  }

  void removeItemFromSelectedItems(CartItem item) {
    selectedItems.remove(item);
    notifyListeners();
  }

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
    }else{
      myStorage.lStore.remove("lastGiftSearch");
    }
  }

  Future<void> saveCartToCache() async {
    List<Map<String, dynamic>> items = [];
    if(cartItems.isNotEmpty){
      for(CartItem item in cartItems){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "cartItems", value: items);
    }else{
      myStorage.lStore.remove("cartItems");
    }
  }

  Future<void> saveFailedItemToCache() async {
    List<Map<String, dynamic>> items = [];
    if(failedItems.isNotEmpty){
      for(CartItem item in failedItems){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "failedItems", value: items);
    }else{
      myStorage.lStore.remove("failedItems");
    }
  }

  Future<void> saveUnsavedTransToCache() async {
    List<Map<String, dynamic>> items = [];
    if(unsavedTrans.isNotEmpty){
      for(GiftTransaction item in unsavedTrans){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "unsavedTrans", value: items);
    }else{
      myStorage.lStore.remove("unsavedTrans");
    }
  }

  Future<void> saveUnsavedGiftsToCache() async {
    List<Map<String, dynamic>> items = [];
    if(unsavedGifts.isNotEmpty){
      for(CartItem item in unsavedGifts){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "unsavedGifts", value: items);
    }else{
      myStorage.lStore.remove("unsavedGifts");
    }
  }

  Future<void> saveSelectedItemsPaidToCache() async {
    await myStorage.addToStore(key: "selectedItemsPaid", value: selectedItemsPaid);
    await myStorage.addToStore(key: "selectedItemPaymentId", value: selectedItemPaymentId);
  }

  Future<void> saveGiftibleCountriesToCache() async {
    List<Map<String, dynamic>> items = [];
    if(giftibleCountries.isNotEmpty){
      for(ReloadlyCountry item in giftibleCountries){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "giftibleCountries", value: items);
    }else{
      myStorage.lStore.remove("giftibleCountries");
    }
  }

  Future<void> saveGiftCategoriesToCache() async {
    List<Map<String, dynamic>> items = [];
    if(giftCategories.isNotEmpty){
      for(GiftCategory item in giftCategories){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "giftCategories", value: items);
    }else{
      myStorage.lStore.remove("giftCategories");
    }
  }

  Future<void> saveProductsToCache() async {
    List<Map<String, dynamic>> items = [];
    if(products.isNotEmpty){
      for(GiftProduct item in products){
        items.add(item.toJson());
      }
      await myStorage.addToStore(key: "giftProducts", value: items);
    }else{
      myStorage.lStore.remove("giftProducts");
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

  void getFailedItemsFromCache(){
    dynamic failedGiftItems = myStorage.getFromStore(key: "failedItems");
    if(failedGiftItems != null){
      List<dynamic> items = failedGiftItems;
      if(items.isNotEmpty){
        for (dynamic item in items) {
          failedItems.add(CartItem.fromJson(item));
        }
      }
    }
  }

  void getUnsavedTransFromCache(){
    dynamic unsavedGiftItems = myStorage.getFromStore(key: "unsavedTrans");
    if(unsavedGiftItems != null){
      List<dynamic> items = unsavedGiftItems;
      if(items.isNotEmpty){
        for (dynamic item in items) {
          unsavedTrans.add(GiftTransaction.fromJson(item));
        }
      }
    }
  }

  void getUnsavedGiftsFromCache(){
    dynamic unsavedGiftItems = myStorage.getFromStore(key: "unsavedGifts");
    if(unsavedGiftItems != null){
      List<dynamic> items = unsavedGiftItems;
      if(items.isNotEmpty){
        for (dynamic item in items) {
          unsavedGifts.add(CartItem.fromJson(item));
        }
      }
    }
  }

  void getSelectedItemsPaidFromCache(){
    bool? paid = myStorage.getFromStore(key: "selectedItemsPaid");
    String? payId = myStorage.getFromStore(key: "selectedItemPaymentId");
    if(paid != null){
      selectedItemsPaid = paid;
      if(payId != null) selectedItemPaymentId = payId;
    }
  }

  Future<FxRate?> getFxRate(String cur, double amount) async {
    String path = "fx-rate?currencyCode=$cur&amount=$amount";
    dynamic result = await makeRequest(path: path);
    if(result != null){
      return FxRate.fromJson(result);
    }else{ return null; }
  }

  Future<RedeemInstruction?> getRedeemInstructions(int brandId) async {
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

  Future<void> getTransactionsFromCloud(DateTime startDate, DateTime endDate) async {
    try{
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken != null && myStorage.user != null && myStorage.user!.id != null){
        String transUrl = "$apiEndPoint/gifts/aff/${myStorage.user!.id}/dates";
        Response res = await prudDio.get(
          transUrl,
          queryParameters: {
            "start_date": startDate.toIso8601String(),
            "end_date": endDate.toIso8601String(),
          }
        );
        if (res.data != null  && res.data.length > 0) {
          List<GiftTransactionDetails> newTrans = [];
          for(dynamic trans in res.data){
            newTrans.add(GiftTransactionDetails.fromJson(trans));
          }
          if(newTrans.isNotEmpty) updateTransactions(newTrans);
        }
        debugPrint("GetTransResults: $res : ${res.data}");
      }
    }catch(ex){
      debugPrint("giftCardNotifier.getTransactionsFromCloud Error: $ex");
    }
  }

  Future<bool> saveTransactionToCloud(GiftTransactionDetails details) async {
    bool saved = false;
    try{
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken != null){
        String transUrl = "$apiEndPoint/gifts/";
        Response res = await prudDio.post(transUrl, data: details.toJson());
        if (res.data != null  && res.data["gift_transaction_id"] != null) {
          saved = true;
        }else{
          saved = false;
        }
        debugPrint("TransSaveResults: $res : ${res.data}");
      }
    }catch(ex){
      debugPrint("giftCardNotifier.saveTransactionToCloud Error: $ex");
      return saved;
    }
    return saved;
  }

  Future<bool> addTransToCloud(GiftTransaction tran, CartItem gift) async {
    bool saved = false;
    try{
      double giftGrandTotalInNaira = await currencyMath.convert(
        amount: gift.grandTotal,
        quoteCode: "NGN",
        baseCode: gift.senderCur
      );
      double discountInNaira = await currencyMath.convert(
        amount: gift.totalDiscount,
        quoteCode: "NGN",
        baseCode: gift.senderCur
      );
      double transCostInSenderCur = await currencyMath.convert(
        amount: tran.amount!,
        quoteCode: gift.senderCur,
        baseCode: "NGN"
      );
      double income = (giftGrandTotalInNaira - tran.amount!) + discountInNaira;
      double appReferralCommission = income > 0? (income * installReferralCommission) : 0;
      double referComm = income > 0? (income * referralCommission) : 0;
      if(myStorage.installReferralCode == null) appReferralCommission = 0;
      if(myStorage.giftReferral == null) referComm = 0;
      double profit = income - (referComm + appReferralCommission);
      GiftTransactionDetails details = GiftTransactionDetails(
        income: income,
        installReferralCommission: appReferralCommission,
        installReferralId: appReferralCommission > 0? myStorage.installReferralCode : null,
        profitForPrudapp: profit,
        customerGot: discountInNaira,
        commissionFromReloadly: discountInNaira,
        referralsGot: appReferralCommission + referComm,
        referralCommission: referComm,
        transCurrency: tran.currencyCode,
        referralId: referComm > 0? myStorage.giftReferral : null,
        transDate: DateTime.parse(tran.transactionCreatedTime!),
        affId: myStorage.user?.id,
        transId: tran.transactionId,
        beneficiary: gift.beneficiary,
        transactionPaid: giftGrandTotalInNaira,
        transactionPaidInSelected: gift.grandTotal,
        selectedCurrencyCode: gift.senderCur,
        transactionCost: tran.amount,
        transactionCostInSelected: transCostInSenderCur,
        refunded: false,
        productPhoto: gift.productPhoto,
      );
      debugPrint("Trans Amount: ${details.transactionCost} | Profit: ${details.profitForPrudapp}");
      saved = await saveTransactionToCloud(details);
      if(saved == true) addToTransactions(details);
    }catch(ex){
      debugPrint("addTransToCloud Error: $ex");
    }
    return saved;
  }

  Future<List<GiftRedeemCode>?> getRedeemCode(int transId) async {
    String path = "orders/transactions/$transId/cards";
    List<GiftRedeemCode> items = [];
    List<dynamic>? result = await makeRequest(path: path);
    if(result != null){
      if(result.isNotEmpty){
        for(dynamic item in result){
          items.add(GiftRedeemCode.fromJson(item));
        }
        return items;
      }else{
        return [];
      }
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
      getUnsavedTransFromCache();
      getFailedItemsFromCache();
      getSelectedItemsPaidFromCache();
      getUnsavedGiftsFromCache();
      if(cartItems.isEmpty && failedItems.isNotEmpty){
        cartItems = failedItems;
      }
      notifyListeners();
    }catch(ex){
      debugPrint("GiftCardNotifier_initGiftCard Error: $ex");
    }
  }

  GiftCardNotifier._internal();
}

Dio giftDio = Dio(BaseOptions(
  receiveDataWhenStatusError: true,
  connectTimeout: const Duration(seconds: 60), // 60 seconds
  receiveTimeout: const Duration(seconds: 60),
  validateStatus: (statusCode) {
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
  }
));
final giftCardNotifier = GiftCardNotifier();
List<ReloadlyCountry> giftibleCountries = [];
List<GiftCategory> giftCategories = [];
double giftCustomerDiscountInPercentage = 1/3;
String giftApiUrl = Constants.apiStatues == 'production'? "https://giftcards.reloadly.com" : "https://giftcards-sandbox.reloadly.com";
String? reloadlyGiftToken;
