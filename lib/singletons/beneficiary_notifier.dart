
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../models/reloadly.dart';

class BeneficiaryNotifier extends ChangeNotifier {
  static final BeneficiaryNotifier _beneficiaryNotifier = BeneficiaryNotifier._internal();
  static get beneficiaryNotifier => _beneficiaryNotifier;

  factory BeneficiaryNotifier(){
    return _beneficiaryNotifier;
  }

  List<Beneficiary> selectedBeneficiaries = [];
  List<Beneficiary> myBeneficiaries = [];

  void getAllFromCache(){
    dynamic bensCache = myStorage.getFromStore(key: "myBeneficiaries");
    dynamic selectedBensCache = myStorage.getFromStore(key: "selectedBeneficiaries");
    myBeneficiaries.clear();
    selectedBeneficiaries.clear();
    if(bensCache != null && bensCache.isNotEmpty){
      for (dynamic ben in bensCache) {
        myBeneficiaries.add(Beneficiary.fromJson(ben));
      }
    }
    if(selectedBensCache != null && selectedBensCache.isNotEmpty){
      for (dynamic ben in selectedBensCache) {
        selectedBeneficiaries.add(Beneficiary.fromJson(ben));
      }
    }
  }

  Future<void> saveToCache({bool isSelected = true}) async {
    List<Beneficiary> bens = [];
    List<Map<String, dynamic>> bensCache = [];
    String? storeField;
    if(isSelected) {
      bens = selectedBeneficiaries;
      storeField = "selectedBeneficiaries";
    } else {
      bens = myBeneficiaries;
      storeField = "myBeneficiaries";
    }
    if(bens.isNotEmpty){
      for(Beneficiary ben in bens){
        bensCache.add(ben.toJson());
      }
      await myStorage.addToStore(key: storeField, value: bensCache);
    }
  }

  Future<void> addBeneficiary(Beneficiary ben, {bool isSelected = true}) async {
    if(isSelected) {
      selectedBeneficiaries.add(ben);
    } else {
      myBeneficiaries.add(ben);
    }
    await saveToCache(isSelected: isSelected);
    notifyListeners();
  }

  Future<void> removeBeneficiary(Beneficiary ben, {bool isSelected = true}) async {
    if(isSelected) {
      selectedBeneficiaries.remove(ben);
    } else {
      myBeneficiaries.remove(ben);
    }
    await saveToCache(isSelected: isSelected);
    notifyListeners();
  }

  Future<void> selectAll() async {
    selectedBeneficiaries = myBeneficiaries;
    await saveToCache(isSelected: true);
    notifyListeners();
  }

  Future<void> removeAll() async {
    selectedBeneficiaries = [];
    await saveToCache(isSelected: true);
    notifyListeners();
  }

  Future<void> initBens() async {
    try{
      getAllFromCache();
      notifyListeners();
    }catch(ex){
      debugPrint("BeneficiaryNotifier_initBens Error: $ex");
    }
  }

  BeneficiaryNotifier._internal();
}

final beneficiaryNotifier = BeneficiaryNotifier();
