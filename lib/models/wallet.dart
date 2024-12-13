import 'package:prudapp/singletons/currency_math.dart';

import '../singletons/influencer_notifier.dart';

enum WalletType {
  influencer,
  switzStore,
  shipper,
  hotel,
  bus,
}

class WalletTransactionResult{
  bool succeeded;
  WalletHistory? tran;

  WalletTransactionResult({this.tran, required this.succeeded});
}

class WalletHistory{
  String? id;
  bool isCredit;
  String walletId;
  String transId;
  double amount;
  String viaChannel;
  DateTime dated;
  String currency;
  int month;
  int year;
  String selectedCurrency;
  double amtInSelectedCurrency;

  WalletHistory({
    required this.isCredit,
    this.id,
    required this.amount,
    required this.currency,
    required this.transId,
    required this.dated,
    required this.month,
    required this.viaChannel,
    required this.walletId,
    required this.year,
    required this.amtInSelectedCurrency,
    required this.selectedCurrency
  });

  Map<String, dynamic> toJson(){
    return {
      "isCredit": isCredit,
      "id": id,
      "amount": amount,
      "currency": currency,
      "transId": transId,
      "dated": dated.toIso8601String(),
      "month": month,
      "viaChannel": viaChannel,
      "selectedCurrency": selectedCurrency,
      "amtInSelectedCurrency": amtInSelectedCurrency,
      "walletId": walletId,
      "year": year,
    };
  }

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      id: json["id"],
      isCredit: json["isCredit"],
      amount: json["amount"],
      currency: json["currency"],
      transId: json["transId"],
      dated: DateTime.parse(json["dated"]),
      month: json["month"],
      viaChannel: json["viaChannel"],
      selectedCurrency: json["selectedCurrency"],
      amtInSelectedCurrency: json["amtInSelectedCurrency"],
      walletId: json["walletId"],
      year: json["year"]
    );
  }
}

class WalletAction {
  double amount;
  bool isCreditAction;
  String channel;
  String selectedCurrency;
  double amtInSelectedCurrency;
  String ownerId;

  WalletAction({
    required this.amount,
    required this.selectedCurrency,
    required this.amtInSelectedCurrency,
    required this.channel,
    required this.isCreditAction,
    required this.ownerId
  });

  Map<String, dynamic> toJson(){
    return {
      "amount": amount,
      "selectedCurrency": selectedCurrency,
      "amtInSelectedCurrency": amtInSelectedCurrency,
      "channel": channel,
      "isCreditAction": isCreditAction,
      "ownerId": ownerId
    };
  }
}

class Wallet{
  String id;
  double balance;
  DateTime createdOn;
  DateTime balanceAsAt;
  String? currencyCode;

  Wallet({
    required this.id,
    required this.balance,
    required this.balanceAsAt,
    required this.createdOn
  });

  Future<double> convertToInfluencersCurrency() async {
    double amtInWalletCur = await currencyMath.convert(
      amount: balance,
      quoteCode: influencerNotifier.influencerWalletCurrencyCode?? "NGN",
      baseCode: "NGN"
    );
    return currencyMath.roundDouble(amtInWalletCur, 2);
  }

  bool checkIfSufficient(double amtInNaira) => balance >= amtInNaira;

  Map<String, dynamic> toJson(){
    return {
      "id": id,
      "balance": balance,
      "createdOn": createdOn.toIso8601String(),
      "balanceAsAt": balanceAsAt.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json["id"],
      balance: json["balance"],
      createdOn: DateTime.parse(json["createdOn"]),
      balanceAsAt: DateTime.parse(json["balanceAsAt"])
    );
  }
}

class InfluencerWallet extends Wallet {
  String? affId;

  InfluencerWallet({
    required this.affId,
    required super.id,
    required super.balance,
    required super.balanceAsAt,
    required super.createdOn
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res["affId"] = affId;
    return res;
  }

  factory InfluencerWallet.fromJson(Map<String, dynamic> json){
    return InfluencerWallet(
      affId: json["affId"],
      id: json["id"],
      balance: json["balance"],
      createdOn: DateTime.parse(json["createdOn"]),
      balanceAsAt: DateTime.parse(json["balanceAsAt"])
    );
  }
}

class ShipperWallet extends Wallet {
  String? shipperId;

  ShipperWallet({
    required this.shipperId,
    required super.id,
    required super.balance,
    required super.balanceAsAt,
    required super.createdOn
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res["shipperId"] = shipperId;
    return res;
  }

  factory ShipperWallet.fromJson(Map<String, dynamic> json){
    return ShipperWallet(
        shipperId: json["shipperId"],
        id: json["id"],
        balance: json["balance"],
        createdOn: DateTime.parse(json["createdOn"]),
        balanceAsAt: DateTime.parse(json["balanceAsAt"])
    );
  }
}

class HotelWallet extends Wallet {
  String? hotelId;

  HotelWallet({
    required this.hotelId,
    required super.id,
    required super.balance,
    required super.balanceAsAt,
    required super.createdOn
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res["hotelId"] = hotelId;
    return res;
  }

  factory HotelWallet.fromJson(Map<String, dynamic> json){
    return HotelWallet(
      hotelId: json["hotelId"],
      id: json["id"],
      balance: json["balance"],
      createdOn: DateTime.parse(json["createdOn"]),
      balanceAsAt: DateTime.parse(json["balanceAsAt"])
    );
  }
}

class BusWallet extends Wallet {
  String? busId;

  BusWallet({
    required this.busId,
    required super.id,
    required super.balance,
    required super.balanceAsAt,
    required super.createdOn
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res["busId"] = busId;
    return res;
  }

  factory BusWallet.fromJson(Map<String, dynamic> json){
    return BusWallet(
        busId: json["busId"],
        id: json["id"],
        balance: json["balance"],
        createdOn: DateTime.parse(json["createdOn"]),
        balanceAsAt: DateTime.parse(json["balanceAsAt"])
    );
  }
}

class SwitzStoreWallet extends Wallet {
  String? storeId;

  SwitzStoreWallet({
    required this.storeId,
    required super.id,
    required super.balance,
    required super.balanceAsAt,
    required super.createdOn
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = super.toJson();
    res["storeId"] = storeId;
    return res;
  }

  factory SwitzStoreWallet.fromJson(Map<String, dynamic> json){
    return SwitzStoreWallet(
        storeId: json["storeId"],
        id: json["id"],
        balance: json["balance"],
        createdOn: DateTime.parse(json["createdOn"]),
        balanceAsAt: DateTime.parse(json["balanceAsAt"])
    );
  }
}