
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/bus_models.dart';
import '../models/user.dart';
import 'currency_math.dart';
import 'influencer_notifier.dart';

class BusNotifier extends ChangeNotifier {
  static final BusNotifier _busNotifier = BusNotifier._internal();
  static get busNotifier => _busNotifier;

  factory BusNotifier(){
    return _busNotifier;
  }

  BusBrand? busBrand;
  bool showFloatingButton = true;
  String? busBrandId;
  String? busOperatorId;
  String? busDriverId;
  bool isActive = false;
  String? busBrandRole;
  BusDetail? selectedBus;
  DriverDetails? selectedDriver;
  BusImage? selectedBusImage;
  BusSeat? selectedBusSeat;
  BusFeature? selectedBusFeature;
  OperatorDetails? selectedOperator;
  List<String> roles = ["ADMIN", "DRIVER", "SUPER"];
  List<String> statuses = ["Bad", "Good", "Very Good", "Excellent"];
  List<String> seatTypes = ["Economy", "Business", "Executive"];
  List<String> driverRanks = ["Junior", "Senior"];
  List<OperatorDetails> operatorDetails = [];
  List<DriverDetails> driverDetails = [];
  List<BusDetail> busDetails = [];
  List<String> busTypes = ["Luxurious Bus", "18 Seater", "J5", "14 Seater", "Sienna", "Others"];
  List<JourneyWithBrand> brandPendingJourneys = [];
  List<JourneyWithBrand> brandCompletedJourneys = [];
  List<JourneyWithBrand> brandActiveJourneys = [];
  List<JourneyWithBrand> brandBoardingJourneys = [];
  List<JourneyWithBrand> brandHaltedJourneys = [];
  List<JourneyWithBrand> brandHaltedBoardingJourneys = [];
  List<JourneyWithBrand> brandCancelledJourneys = [];
  Journey? selectedJourney;


  void updateSelectedJourney(Journey jy){
    selectedJourney = jy;
    notifyListeners();
  }


  void updateSelectedOperator(OperatorDetails op){
    selectedOperator = op;
    notifyListeners();
  }

  void updateSelectedBus(BusDetail bu){
    selectedBus = bu;
    notifyListeners();
  }

  void updateSelectedDriver(DriverDetails dd){
    selectedDriver = dd;
    notifyListeners();
  }

  void updateSelectedBusSeat(BusSeat bs){
    selectedBusSeat = bs;
    notifyListeners();
  }

  void updateSelectedBusFeature(BusFeature bf){
    selectedBusFeature = bf;
    notifyListeners();
  }

  void updateSelectedBusImage(BusImage bi){
    selectedBusImage = bi;
    notifyListeners();
  }

  void updateShowFloatButton(bool status){
    showFloatingButton = status;
    notifyListeners();
  }

  void getDefaultSettings(){
    busOperatorId = myStorage.getFromStore(key: "busOperatorId");
    busDriverId = myStorage.getFromStore(key: "busDriverId");
    busBrandId = myStorage.getFromStore(key: "busBrandId");
    isActive = myStorage.getFromStore(key: "isActive")?? false;
    busBrandRole = myStorage.getFromStore(key: "busBrandRole");
  }


  Future<void> saveDefaultSettings() async {
    if(busOperatorId != null) await myStorage.addToStore(key: "busOperatorId", value: busOperatorId);
    if(busDriverId != null) await myStorage.addToStore(key: "busDriverId", value: busDriverId);
    if(busBrandId != null) await myStorage.addToStore(key: "busBrandId", value: busBrandId);
    await myStorage.addToStore(key: "isActive", value: isActive);
    if(busBrandRole != null) await myStorage.addToStore(key: "busBrandRole", value: busBrandRole);
  }

  Future<void> saveOperatorDetailsToCache() async {
    List<Map<String, dynamic>> items = operatorDetails.map((od) => od.toJson()).toList();
    await myStorage.addToStore(key: "operatorDetails", value: items);
  }

  Future<void> saveDriverDetailsToCache() async {
    List<Map<String, dynamic>> items = driverDetails.map((od) => od.toJson()).toList();
    await myStorage.addToStore(key: "driverDetails", value: items);
  }

  Future<void> saveBusDetailsToCache() async {
    List<Map<String, dynamic>> items = busDetails.map((od) => od.toJson()).toList();
    await myStorage.addToStore(key: "busDetails", value: items);
  }

