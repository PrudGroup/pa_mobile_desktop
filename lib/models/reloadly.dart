import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:prudapp/singletons/tab_data.dart';

class GiftSearchCriteria{
  Country beneficiaryCountry;
  Currency beneficiaryCurrency;
  Currency senderCurrency;
  GiftCategory? category;

  GiftSearchCriteria({
    required this.beneficiaryCountry,
    required this.beneficiaryCurrency,
    required this.senderCurrency,
    this.category
  });

  Map<String, dynamic> toJson(){
    return {
      if(category != null) "category": category!.toJson(),
      "beneficiaryCurrency": beneficiaryCurrency.toJson(),
      "beneficiaryCountry": beneficiaryCountry.toJson(),
      "senderCurrency": senderCurrency.toJson(),
    };
  }

  factory GiftSearchCriteria.fromJson(Map<String, dynamic> json){
    return GiftSearchCriteria(
      beneficiaryCountry: Country.from(json: json["beneficiaryCountry"]),
      beneficiaryCurrency: Currency.from(json: json["beneficiaryCurrency"]),
      senderCurrency: Currency.from(json: json["senderCurrency"]),
      category: json["category"] != null? GiftCategory.fromJson(json["category"]) : null,
    );
  }

}

class PhoneDetails{
  String? countryCode;
  String? phoneNumber;

  PhoneDetails({
    this.countryCode,
    this.phoneNumber
  });

  Map<String, dynamic> toJson(){
    return {
      if(countryCode != null) "countryCode": countryCode,
      if(phoneNumber != null) "phoneNumber": phoneNumber
    };
  }
}

class GiftRedeemCode{
  int? cardNumber;
  int? pinCode;

  GiftRedeemCode({this.cardNumber, this.pinCode});

  factory GiftRedeemCode.fromJson(Map<String, dynamic> json){
    return GiftRedeemCode(
      cardNumber: json["cardNumber"],
      pinCode: json["pinCode"]
    );
  }
}

class GiftOrder{
  String? customIdentifier;
  bool? preOrder;
  int productId;
  int quantity;
  String? recipientEmail;
  PhoneDetails? recipientPhoneDetails;
  String senderName;
  double unitPrice;

  GiftOrder({
    required this.productId,
    required this.quantity,
    required this.senderName,
    required this.unitPrice,
    this.preOrder,
    this.recipientEmail,
    this.recipientPhoneDetails,
  }){
    customIdentifier = tabData.getRandomString(18);
  }

  Map<String, dynamic> toJson(){
    return {
      "productId": productId,
      "quantity": quantity,
      "senderName": senderName,
      "unitPrice": unitPrice,
      if(customIdentifier != null) "customIdentifier": customIdentifier,
      if(preOrder != null) "preOrder": preOrder,
      if(recipientEmail != null) "recipientEmail": recipientEmail,
      if(recipientPhoneDetails != null) "recipientPhoneDetails": recipientPhoneDetails!.toJson(),
    };
  }
}

class GiftTransactionProduct{
  int? productId;
  String? productName;
  GiftBrand? brand;
  double? unitPrice;
  double? totalPrice;
  int? quantity;
  String? currencyCode;
  String? countryCode;

  GiftTransactionProduct({
    this.currencyCode,
    this.countryCode,
    this.quantity,
    this.productName,
    this.brand,
    this.productId,
    this.totalPrice,
    this.unitPrice
  });

  Map<String, dynamic> toJson(){
    return {
      if(currencyCode != null) "currencyCode": currencyCode,
      if(countryCode != null) "countryCode": countryCode,
      if(quantity != null) "quantity": quantity,
      if(productName != null) "productName": productName,
      if(brand != null) "brand": brand!.toJson(),
      if(productId != null) "productId": productId,
      if(totalPrice != null) "totalPrice": totalPrice,
      if(unitPrice != null) "unitPrice": unitPrice,
    };
  }

