import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';

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
      "is_credit": isCredit,
      "id": id,
      "amount": amount,
      "currency": currency,
      "trans_id": transId,
      "dated": dated.toIso8601String(),
      "month": month,
      "via_channel": viaChannel,
      "selected_currency": selectedCurrency,
      "amt_in_selected_currency": amtInSelectedCurrency,
      "wallet_id": walletId,
      "year": year,
    };
  }

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    return WalletHistory(
      id: json["id"],
      isCredit: json["is_credit"],
      amount: json["amount"],
      currency: json["currency"],
      transId: json["trans_id"],
      dated: DateTime.parse(json["dated"]),
      month: json["month"],
      viaChannel: json["via_channel"],
      selectedCurrency: json["selected_currency"],
      amtInSelectedCurrency: json["amt_in_selected_currency"],
      walletId: json["wallet_id"],
      year: json["year"]
    );
  }
}

class WalletAction {
  String affId;
  double amount;
  bool isCreditAction;
  String channel;
  String selectedCurrency;
  double amtInSelectedCurrency;

  WalletAction({
    required this.amount,
    required this.affId,
    required this.selectedCurrency,
    required this.amtInSelectedCurrency,
    required this.channel,
    required this.isCreditAction
  });

  Map<String, dynamic> toJson(){
    return {
      "amount": amount,
      "aff_id": affId,
      "selected_currency": selectedCurrency,
      "amt_in_selected_currency": amtInSelectedCurrency,
      "channel": channel,
      "is_credit_action": isCreditAction,
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
      createdOn: DateTime.parse(json["created_on"]),
      balanceAsAt: DateTime.parse(json["balance_as_at"])
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
      affId: json["aff_id"],
      id: json["id"],
      balance: json["balance"],
      createdOn: DateTime.parse(json["created_on"]),
      balanceAsAt: DateTime.parse(json["balance_as_at"])
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
    res["shipper_id"] = shipperId;
    return res;
  }

  factory ShipperWallet.fromJson(Map<String, dynamic> json){
    return ShipperWallet(
        shipperId: json["shipper_id"],
        id: json["id"],
        balance: json["balance"],
        createdOn: DateTime.parse(json["created_on"]),
        balanceAsAt: DateTime.parse(json["balance_as_at"])
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
      hotelId: json["hotel_id"],
      id: json["id"],
      balance: json["balance"],
      createdOn: DateTime.parse(json["created_on"]),
      balanceAsAt: DateTime.parse(json["balance_as_at"])
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
        createdOn: DateTime.parse(json["created_on"]),
        balanceAsAt: DateTime.parse(json["balance_as_at"])
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
    res["store_id"] = storeId;
    return res;
  }

  factory SwitzStoreWallet.fromJson(Map<String, dynamic> json){
    return SwitzStoreWallet(
        storeId: json["store_id"],
        id: json["id"],
        balance: json["balance"],
        createdOn: DateTime.parse(json["created_on"]),
        balanceAsAt: DateTime.parse(json["balance_as_at"])
    );
  }
}