  void getDriverDetailsFromCache() async {
    List<dynamic>? items = myStorage.getFromStore(key: "driverDetails");
    if(items != null){
      driverDetails = items.map<DriverDetails>((dynamic od) => DriverDetails.fromJson(od)).toList();
    }
  }

  void getOperatorDetailsFromCache() async {
    List<dynamic>? items = myStorage.getFromStore(key: "operatorDetails");
    if(items != null){
      operatorDetails = items.map<OperatorDetails>((dynamic od) => OperatorDetails.fromJson(od)).toList();
    }
  }

  void getBusDetailsFromCache() async {
    List<dynamic>? items = myStorage.getFromStore(key: "busDetails");
    if(items != null){
      busDetails = items.map<BusDetail>((dynamic od) => BusDetail.fromJson(od)).toList();
    }
  }

  Future<void> addToOperatorDetails(OperatorDetails od) async {
    operatorDetails.add(od);
    await saveOperatorDetailsToCache();
  }

  Future<void> addToDriverDetails(DriverDetails dd) async {
    driverDetails.add(dd);
    await saveDriverDetailsToCache();
  }

  Future<BusBrandOperator?> createNewOperator(BusBrandOperator opr) async {
    String path = "operators/";
    dynamic res = await makeRequest(path: path, method: 1, data: opr.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandOperator opr = BusBrandOperator.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<Bus?> createNewBus(Bus bus) async {
    String path = "buses/";
    dynamic res = await makeRequest(path: path, method: 1, data: bus.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        Bus bu = Bus.fromJson(res);
        return bu;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<Journey?> createNewJourney(Journey journey) async {
    String path = "journeys/";
    debugPrint("Journey: ${journey.toJson()}");
    dynamic res = await makeRequest(path: path, method: 1, data: journey.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        Journey bu = Journey.fromJson(res);
        return bu;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<JourneyPassenger?> bookPassengerForJourney(JourneyPassenger newPassenger) async {
    String path = "journeys/${newPassenger.journeyId}/passengers/";
    dynamic res = await makeRequest(path: path, method: 1, data: newPassenger.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        JourneyPassenger jp = JourneyPassenger.fromJson(res);
        return jp;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusImage?> createBusImage(BusImage busImage) async {
    String path = "buses/${busImage.busId}/images/";
    dynamic res = await makeRequest(path: path, method: 1, data: busImage.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        BusImage bu = BusImage.fromJson(res);
        return bu;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusFeature?> createBusFeature(BusFeature busFeature) async {
    String path = "buses/${busFeature.busId}/features/";
    dynamic res = await makeRequest(path: path, method: 1, data: busFeature.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        BusFeature bu = BusFeature.fromJson(res);
        return bu;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusSeat?> createBusSeat(BusSeat busSeat) async {
    String path = "buses/${busSeat.busId}/seats/";
    dynamic res = await makeRequest(path: path, method: 1, data: busSeat.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        BusSeat bu = BusSeat.fromJson(res);
        return bu;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<void> getOperators() async {
    String path = "operators/brands/$busBrandId";
    List<BusBrandOperator> found = [];
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res.isNotEmpty){
        for(dynamic re in res){
          found.add(BusBrandOperator.fromJson(re));
        }
        if(found.isNotEmpty){
          List<OperatorDetails> results = [];
          for(BusBrandOperator bo in found){
            User? usr = await influencerNotifier.getInfluencerById(bo.affId);
            if(usr != null){
              results.add(OperatorDetails(op: bo, detail: usr));
            }
          }
          if(results.isNotEmpty) operatorDetails = results;
        }
        notifyListeners();
      }
    }
  }

  Future<void> getDrivers() async {
    String path = "operators/brands/$busBrandId/role";
    List<BusBrandOperator> found = [];
    dynamic res = await makeRequest(path: path, data: {"role": "DRIVER"});
    if(res != null && res != false){
      if(res.isNotEmpty){
        for(dynamic re in res){
          found.add(BusBrandOperator.fromJson(re));
        }
        if(found.isNotEmpty){
          List<DriverDetails> results = [];
          for(BusBrandOperator bo in found){
            BusBrandDriver? drive = await getDriverByOperatorId(bo.id!);
            if(drive != null){
              User? usr = await busNotifier.getDriverDetail(drive.id!);
              if(usr != null){
                results.add(DriverDetails(dr: drive, detail: usr));
              }
            }
          }
          if(results.isNotEmpty) {
            driverDetails = results;
            saveDriverDetailsToCache();
          }
        }
        notifyListeners();
      }
    }
  }

  Future<DriverDetails?> getDriverById(String drvId) async {
    String path = "drivers/$drvId";
    DriverDetails? details;
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res.isNotEmpty){
        BusBrandDriver? drive = BusBrandDriver.fromJson(res);
        User? usr = await busNotifier.getDriverDetail(drive.id!);
        if(usr != null){
          details = DriverDetails(dr: drive, detail: usr);
        }
      }
    }
    return details;
  }

  Future<void> getBusesFromCloud() async {
    if(busBrandId != null) {
      List<BusDetail> found = [];
      List<Bus>? buses = await getBrandBuses(busBrandId!);
      if (buses != null) {
        if (buses.isNotEmpty) {
          for (Bus bus in buses) {
            List<BusImage>? images = await getBusImagesViaId(bus.id!);
            List<BusSeat>? seats = await getBusSeatsViaId(bus.id!);
            List<BusFeature>? features = await getBusFeaturesViaId(bus.id!);
            if(images != null && features != null && seats != null){
              found.add(BusDetail(bus: bus, features: features, images: images, seats: seats));
            }
          }
          if (found.isNotEmpty) {
            busDetails = found;
            await saveBusDetailsToCache();
            notifyListeners();
          }
        }
      }
    }
  }

  Future<List<PassengerDetail>> getJourneyPassengersFromCloud(String journeyId, String busId) async {
    List<PassengerDetail> found = [];
    String path = "journeys/$journeyId/passengers";
    List<JourneyPassenger>? passengers;
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false) {
      if (res.isNotEmpty) {
        passengers = res.map<JourneyPassenger>((dynamic re) => JourneyPassenger.fromJson(re)).toList();
        if (passengers != null && passengers.isNotEmpty) {
          for (JourneyPassenger pas in passengers) {
            User? usr = await influencerNotifier.getInfluencerById(pas.affId);
            BusSeat? seat = await getBusSeatViaId(busId, pas.seatId );
            if(usr != null && seat != null){
              found.add(PassengerDetail(seat: seat, passenger: pas, user: usr));
            }
          }
        }
      }
    }
    return found;
  }

  Future<BusDetail?> getBusByIdFromCloud(String busId) async {
    String path = "buses/$busId";
    BusDetail? details;
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false) {
      if (res.isNotEmpty) {
        Bus? bus = Bus.fromJson(res);
        List<BusImage>? images = await getBusImagesViaId(bus.id!);
        List<BusSeat>? seats = await getBusSeatsViaId(bus.id!);
        List<BusFeature>? features = await getBusFeaturesViaId(bus.id!);
        if(images != null && features != null && seats != null){
          details = BusDetail(bus: bus, features: features, images: images, seats: seats);
        }
      }
    }
    return details;
  }

  Future<List<JourneyWithBrand>> getBrandJourneysFromCloud(int status, String brandId) async {
    List<Journey> found = [];
    List<JourneyWithBrand> foundWithBrands = [];
    BusBrand? brand = await getBusBrandById(brandId);
    if(brand != null) {
      String path = "journeys/brands/$brandId/status/$status";
      dynamic res = await makeRequest(path: path);
      if(res != null && res != false){
        if(res.isNotEmpty){
          found = res.map<Journey>((dynamic re) => Journey.fromJson(re)).toList();
          if(found.isNotEmpty){
            for(Journey journey in found){
              foundWithBrands.add(JourneyWithBrand(journey: journey, brand: brand));
            }
          }
        }
      }
    }
    return foundWithBrands;
  }

  Future<BusBrandDriver?> createNewDriver(BusBrandDriver dr) async {
    String path = "drivers/";
    dynamic res = await makeRequest(path: path, method: 1, data: dr.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandDriver opr = BusBrandDriver.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusBrandOperator?> getOperatorByAffId(String affId) async {
    String path = "operators/aff/$affId";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandOperator opr = BusBrandOperator.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusBrandOperator?> getOperatorById(String id) async {
    String path = "operators/$id";
    dynamic res = await makeRequest(path: path);
    debugPrint("result: $res, path: $path");
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandOperator opr = BusBrandOperator.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<BusBrandDriver?> getDriverByOperatorId(String id) async {
    String path = "drivers/operators/$id";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res["id"] != null){
        BusBrandDriver opr = BusBrandDriver.fromJson(res);
        return opr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<List<BusImage>?> getBusImagesViaId(String busId) async {
    String path = "buses/$busId/images";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res.isNotEmpty){
        List<BusImage> imgs = res.map<BusImage>((re) => BusImage.fromJson(re)).toList();
        return imgs;
      }else{
        return [];
      }
    }else{
      return null;
    }
  }

  Future<List<BusSeat>?> getBusSeatsViaId(String busId) async {
    String path = "buses/$busId/seats";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res.isNotEmpty){
        List<BusSeat> seats = res.map<BusSeat>((re) => BusSeat.fromJson(re)).toList();
        return seats;
      }else{
        return [];
      }
    }else{
      return null;
    }
  }

  Future<BusSeat?> getBusSeatViaId(String busId, String seatId) async {
    String path = "buses/$busId/seats/$seatId";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return BusSeat.fromJson(res);
    }else{
      return null;
    }
  }

  Future<List<BusFeature>?> getBusFeaturesViaId(String busId) async {
    String path = "buses/$busId/features";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res.isNotEmpty){
        List<BusFeature> features = res.map<BusFeature>((re) => BusFeature.fromJson(re)).toList();
        return features;
      }else{
        return [];
      }
    }else{
      return null;
    }
  }

  Future<List<Bus>?> getBrandBuses(String brandId) async {
    String path = "buses/brands/$brandId";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res.isNotEmpty){
        List<Bus> buses = res.map<Bus>((dynamic re) => Bus.fromJson(re)).toList();
        return buses;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<User?> getDriverDetail(String drId) async {
    String path = "drivers/$drId/aff";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      if(res["id"] != null){
        User usr = User.fromJson(res);
        return usr;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  void toggleButton(){
    if(showFloatingButton){
      updateShowFloatButton(false);
    }else{
      updateShowFloatButton(true);
    }
  }

  Future<bool> blockOperator(String opId) async {
    String path = "operators/$opId/block";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> blockBus(String busId) async {
    String path = "buses/$busId/block";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> blockDriver(String drId) async {
    String path = "drivers/$drId/block";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> unblockOperator(String opId) async {
    String path = "operators/$opId/unblock";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> unblockBus(String busId) async {
    String path = "buses/$busId/unblock";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> unblockDriver(String drId) async {
    String path = "drivers/$drId/unblock";
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteOperator(String opId) async {
    String path = "operators/$opId";
    dynamic res = await makeRequest(path: path, method: 3);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteBus(String busId) async {
    String path = "buses/$busId";
    dynamic res = await makeRequest(path: path, method: 3);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteBusImage(String busId, String imageId) async {
    String path = "buses/$busId/images/$imageId";
    dynamic res = await makeRequest(path: path, method: 3);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteBusSeat(String busId, String seatId) async {
    String path = "buses/$busId/seats/$seatId";
    dynamic res = await makeRequest(path: path, method: 3);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteBusFeature(String busId, String featureId) async {
    String path = "buses/$busId/features/$featureId";
    dynamic res = await makeRequest(path: path, method: 3);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> deleteDriver(String drId) async {
    String path = "drivers/$drId";
    dynamic res = await makeRequest(path: path, method: 3);
    if(res != null && res != false){
      return true;
    }else{
      return false;
    }
  }

  Future<bool> createNewBrand(BusBrand brand) async {
    String path = "";
    dynamic res = await makeRequest(path: path, method: 1, data: brand.toJson());
    if(res != null && res != false){
      if(res["id"] != null){
        busBrand = BusBrand.fromJson(res);
        if(busBrand != null && busBrand!.id != null) busBrandId = busBrand!.id;
        await saveDefaultSettings();
        notifyListeners();
        return true;
      }else{
        return false;
      }
    }else{
      return false;
    }
  }

  Future<String?> sendCode(String email, String code) async {
    String path = "send_code";
    dynamic res = await makeRequest(path: path,data: {
      "email": email,
      "code": code,
    });
    if(res != null && res != false){
      return res;
    }else{
      return null;
    }
  }

  Future<bool> updateEmailVerification(String brandId, String email) async {
    String path = "$brandId/email/verify";
    dynamic res = await makeRequest(path: path);
    if(res == true){
      return true;
    }else{
      return false;
    }
  }

  Future<BusBrand?> getBusBrandById(String id) async {
    String path = id;
    dynamic res = await makeRequest(path: path);
    if(res != null && res != false){
      dynamic brand = res;
      if(brand["id"] == id){
        busBrand = BusBrand.fromJson(brand);
        notifyListeners();
        return busBrand;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  void setDioHeaders(){
    busDio.options.headers.addAll({
      "Content-Type": "application/json",
      "AppCredential": prudApiKey,
      "Authorization": iCloud.affAuthToken
    });
  }

  // method: 0 = GET, 1 = POST, 2 = PUT, 3 = DELETE
  Future<dynamic> makeRequest({required String path, int method = 0, Map<String, dynamic>? data}) async {
    currencyMath.loginAutomatically();
    if(iCloud.affAuthToken != null){
      setDioHeaders();
      String url = "$prudApiUrl/bus_brands/$path";
      Response? res;
      switch(method){
        case 1: res = await busDio.post(url, data: data);
        case 2: res = await busDio.put(url, data: data);
        case 3: res = await busDio.delete(url);
        default: res = await busDio.get(url, queryParameters: data);
      }
      debugPrint("Bus Request: $res");
      if(res.data != null){
        return res.data;
      }else{
        return null;
      }
    }else{
      return null;
    }
  }

  Future<void> clearDefaultSettings() async {
    busBrandId = null;
    busBrand = null;
    busBrandRole = null;
    busOperatorId = null;
    isActive = false;
    await saveDefaultSettings();
  }

  Future<void> clearStaffing() async {
    operatorDetails = [];
    driverDetails = [];
    myStorage.lStore.remove("operatorDetails");
    myStorage.lStore.remove("driverDetails");
  }

  Future<void> initBus() async {
    await tryAsync("initBus", () async {
      getDefaultSettings();
      getDriverDetailsFromCache();
      getOperatorDetailsFromCache();
      getBusDetailsFromCache();
      notifyListeners();
    });
  }

  BusNotifier._internal();
}

double customerDiscountInPercentage = 0.02;
double influencerCommissionInPercentage = 0.025;
Dio busDio = Dio(BaseOptions(
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
final busNotifier = BusNotifier();
final List<Journey> localJourneys = [
  Journey(createdBy: "BERTY", driverId: "", busId: "", departure: 234567838, departureCity: "Lagos", depTerminal: "23, Chisco park, Alaba Market, Lagos.", arrTerminal: "33, Chisco park, Utako.", departureCountry: "NG", departureDate: DateTime.now().subtract(const Duration(days: 3)), destinationCity: "Abuja", destinationCountry: "NG", destinationDate: DateTime.now().subtract(const Duration(days: 2)), duration: JourneyDuration(hours: 22, minutes: 30), brandId: "24567", businessSeatPrice: 35000.00, economySeatPrice: 25000.00, executiveSeatPrice: 45000.00, priceCurrencyCode: "NGN"),
  Journey(createdBy: "BERTY", driverId: "", busId: "", departure: 234567838, departureCity: "Abuja", depTerminal: "23, Chisco park, Abuja.", arrTerminal: "33, Chisco park, Uyo.", departureCountry: "NG", departureDate: DateTime.now().subtract(const Duration(days: 3)), destinationCity: "Uyo", destinationCountry: "NG", destinationDate: DateTime.now().subtract(const Duration(days: 2)), duration: JourneyDuration(hours: 22, minutes: 30), brandId: "24567", businessSeatPrice: 25000.00, economySeatPrice: 20000.00, executiveSeatPrice: 30000.00, priceCurrencyCode: "NGN"),
  Journey(createdBy: "BERTY", driverId: "", busId: "", departure: 234567838, departureCity: "Asaba", depTerminal: "23, Chisco park, Asaba.", arrTerminal: "33, Chisco park, Calabar", departureCountry: "NG", departureDate: DateTime.now().subtract(const Duration(days: 3)), destinationCity: "Calabar", destinationCountry: "NG", destinationDate: DateTime.now().subtract(const Duration(days: 2)), duration: JourneyDuration(hours: 22, minutes: 30), brandId: "24567", businessSeatPrice: 45000.00, economySeatPrice: 35000.00, executiveSeatPrice: 55000.00, priceCurrencyCode: "NGN"),
];