  factory GiftTransactionProduct.fromJson(Map<String, dynamic> json){
    return GiftTransactionProduct(
        currencyCode: json["currencyCode"],
        countryCode: json["countryCode"],
        quantity: json["quantity"],
        productName: json["productName"],
        brand: json["brand"] != null? GiftBrand.fromJson(json["brand"]) : null,
        productId: json["productId"],
        totalPrice: json["totalPrice"],
        unitPrice: json["unitPrice"]
    );
  }
}

class GiftTransaction{
  double? amount;
  String? currencyCode;
  String? customIdentifier;
  double? discount;
  double? fee;
  bool? preOrdered;
  String? recipientEmail;
  String? recipientPhone;
  double? smsFee;
  String? status; // SUCCESSFUL, PENDING, PROCESSING, REFUNDED, FAILED
  String? transactionCreatedTime;
  int? transactionId;
  GiftTransactionProduct? product;
  
  GiftTransaction({
    this.currencyCode,
    this.amount,
    this.product,
    this.customIdentifier,
    this.discount,
    this.fee,
    this.preOrdered,
    this.recipientEmail,
    this.recipientPhone,
    this.smsFee,
    this.status,
    this.transactionCreatedTime,
    this.transactionId,
  });
  
  Map<String, dynamic> toJson(){
    return {
      if(currencyCode != null) "currencyCode": currencyCode,
      if(amount != null) "amount": amount,
      if(product != null) "product": product!.toJson(),
      if(customIdentifier != null) "customIdentifier": customIdentifier,
      if(discount != null) "discount": discount,
      if(fee != null) "fee": fee,
      if(preOrdered != null) "preOrdered": preOrdered,
      if(recipientEmail != null) "recipientEmail": recipientEmail,
      if(recipientPhone != null) "recipientPhone": recipientPhone,
      if(smsFee != null) "smsFee": smsFee,
      if(status != null) "status": status,
      if(transactionCreatedTime != null) "transactionCreatedTime": transactionCreatedTime,
      if(transactionId != null) "transactionId": transactionId,
    };
  }

  factory GiftTransaction.fromJson(Map<String, dynamic> json){
    return GiftTransaction(
      currencyCode: json["currencyCode"],
      amount: json["amount"],
      product: json["product"] != null? GiftTransactionProduct.fromJson(json["product"]) : null,
      customIdentifier: json["customIdentifier"],
      discount: json["discount"],
      fee: json["fee"],
      preOrdered: json["preOrdered"],
      recipientEmail: json["recipientEmail"],
      recipientPhone: json["recipientPhone"],
      smsFee: json["smsFee"],
      status: json["status"],
      transactionCreatedTime: json["transactionCreatedTime"],
      transactionId: json["transactionId"],
    );
  }

}

class GiftTransactionDetails{
  String? id;
  String? affId;
  int? transId;
  double? income;
  DateTime? transDate;
  String? referralId;
  double? referralCommission;
  String? installReferralId;
  double? installReferralCommission;
  double? profit;
  String? transCurrency;
  bool? refunded;

  GiftTransactionDetails({
    this.transId,
    this.id,
    this.affId,
    this.income,
    this.installReferralCommission,
    this.installReferralId,
    this.profit,
    this.referralCommission,
    this.referralId,
    this.transCurrency,
    this.transDate,
    this.refunded,
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(affId != null) "affId": affId,
      if(transDate != null) "transDate": transDate!.toIso8601String(),
      if(transCurrency != null) "transCurrency": transCurrency,
      if(referralId != null) "referralId": referralId,
      if(referralCommission != null) "referralCommission": referralCommission,
      if(profit != null) "profit": profit,
      if(installReferralId != null) "installReferralId": installReferralId,
      if(installReferralCommission != null) "installReferralCommission": installReferralCommission,
      if(income != null) "income": income,
      if(transId != null) "transId": transId,
    };
  }

  factory GiftTransactionDetails.fromJson(Map<String, dynamic> json){
    return GiftTransactionDetails(
      id: json["id"],
      income: json["income"],
      installReferralCommission: json["installReferralCommission"],
      installReferralId: json["installReferralId"],
      profit: json["profit"],
      referralCommission: json["referralCommission"],
      transCurrency: json["transCurrency"],
      referralId: json["referralId"],
      transDate: json["transDate"] != null? DateTime.tryParse(json["transDate"]) : null,
      affId: json["affId"],
      transId: json["transId"],
    );
  }

}

