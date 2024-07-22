import 'package:country_picker/country_picker.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
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
  String? cardNumber;
  String? pinCode;

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
  });

  Map<String, dynamic> toJson(){
    return {
      "productId": productId,
      "quantity": quantity,
      "senderName": senderName,
      "unitPrice": unitPrice,
      "customIdentifier": tabData.getRandomString(18),
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
  double? commissionFromReloadly;
  double? customerGot;
  double? referralsGot;
  double? income;
  DateTime? transDate;
  String? referralId;
  double? referralCommission;
  String? installReferralId;
  double? installReferralCommission;
  double? profitForPrudapp;
  String? transCurrency;
  bool? refunded;
  Beneficiary? beneficiary;
  double? transactionCost;
  double? transactionCostInSelected;
  double? transactionPaid;
  double? transactionPaidInSelected;
  String? selectedCurrencyCode;
  String? productPhoto;

  GiftTransactionDetails({
    this.transId,
    this.id,
    this.affId,
    this.income,
    this.installReferralCommission,
    this.installReferralId,
    this.profitForPrudapp,
    this.referralCommission,
    this.referralId,
    this.transCurrency,
    this.transDate,
    this.refunded,
    this.beneficiary,
    this.transactionCost,
    this.transactionPaid,
    this.selectedCurrencyCode,
    this.transactionCostInSelected,
    this.transactionPaidInSelected,
    this.commissionFromReloadly,
    this.customerGot,
    this.referralsGot,
    this.productPhoto,
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(affId != null) "aff_id": affId,
      if(transDate != null) "trans_date": transDate!.toIso8601String(),
      if(transCurrency != null) "trans_currency": transCurrency,
      if(referralId != null) "referral_id": referralId,
      if(referralCommission != null) "referral_commission": referralCommission,
      if(profitForPrudapp != null) "profit_for_prudapp": profitForPrudapp,
      if(installReferralId != null) "install_referral_id": installReferralId,
      if(installReferralCommission != null) "install_referral_commission": installReferralCommission,
      if(income != null) "income": income,
      if(referralsGot != null) "referrals_got": referralsGot,
      if(commissionFromReloadly != null) "commission_from_reloadly": commissionFromReloadly,
      if(customerGot != null) "customer_got": customerGot,
      if(transId != null) "trans_id": transId,
      if(refunded != null) "refunded": refunded,
      if(beneficiary != null) "beneficiary": beneficiary!.fullName,
      if(transactionPaid != null) "transaction_paid": transactionPaid,
      if(transactionCost != null) "transaction_cost": transactionCost,
      if(transactionCostInSelected != null) "transaction_cost_in_selected": transactionCostInSelected,
      if(transactionPaidInSelected != null) "transaction_paid_in_selected": transactionPaidInSelected,
      if(selectedCurrencyCode != null) "selected_currency_code": selectedCurrencyCode,
      if(productPhoto != null) "product_photo": productPhoto,
    };
  }

  Beneficiary? getBeneficiary(String fullname){
    if(beneficiaryNotifier.myBeneficiaries.isNotEmpty){
      return beneficiaryNotifier.myBeneficiaries.firstWhere((ben) => ben.fullName == fullname);
    } else{
      return null;
    }
  }

  factory GiftTransactionDetails.fromJson(Map<String, dynamic> json){
    Beneficiary? ben = GiftTransactionDetails().getBeneficiary(json["beneficiary"]);
    return GiftTransactionDetails(
      id: json["id"],
      income: json["income"],
      installReferralCommission: json["install_referral_commission"],
      installReferralId: json["install_referral_id"],
      profitForPrudapp: json["profit_for_prudapp"],
      referralsGot: json["referrals_got"],
      commissionFromReloadly: json["commission_from_reloadly"],
      customerGot: json["customer_got"],
      referralCommission: json["referral_commission"],
      transCurrency: json["trans_currency"],
      referralId: json["referral_id"],
      transDate: json["trans_date"] != null? DateTime.tryParse(json["trans_date"]) : null,
      affId: json["aff_id"],
      transId: json["trans_id"],
      beneficiary: ben,
      transactionCost: json["transaction_cost"],
      transactionPaid: json["transaction_paid"],
      transactionCostInSelected: json["transaction_cost_in_selected"],
      transactionPaidInSelected: json["transaction_paid_in_selected"],
      selectedCurrencyCode: json["selected_currency_code"],
      refunded: json["refunded"],
      productPhoto: json["product_photo"]
    );
  }
}

class RechargeTransactionDetails{
  String? id;
  String? affId;
  int? transId;
  double? commissionFromReloadly;
  double? customerGot;
  double? referralsGot;
  double? income;
  DateTime? transDate;
  String? referralId;
  double? referralCommission;
  String? installReferralId;
  double? installReferralCommission;
  double? profitForPrudapp;
  String? transCurrency;
  bool? refunded;
  Beneficiary? beneficiaryNo;
  double? transactionCost;
  double? transactionCostInSelected;
  double? transactionPaid;
  double? transactionPaidInSelected;
  String? selectedCurrencyCode;
  String? providerPhoto;
  String? transactionType;

  RechargeTransactionDetails({
    this.transId,
    this.id,
    this.affId,
    this.income,
    this.installReferralCommission,
    this.installReferralId,
    this.profitForPrudapp,
    this.referralCommission,
    this.referralId,
    this.transCurrency,
    this.transDate,
    this.refunded,
    this.beneficiaryNo,
    this.transactionCost,
    this.transactionPaid,
    this.selectedCurrencyCode,
    this.transactionCostInSelected,
    this.transactionPaidInSelected,
    this.commissionFromReloadly,
    this.customerGot,
    this.referralsGot,
    this.providerPhoto,
    this.transactionType,
  });

  Map<String, dynamic> toJson(){
    return {
      if(id != null) "id": id,
      if(affId != null) "aff_id": affId,
      if(transDate != null) "trans_date": transDate!.toIso8601String(),
      if(transCurrency != null) "trans_currency": transCurrency,
      if(referralId != null) "referral_id": referralId,
      if(referralCommission != null) "referral_commission": referralCommission,
      if(profitForPrudapp != null) "profit_for_prudapp": profitForPrudapp,
      if(installReferralId != null) "install_referral_id": installReferralId,
      if(installReferralCommission != null) "install_referral_commission": installReferralCommission,
      if(income != null) "income": income,
      if(referralsGot != null) "referrals_got": referralsGot,
      if(commissionFromReloadly != null) "commission_from_reloadly": commissionFromReloadly,
      if(customerGot != null) "customer_got": customerGot,
      if(transId != null) "trans_id": transId,
      if(refunded != null) "refunded": refunded,
      if(beneficiaryNo != null) "beneficiary_no": beneficiaryNo,
      if(transactionPaid != null) "transaction_paid": transactionPaid,
      if(transactionCost != null) "transaction_cost": transactionCost,
      if(transactionCostInSelected != null) "transaction_cost_in_selected": transactionCostInSelected,
      if(transactionPaidInSelected != null) "transaction_paid_in_selected": transactionPaidInSelected,
      if(selectedCurrencyCode != null) "selected_currency_code": selectedCurrencyCode,
      if(providerPhoto != null) "provider_photo": providerPhoto,
      if(transactionType != null) "transaction_type": transactionType,
    };
  }

  factory RechargeTransactionDetails.fromJson(Map<String, dynamic> json){
    return RechargeTransactionDetails(
        id: json["id"],
        income: json["income"],
        installReferralCommission: json["install_referral_commission"],
        installReferralId: json["install_referral_id"],
        profitForPrudapp: json["profit_for_prudapp"],
        referralsGot: json["referrals_got"],
        commissionFromReloadly: json["commission_from_reloadly"],
        customerGot: json["customer_got"],
        referralCommission: json["referral_commission"],
        transCurrency: json["trans_currency"],
        referralId: json["referral_id"],
        transDate: json["trans_date"] != null? DateTime.tryParse(json["trans_date"]) : null,
        affId: json["aff_id"],
        transId: json["trans_id"],
        beneficiaryNo: json["beneficiary_no"],
        transactionCost: json["transaction_cost"],
        transactionPaid: json["transaction_paid"],
        transactionCostInSelected: json["transaction_cost_in_selected"],
        transactionPaidInSelected: json["transaction_paid_in_selected"],
        selectedCurrencyCode: json["selected_currency_code"],
        refunded: json["refunded"],
        providerPhoto: json["provider_photo"],
        transactionType: json["transaction_type"],
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
  String? productPhoto;

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
    this.beneficiary,
    this.productPhoto,
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
      if(productPhoto != null) "productPhoto": productPhoto,
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
      productPhoto: json["productPhoto"],
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
  int? brandId;
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
  List<dynamic>? callingCodes;
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

class OperatorCountry{
  String? name;
  String? isoName;

  OperatorCountry({this.isoName, this.name});

  Map<String, dynamic> toJson(){
    return {
      if(name != null) "name": name,
      if(isoName != null) "isoName": isoName
    };
  }

  factory OperatorCountry.fromJson(Map<String, dynamic> json){
    return OperatorCountry(
      name: json["name"],
      isoName: json["isoName"]
    );
  }
}

class RechargeFee{
  double? international;
  double? internationalPercentage;
  double? local;
  double? localPercentage;


  RechargeFee({
    this.international,
    this.internationalPercentage,
    this.local,
    this.localPercentage,
  });

  Map<String, dynamic> toJson(){
    return {
      if(international != null) "international": international,
      if(internationalPercentage != null) "internationalPercentage": internationalPercentage,
      if(local != null) "local": local,
      if(localPercentage != null) "localPercentage": localPercentage,
    };
  }

  factory RechargeFee.fromJson(Map<String, dynamic> json){
    return RechargeFee(
      international: json["international"],
      internationalPercentage: json["internationalPercentage"],
      local: json["local"],
      localPercentage: json["localPercentage"]
    );
  }
}

class OperatorFx{
  String? currencyCode;
  double? fxRate;
  String? name;
  String? id;

  OperatorFx({
    this.currencyCode,
    this.fxRate,
    this.name,
    this.id,
  });

  Map<String, dynamic> toJson(){
    return {
      if(currencyCode != null) "currencyCode": currencyCode,
      if(fxRate != null) "fxRate": fxRate,
      if(id != null) "id": id,
      if(name != null) "name": name,
    };
  }

  factory OperatorFx.fromJson(Map<String, dynamic> json){
    return OperatorFx(
      currencyCode: json["currencyCode"],
      fxRate: json["fxRate"],
      id: json["id"],
      name: json["name"],
    );
  }
}

class RechargeFx{
  String? currencyCode;
  double? rate;


  RechargeFx({
    this.currencyCode,
    this.rate,
  });

  Map<String, dynamic> toJson(){
    return {
      if(currencyCode != null) "currencyCode": currencyCode,
      if(rate != null) "rate": rate,
    };
  }

  factory RechargeFx.fromJson(Map<String, dynamic> json){
    return RechargeFx(
      currencyCode: json["currencyCode"],
      rate: json["rate"],
    );
  }
}

class PhoneNo{
  String? countryCode;
  int? number;

  PhoneNo({
    this.countryCode,
    this.number,
  });

  Map<String, dynamic> toJson(){
    return {
      if(countryCode != null) "countryCode": countryCode,
      if(number != null) "number": number,
    };
  }

  factory PhoneNo.fromJson(Map<String, dynamic> json){
    return PhoneNo(
      countryCode: json["countryCode"],
      number: json["number"],
    );
  }
}

class RechargeOperator{
  int? id;
  String? name;
  bool? bundle;
  bool? comboProduct;
  double? commission;
  OperatorCountry? country;
  bool? data;
  String? denominationType;
  String? destinationCurrencyCode;
  String? destinationCurrencySymbol;
  RechargeFee? fees;
  List<dynamic>? fixedAmounts;
  Map<String, dynamic>? fixedAmountsDescriptions;
  RechargeFx? fx;
  double? internationalDiscount;
  double? localDiscount;
  List<dynamic>? localFixedAmounts;
  Map<String, dynamic>? localFixedAmountsDescriptions;
  double? localMaxAmount;
  double? localMinAmount;
  List<dynamic>? logoUrls;
  double? maxAmount;
  double? minAmount;
  double? mostPopularAmount;
  int? operatorId;
  bool? pin;
  List<OperatorPromotion>? promotions;
  String? senderCurrencyCode;
  String? senderCurrencySymbol;
  List<dynamic>? suggestedAmounts;
  Map<String, dynamic>? suggestedAmountsMap;
  bool? supportsLocalAmounts;
  String? status;


  RechargeOperator({
    this.id, 
    this.name,
    this.data,
    this.denominationType,
    this.country,
    this.logoUrls,
    this.bundle, 
    this.comboProduct,
    this.commission,
    this.destinationCurrencyCode,
    this.destinationCurrencySymbol,
    this.fees,
    this.fixedAmounts,
    this.fixedAmountsDescriptions,
    this.fx,
    this.internationalDiscount,
    this.localDiscount,
    this.localFixedAmounts,
    this.localFixedAmountsDescriptions,
    this.localMaxAmount,
    this.localMinAmount,
    this.maxAmount,
    this.minAmount,
    this.mostPopularAmount,
    this.operatorId, 
    this.pin,
    this.promotions,
    this.senderCurrencyCode,
    this.senderCurrencySymbol,
    this.suggestedAmounts,
    this.suggestedAmountsMap,
    this.supportsLocalAmounts,
    this.status
  });

  Map<String, dynamic> toJson(){
    return {
      if(name != null) "name": name,
      if(id != null) "id": id,
      if(supportsLocalAmounts != null) "supportsLocalAmounts": supportsLocalAmounts,
      if(suggestedAmountsMap != null) "suggestedAmountsMap": suggestedAmountsMap,
      if(suggestedAmounts != null) "suggestedAmounts": suggestedAmounts,
      if(senderCurrencySymbol != null) "senderCurrencySymbol": senderCurrencySymbol,
      if(senderCurrencyCode != null) "senderCurrencyCode": senderCurrencyCode,
      if(promotions != null) "promotions": promotions!.map((promo) => promo.toJson()).toList(),
      if(pin != null) "pin": pin,
      if(operatorId != null) "operatorId": operatorId,
      if(mostPopularAmount != null) "mostPopularAmount": mostPopularAmount,
      if(minAmount != null) "minAmount": minAmount,
      if(maxAmount != null) "maxAmount": maxAmount,
      if(logoUrls != null) "logoUrls": logoUrls,
      if(localMinAmount != null) "localMinAmount": localMinAmount,
      if(localMaxAmount != null) "localMaxAmount": localMaxAmount,
      if(localFixedAmountsDescriptions != null) "localFixedAmountsDescriptions": localFixedAmountsDescriptions,
      if(localFixedAmounts != null) "localFixedAmounts": localFixedAmounts,
      if(localDiscount != null) "localDiscount": localDiscount,
      if(internationalDiscount != null) "internationalDiscount": internationalDiscount,
      if(fx != null) "fx": fx!.toJson(),
      if(fixedAmountsDescriptions != null) "fixedAmountsDescriptions": fixedAmountsDescriptions,
      if(fixedAmounts != null) "fixedAmounts": fixedAmounts,
      if(fees != null) "fees": fees!.toJson(),
      if(destinationCurrencySymbol != null) "destinationCurrencySymbol": destinationCurrencySymbol,
      if(destinationCurrencyCode != null) "destinationCurrencyCode": destinationCurrencyCode,
      if(denominationType != null) "denominationType": denominationType,
      if(data != null) "data": data,
      if(country != null) "country": country!.toJson(),
      if(commission != null) "commission": commission,
      if(comboProduct != null) "comboProduct": comboProduct,
      if(bundle != null) "bundle": bundle,
      if(status != null) "status": status,
    };
  }

  factory RechargeOperator.fromJson(Map<String, dynamic> json){
    return RechargeOperator(
      name: json["name"],
      id: json["id"],
      supportsLocalAmounts: json["supportsLocalAmounts"],
      suggestedAmountsMap: json["suggestedAmountsMap"],
      suggestedAmounts: json["suggestedAmounts"],
      senderCurrencySymbol: json["senderCurrencySymbol"],
      senderCurrencyCode: json["senderCurrencyCode"],
      promotions: json["promotions"] != null && json["promotions"].isNotEmpty? json["promotions"].map(
        (promo) => OperatorPromotion.fromJson(promo)
      ).toList() : [],
      pin: json["pin"],
      operatorId: json["operatorId"],
      mostPopularAmount: json["mostPopularAmount"] is int? json["mostPopularAmount"].toDouble() : json["mostPopularAmount"],
      minAmount: json["minAmount"] is int? json["minAmount"].toDouble() : json["minAmount"],
      maxAmount: json["maxAmount"] is int? json["maxAmount"].toDouble() : json["maxAmount"],
      logoUrls: json["logoUrls"],
      localMinAmount: json["localMinAmount"] is int? json["localMinAmount"].toDouble() : json["localMinAmount"],
      localMaxAmount: json["localMaxAmount"] is int? json["localMaxAmount"].toDouble() : json["localMaxAmount"],
      localFixedAmountsDescriptions: json["localFixedAmountsDescriptions"],
      localFixedAmounts: json["localFixedAmounts"],
      localDiscount: json["localDiscount"],
      internationalDiscount: json["internationalDiscount"],
      fx: json["fx"] != null? RechargeFx.fromJson(json["fees"]) : null,
      fixedAmountsDescriptions: json["fixedAmountsDescriptions"],
      fixedAmounts: json["fixedAmounts"],
      status: json["status"],
      fees: json["fees"] != null? RechargeFee.fromJson(json["fees"]) : null,
      destinationCurrencySymbol: json["destinationCurrencySymbol"],
      destinationCurrencyCode: json["destinationCurrencyCode"],
      denominationType: json["denominationType"],
      data: json["data"],
      country: json["country"] != null? OperatorCountry.fromJson(json["country"]) : null,
      commission: json["commission"],
      comboProduct: json["comboProduct"],
      bundle: json["bundle"],
    );
  }
}

class OperatorCommission{
  RechargeOperator? operator;
  double? internationalPercentage;
  double? localPercentage;
  double? percentage;
  String? updatedAt;

  OperatorCommission({
    this.operator,
    this.localPercentage,
    this.internationalPercentage,
    this.percentage,
    this.updatedAt,
  });

  Map<String, dynamic> toJson(){
    return {
      if(operator != null) "operator": operator!.toJson(),
      if(localPercentage != null) "localPercentage": localPercentage,
      if(internationalPercentage != null) "internationalPercentage": internationalPercentage,
      if(percentage != null) "percentage": percentage,
      if(updatedAt != null) "updatedAt": updatedAt,
    };
  }

  factory OperatorCommission.fromJson(Map<String, dynamic> json){
    return OperatorCommission(
      operator: json["operator"] != null? RechargeOperator.fromJson(json["operator"]) : null,
      internationalPercentage: json["internationalPercentage"],
      percentage: json["percentage"],
      localPercentage: json["localPercentage"],
      updatedAt: json["updatedAt"],
    );
  }
}

class OperatorPromotion{
  String? denominations;
  String? description;
  String? endDate;
  String? localDenominations;
  int? operatorId;
  int? promotionId;
  String? startDate;
  String? title1;
  String? title2;

  OperatorPromotion({
    this.operatorId,
    this.denominations,
    this.description,
    this.endDate,
    this.localDenominations,
    this.promotionId,
    this.startDate,
    this.title1,
    this.title2
  });

  Map<String, dynamic> toJson(){
    return {
      if(operatorId != null) "operatorId": operatorId,
      if(denominations != null) "denominations": denominations,
      if(description != null) "description": description,
      if(endDate != null) "endDate": endDate,
      if(localDenominations != null) "localDenominations": localDenominations,
      if(promotionId != null) "promotionId": promotionId,
      if(startDate != null) "startDate": startDate,
      if(title1 != null) "percentage": title1,
      if(title2 != null) "updatedAt": title2,
    };
  }

  factory OperatorPromotion.fromJson(Map<String, dynamic> json){
    return OperatorPromotion(
      operatorId: json["operatorId"] ,
      denominations: json["denominations"],
      description: json["description"],
      endDate: json["endDate"],
      localDenominations: json["localDenominations"],
      promotionId: json["promotionId"],
      startDate: json["startDate"],
      title1: json["title1"],
      title2: json["title2"],
    );
  }
}

class TopUpOrder {
  String? recipientEmail;
  PhoneNo? recipientPhone;
  PhoneNo? senderPhone;
  bool? useLocalAmount;
  int? operatorId;
  String? customIdentifier;
  double? amount;

  TopUpOrder({
    this.operatorId,
    this.recipientEmail,
    this.recipientPhone,
    this.senderPhone,
    this.useLocalAmount,
    this.amount,
    this.customIdentifier,
  });

  Map<String, dynamic> toJson(){
    return {
      if(operatorId != null) "operatorId": operatorId,
      if(recipientEmail != null) "recipientEmail": recipientEmail,
      if(recipientPhone != null) "recipientPhone": recipientPhone!.toJson(),
      if(senderPhone != null) "senderPhone": senderPhone!.toJson(),
      if(useLocalAmount != null) "useLocalAmount": useLocalAmount,
      if(amount != null) "amount": amount,
      "customIdentifier": tabData.getRandomString(18),
    };
  }

  factory TopUpOrder.fromJson(Map<String, dynamic> json){
    return TopUpOrder(
      operatorId: json["operatorId"] ,
      useLocalAmount: json["useLocalAmount"],
      senderPhone: json["senderPhone"] != null? PhoneNo.fromJson(json["senderPhone"])  : null,
      recipientPhone: json["recipientPhone"] != null? PhoneNo.fromJson(json["recipientPhone"]) : null,
      recipientEmail: json["recipientEmail"],
      amount: json["amount"],
      customIdentifier: json["customIdentifier"],
    );
  }
}

class PinDetail{
  int? code;
  String? info;
  String? ivr;
  int? serial;
  int? validity;
  String? value;


  PinDetail({
    this.value,
    this.validity,
    this.serial,
    this.ivr,
    this.info,
    this.code,
  });

  Map<String, dynamic> toJson(){
    return {
      if(value != null) "value": value,
      if(validity != null) "validity": validity,
      if(serial != null) "serial": serial,
      if(ivr != null) "ivr": ivr,
      if(info != null) "info": info,
      if(code != null) "code": code,
    };
  }

  factory PinDetail.fromJson(Map<String, dynamic> json){
    return PinDetail(
      value: json["value"] ,
      validity: json["validity"],
      serial: json["serial"],
      ivr: json["ivr"],
      info: json["info"],
      code: json["code"],
    );
  }
}

class TopUpTransaction {
  String? countryCode;
  String? customIdentifier;
  double? deliveredAmount;
  String? deliveredAmountCurrencyCode;
  int? operatorId;
  String? discountCurrencyCode;
  double? discount;
  double? fee;
  String? operatorName;
  String? operatorTransactionId;
  int? recipientPhone;
  double? requestedAmount;
  String? requestedAmountCurrencyCode;
  String? senderPhone;
  String? status;
  String? transactionDate;
  int? transactionId;
  PinDetail? pinDetail;

  TopUpTransaction({
    this.operatorId,
    this.countryCode,
    this.customIdentifier,
    this.deliveredAmount,
    this.deliveredAmountCurrencyCode,
    this.discount,
    this.discountCurrencyCode,
    this.fee,
    this.operatorName,
    this.status,
    this.transactionId,
    this.operatorTransactionId,
    this.pinDetail,
    this.recipientPhone,
    this.requestedAmount,
    this.requestedAmountCurrencyCode,
    this.senderPhone,
    this.transactionDate
  });

  Map<String, dynamic> toJson(){
    return {
      if(operatorId != null) "operatorId": operatorId,
      if(deliveredAmount != null) "deliveredAmount": deliveredAmount,
      if(countryCode != null) "countryCode": countryCode,
      if(deliveredAmountCurrencyCode != null) "deliveredAmountCurrencyCode": deliveredAmountCurrencyCode,
      if(discountCurrencyCode != null) "discountCurrencyCode": discountCurrencyCode,
      if(discount != null) "discount": discount,
      if(fee != null) "fee": fee,
      if(operatorName != null) "operatorName": operatorName,
      if(customIdentifier != null) "customIdentifier": customIdentifier,
      if(operatorTransactionId != null) "operatorTransactionId": operatorTransactionId,
      if(recipientPhone != null) "recipientPhone": recipientPhone,
      if(requestedAmount != null) "requestedAmount": requestedAmount,
      if(requestedAmountCurrencyCode != null) "requestedAmountCurrencyCode": requestedAmountCurrencyCode,
      if(senderPhone != null) "senderPhone": senderPhone,
      if(status != null) "status": status,
      if(transactionDate != null) "transactionDate": transactionDate,
      if(transactionId != null) "transactionId": transactionId,
      if(pinDetail != null) "pinDetail": pinDetail!.toJson(),
    };
  }

  factory TopUpTransaction.fromJson(Map<String, dynamic> json){
    return TopUpTransaction(
      operatorId: json["operatorId"] ,
      countryCode: json["countryCode"],
      deliveredAmount: json["deliveredAmount"],
      deliveredAmountCurrencyCode: json["deliveredAmountCurrencyCode"],
      discountCurrencyCode: json["discountCurrencyCode"],
      discount: json["discount"],
      fee: json["fee"],
      operatorName: json["operatorName"],
      customIdentifier: json["customIdentifier"],
      status: json["status"] ,
      transactionId: json["transactionId"],
      operatorTransactionId: json["operatorTransactionId"],
      recipientPhone: json["recipientPhone"],
      requestedAmount: json["requestedAmount"],
      requestedAmountCurrencyCode: json["requestedAmountCurrencyCode"],
      senderPhone: json["senderPhone"],
      transactionDate: json["transactionDate"],
      pinDetail: json["pinDetail"] != null? PinDetail.fromJson(json["pinDetail"]) : null,
    );
  }
}

class TransactionStatus{
  String? code;
  String? message;
  String? status;


  TransactionStatus({
    this.status,
    this.message,
    this.code,
  });

  Map<String, dynamic> toJson(){
    return {
      if(message != null) "message": message,
      if(status != null) "status": status,
      if(code != null) "code": code,
    };
  }

  factory TransactionStatus.fromJson(Map<String, dynamic> json){
    return TransactionStatus(
      message: json["message"] ,
      status: json["status"],
      code: json["code"],
    );
  }
}