class Beneficiary{
  String fullName;
  String countryCode;
  String phoneNo;
  String currencyCode;
  String gender;
  String email;
  String avatar;
  dynamic photo;
  bool isAvatar;
  String parseablePhoneNo;

  Beneficiary({
    required this.currencyCode,
    required this.countryCode,
    required this.fullName,
    required this.gender,
    required this.phoneNo,
    required this.email,
    required this.avatar,
    required this.photo,
    required this.parseablePhoneNo,
    this.isAvatar = true,
  });

  Map<String, dynamic> toJson(){
    return {
      "countryCode": countryCode,
      "currencyCode": currencyCode,
      "fullName": fullName,
      "email": email,
      "phoneNo": phoneNo,
      "gender": gender,
      "avatar": avatar,
      "isAvatar": isAvatar,
      "photo": photo,
      "parseablePhoneNo": parseablePhoneNo,
    };
  }

  factory Beneficiary.fromJson(Map<String, dynamic> json){
    return Beneficiary(
      currencyCode: json["currencyCode"],
      countryCode: json["countryCode"],
      fullName: json["fullName"],
      gender: json["gender"],
      phoneNo: json["phoneNo"],
      email: json["email"],
      avatar: json["avatar"],
      isAvatar: json["isAvatar"],
      parseablePhoneNo: json["parseablePhoneNo"],
      photo: json["photo"] != null? Uint8List.fromList(json["photo"].cast<int>().toList()) : null,
    );
  }
}

class CartItem{
  GiftProduct product;
  double benSelectedDeno;
  String benCur;
  int quantity;
  double charges;
  double amount;
  double totalDiscount;
  double grandTotal;
  String senderCur;
  DateTime createdOn;
  DateTime lastUpdated;
  Beneficiary? beneficiary;

  CartItem({
    required this.amount,
    required this.charges,
    required this.createdOn,
    required this.grandTotal,
    required this.lastUpdated,
    required this.product,
    required this.quantity,
    required this.totalDiscount,
    required this.senderCur,
    required this.benCur,
    required this.benSelectedDeno,
    this.beneficiary
  });

  Map<String, dynamic> toJson(){
    return {
      "amount": amount,
      "charges": charges,
      "createdOn": createdOn.toIso8601String(),
      "grandTotal": grandTotal,
      "lastUpdated": lastUpdated.toIso8601String(),
      "product": product.toJson(),
      "quantity": quantity,
      "totalDiscount": totalDiscount,
      "senderCur": senderCur,
      "benSelectedDeno": benSelectedDeno,
      "benCur": benCur,
      if(beneficiary != null) "beneficiary": beneficiary!.toJson(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json){
    return CartItem(
      amount: json["amount"],
      charges: json["charges"],
      createdOn: DateTime.parse(json["createdOn"]),
      grandTotal: json["grandTotal"],
      lastUpdated: DateTime.parse(json["lastUpdated"]),
      product: GiftProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      totalDiscount: json["totalDiscount"],
      senderCur: json["senderCur"],
      benCur: json["benCur"],
      benSelectedDeno: json["benSelectedDeno"],
      beneficiary: json["beneficiary"] != null? Beneficiary.fromJson(json["beneficiary"]) : null,
    );
  }
}
class GiftBrand{
  int? brandId;
  String? brandName;

  GiftBrand({
    this.brandId,
    this.brandName,
  });

  Map<String, dynamic> toJson(){
    return {
      if(brandName != null) "brandName": brandName,
      if(brandId != null) "brandId": brandId,
    };
  }

  factory GiftBrand.fromJson(Map<String, dynamic> json){
    return GiftBrand(
      brandId: json["brandId"],
      brandName: json["brandName"],
    );
  }

}

class RedeemInstruction{
  String? concise;
  String? verbose;
  String? brandId;
  String? brandName;


  RedeemInstruction({
    this.concise,
    this.verbose,
    this.brandName,
    this.brandId
  });

  Map<String, dynamic> toJson(){
    return {
      if(concise != null) "concise": concise,
      if(verbose != null) "verbose": verbose,
      if(brandName != null) "brandName": brandName,
      if(brandId != null) "brandId": brandId,
    };
  }

  factory RedeemInstruction.fromJson(Map<String, dynamic> json){
    return RedeemInstruction(
      concise: json["concise"],
      verbose: json["verbose"],
      brandName: json["brandName"],
      brandId: json["brandId"],
    );
  }
}

class GiftProduct{
  GiftBrand? brand;
  GiftCategory? category;
  ReloadlyCountry? country;
  String? denominationType; // FIXED, RANGE
  double? discountPercentage;
  List<dynamic>? fixedRecipientDenominations;
  Map<String, dynamic>? fixedRecipientToSenderDenominationsMap;
  List<dynamic>? fixedSenderDenominations;
  bool? global;
  List<dynamic>? logoUrls;
  double? maxRecipientDenomination;
  double? maxSenderDenomination;
  double? minRecipientDenomination;
  double? minSenderDenomination;
  int? productId;
  String? productName;
  String? recipientCurrencyCode;
  RedeemInstruction? redeemInstruction;
  String? senderCurrencyCode;
  double? senderFee;
  bool? supportsPreOrder;
  double? senderFeePercentage;


  GiftProduct({
    this.brand,
    this.senderFee,
    this.senderCurrencyCode,
    this.country,
    this.productId,
    this.category,
    this.denominationType,
    this.discountPercentage,
    this.fixedRecipientDenominations,
    this.fixedRecipientToSenderDenominationsMap,
    this.fixedSenderDenominations,
    this.global,
    this.logoUrls,
    this.maxRecipientDenomination,
    this.maxSenderDenomination,
    this.minRecipientDenomination,
    this.minSenderDenomination,
    this.productName,
    this.recipientCurrencyCode,
    this.redeemInstruction,
    this.senderFeePercentage,
    this.supportsPreOrder
  });

  Map<String, dynamic> toJson(){
    return {
      if(redeemInstruction != null) "redeemInstruction": redeemInstruction!.toJson(),
      if(brand != null) "brand": brand!.toJson(),
      if(senderFee != null) "senderFee": senderFee,
      if(country != null) "country": country!.toJson(),
      if(productId != null) "productId": productId,
      if(category != null) "category": category!.toJson(),
      if(denominationType != null) "denominationType": denominationType,
      if(discountPercentage != null) "discountPercentage": discountPercentage,
      if(fixedRecipientDenominations != null) "fixedRecipientDenominations": fixedRecipientDenominations,
      if(fixedRecipientToSenderDenominationsMap != null) "fixedRecipientToSenderDenominationsMap": fixedRecipientToSenderDenominationsMap,
      if(fixedSenderDenominations != null) "fixedSenderDenominations": fixedSenderDenominations,
      if(global != null) "global": global,
      if(logoUrls != null) "logoUrls": logoUrls,
      if(maxRecipientDenomination != null) "maxRecipientDenomination": maxRecipientDenomination,
      if(maxSenderDenomination != null) "maxSenderDenomination": maxSenderDenomination,
      if(minRecipientDenomination != null) "minRecipientDenomination": minRecipientDenomination,
      if(minSenderDenomination != null) "minSenderDenomination": minSenderDenomination,
      if(productName != null) "productName": productName,
      if(senderFeePercentage != null) "senderFeePercentage": senderFeePercentage,
      if(supportsPreOrder != null) "supportsPreOrder": supportsPreOrder,
      if(recipientCurrencyCode != null) "recipientCurrencyCode": recipientCurrencyCode,
      if(senderCurrencyCode != null) "senderCurrencyCode": senderCurrencyCode,
    };
  }

  factory GiftProduct.fromJson(Map<String, dynamic> json){
    return GiftProduct(
      redeemInstruction: json["redeemInstruction"] != null? RedeemInstruction.fromJson(json["redeemInstruction"]) : null,
      recipientCurrencyCode: json["recipientCurrencyCode"],
      senderCurrencyCode: json["senderCurrencyCode"],
      brand: json["brand"] != null? GiftBrand.fromJson(json["brand"]) : null,
      senderFee: json["senderFee"],
      country: json["country"] != null? ReloadlyCountry.fromJson(json["country"]) : null,
      productId: json["productId"],
      category: json["category"] != null? GiftCategory.fromJson(json["category"]) : null,
      denominationType: json["denominationType"],
      discountPercentage: json["discountPercentage"],
      fixedRecipientDenominations: json["fixedRecipientDenominations"],
      fixedRecipientToSenderDenominationsMap: json["fixedRecipientToSenderDenominationsMap"],
      fixedSenderDenominations: json["fixedSenderDenominations"],
      global: json["global"],
      logoUrls: json["logoUrls"],
      maxRecipientDenomination: json["maxRecipientDenomination"],
      maxSenderDenomination: json["maxSenderDenomination"],
      minRecipientDenomination: json["minRecipientDenomination"],
      minSenderDenomination: json["minSenderDenomination"],
      productName: json["productName"],
      supportsPreOrder: json["supportsPreOrder"],
      senderFeePercentage: json["senderFeePercentage"],
    );
  }
}

class FxRate{
  double? recipientAmount;
  String? recipientCurrency;
  double? senderAmount;
  String? senderCurrency;

  FxRate({
    this.recipientAmount,
    this.recipientCurrency,
    this.senderAmount,
    this.senderCurrency
  });

  factory FxRate.fromJson(Map<String, dynamic> json){
    return FxRate(
      senderAmount: json["senderAmount"],
      senderCurrency: json["senderCurrency"],
      recipientAmount: json["recipientAmount"],
      recipientCurrency: json["recipientCurrency"],
    );
  }

}
class PrudBalance{
  double amount;
  String currency;

  PrudBalance({
    required this.amount,
    required this.currency,
  });

  factory PrudBalance.fromJson(Map<String, dynamic> json){
    return PrudBalance(amount: json['amount'], currency: json['currency']);
  }
}

class ReloadlyCountry {
  List<String>? callingCodes;
  String? continent;
  String? currencyCode;
  String? currencyName;
  String? currencySymbol;
  String? flag;
  String? flagUrl;
  String? isoName;
  String? name;

  ReloadlyCountry({
    this.callingCodes,
    this.continent,
    this.currencyCode,
    this.currencyName,
    this.name,
    this.currencySymbol,
    this.flag,
    this.isoName,
    this.flagUrl,
  });

  Map<String, dynamic> toJson(){
    return {
      if(name != null) "name": name,
      if(isoName != null) "isoName": isoName,
      if(flag != null) "flag": flag,
      if(currencyName != null) "currencyName": currencyName,
      if(currencyCode != null) "currencyCode": currencyCode,
      if(continent != null) "continent": continent,
      if(callingCodes != null) "callingCodes": callingCodes,
      if(currencySymbol != null) "currencySymbol": currencySymbol,
      if(flagUrl != null) "flagUrl": flagUrl,
    };
  }

  factory ReloadlyCountry.fromJson(Map<String, dynamic> json){
    return ReloadlyCountry(
      name: json["name"],
      callingCodes: json["callingCodes"],
      flag: json["flag"],
      isoName: json["isoName"],
      currencyName: json["currencyName"],
      currencyCode: json["currencyCode"],
      continent: json["continent"],
      currencySymbol: json["currencySymbol"],
      flagUrl: json["flagUrl"],
    );
  }
}

class GiftCategory{
  int? id;
  String? name;

  GiftCategory({this.id, this.name});

  Map<String, dynamic> toJson(){
    return {
      if(name != null) "name": name,
      if(id != null) "id": id
    };
  }

  factory GiftCategory.fromJson(Map<String, dynamic> json){
    return GiftCategory(
      name: json["name"],
      id: json["id"]
    );
  }
}