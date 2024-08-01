import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../components/saved_billers.dart';
import '../../../components/saved_device_numbers.dart';
import '../../../components/translate_text.dart';
import '../../../components/utility_service_types.dart';
import '../../../components/utility_types.dart';
import '../../../models/theme.dart';
import '../../../singletons/i_cloud.dart';
import '../../../singletons/utility_notifier.dart';
import '../utility_history.dart';

class Utilities extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const Utilities({super.key, this.affLinkId, this.goToTab});

  @override
  UtilitiesState createState() => UtilitiesState();
}

class UtilitiesState extends State<Utilities> {

  Country? selectedCountry;
  List<String> countries = [];
  String typeIcon = prudImages.power1;
  String serviceTypeIcon = prudImages.prepaid;
  BillerType billerType = BillerType.electricity;
  BillerServiceType serviceType = BillerServiceType.prepaid;
  bool loading = false;
  List<Biller> billers = utilityNotifier.billers;
  Biller? selectedBiller;
  String? deviceNo;
  UtilityDevice? selectedDevice;

  void setBiller(){
    LastBillersUsed lastBiller = utilityNotifier.lastBillerUsed!;
    switch(billerType){
      case BillerType.electricity: {
        setState(() {
          selectedBiller = lastBiller.electricity;
          deviceNo = lastBiller.lastDeviceUsedOnElectricity;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.electricity!.id,
            no: deviceNo,
            type: lastBiller.electricity!.type,
            serviceType: lastBiller.electricity!.serviceType,
            countryIsoCode: lastBiller.electricity!.countryCode,
          );
        });
        break;
      }
      case BillerType.water: {
        setState(() {
          selectedBiller = lastBiller.water;
          deviceNo = lastBiller.lastDeviceUsedOnWater;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.water!.id,
            no: deviceNo,
            type: lastBiller.water!.type,
            serviceType: lastBiller.water!.serviceType,
            countryIsoCode: lastBiller.water!.countryCode,
          );
        });
        break;
      }
      case BillerType.tv: {
        setState(() {
          selectedBiller = lastBiller.tv;
          deviceNo = lastBiller.lastDeviceUsedOnTv;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.tv!.id,
            no: deviceNo,
            type: lastBiller.tv!.type,
            serviceType: lastBiller.tv!.serviceType,
            countryIsoCode: lastBiller.tv!.countryCode,
          );
        });
        break;
      }
      default: {
        setState(() {
          selectedBiller = lastBiller.internet;
          deviceNo = lastBiller.lastDeviceUsedOnInternet;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.internet!.id,
            no: deviceNo,
            type: lastBiller.internet!.type,
            serviceType: lastBiller.internet!.serviceType,
            countryIsoCode: lastBiller.internet!.countryCode,
          );
        });
        break;
      }
    }
  }

  String getServiceTypeIcon() => serviceType == BillerServiceType.postpaid? prudImages.postpaid : prudImages.prepaid;

  String getUtilityTypeIcon(){
    switch(billerType){
      case BillerType.electricity: return prudImages.power1;
      case BillerType.water: return prudImages.water;
      case BillerType.tv: return prudImages.smartTv1;
      default: return prudImages.internet;
    }
  }

  @override
  void initState() {
    tryAsync("initState", () async {
      if(utilitizedCountries.isNotEmpty){
        List<String> ctrs = utilitizedCountries.map((cty) => cty.isoName?? "" ).toList();
        if(ctrs.isNotEmpty && mounted) {
          setState(() {
            countries = ctrs;
            billers = utilityNotifier.billers;
            selectedCountry = tabData.getCountry("NG");
          });
          if(utilityNotifier.lastUtilitySearch != null) await setUtilitySearch();
        }
      }
    });
    super.initState();
    utilityNotifier.addListener(() async {
      try{
        if(mounted){
          setState(() {
            if(utilityNotifier.selectedServiceType != null) {
              serviceType = utilityNotifier.selectedServiceType!;
              serviceTypeIcon = getServiceTypeIcon();
            }
            if(utilityNotifier.selectedBiller != null) selectedBiller = utilityNotifier.selectedBiller;
            if(utilityNotifier.selectedUtilityType != null){
              billerType = utilityNotifier.selectedUtilityType!;
              typeIcon = getUtilityTypeIcon();
            }
            if(utilityNotifier.billers.isNotEmpty) billers = utilityNotifier.billers;
          });
        }
      }catch(ex){
        debugPrint("utilityNotifier Error: $ex");
      }
    });
  }

  @override
  void dispose() {
    utilityNotifier.removeListener((){});
    super.dispose();
  }

  Future<void> getBillers() async {
    tryAsync("getBillers", () async {
      if(selectedCountry != null){
        if(mounted) setState(() => loading = true);
        UtilitySearch search = UtilitySearch(
          type: utilityNotifier.translateType(billerType),
          serviceType: utilityNotifier.translateService(serviceType),
          countryISOCode: selectedCountry!.countryCode,
        );
        await utilityNotifier.getBillers(search);
        if(mounted) setState(() => loading = false);
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> setUtilitySearch() async {
    tryAsync("setUtilitySearch", () async {
      UtilitySearch search = utilityNotifier.lastUtilitySearch!;
      if(mounted){
        setState(() {
          serviceType = utilityNotifier.translateToService(search.serviceType);
          billerType = utilityNotifier.translateToType(search.type);
          selectedCountry = tabData.getCountry(search.countryISOCode);
          serviceTypeIcon = getServiceTypeIcon();
          typeIcon = getUtilityTypeIcon();
        });
        if(utilityNotifier.lastBillerUsed != null){
          if(mounted){
            setBiller();
          }
        }else{ await getBillers(); }
      }
    });
  }

  void selectCountry(){
    showCountryPicker(
      context: context,
      countryFilter: countries,
      onSelect: (country){
        try{
          if(mounted) setState(() => selectedCountry = country);
        }catch(ex){
          debugPrint("selectCountry Error: $ex");
        }
      }
    );
  }

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  void showDevices(){
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) => const SavedDeviceNumbers(),
    );
  }

  void selectType(){
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) => const UtilityTypes(),
    );
  }

  void selectServiceTypes(){
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) => const UtilityServiceTypes(),
    );
  }

  void showLastBillers(){
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) => const SavedBillers(),
    );
  }


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Utility & Bills",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: [
          if(utilityNotifier.deviceNumbers.isNotEmpty) IconButton(
            onPressed: showDevices,
            icon: const Icon(Icons.devices_other_outlined),
            color: prudColorTheme.bgA,
            iconSize: 18,
          ),
          if(utilityNotifier.lastBillerUsed != null) InkWell(
            onTap: showLastBillers,
            child: Stack(
              children: [
                ImageIcon(
                  AssetImage(prudImages.utilities),
                  size: 15,
                  color: prudColorTheme.bgA,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 7, left: 7),
                  child: ImageIcon(
                    AssetImage(prudImages.like),
                    size: 6,
                    color: prudColorTheme.bgA,
                  ),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: () => iCloud.goto(context, const UtilityHistory()),
            icon: const Icon(FontAwesome5Solid.history),
            color: prudColorTheme.bgA,
            iconSize: 18,
          )
        ],
      ),
      body: SizedBox(
        height: screen.height,
        child: Column(
          children: [
            spacer.height,
            PrudPanel(
              title: "Filters",
              titleSize: 13,
              titleColor: prudColorTheme.primary,
              bgColor: prudColorTheme.bgC,
              child: Row(
                children: [
                  InkWell(
                    onTap: selectCountry,
                    child: Stack(
                      children: [
                        Translate(
                          text: "Country",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: selectedCountry != null? Text(
                            "${selectedCountry?.flagEmoji}",
                            style: const TextStyle(fontSize: 30),
                          ) : Icon(FontAwesome5Solid.flag, size: 30, color: prudColorTheme.textB,),
                        ),
                      ],
                    ),
                  ),
                  spacer.width,
                  InkWell(
                    onTap: selectType,
                    child: Stack(
                      children: [
                        Translate(
                          text: "Type",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ImageIcon(
                            AssetImage(typeIcon),
                            size: 30,
                            color: prudColorTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  spacer.width,
                  InkWell(
                    onTap: selectType,
                    child: Stack(
                      children: [
                        Translate(
                          text: "Service",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ImageIcon(
                            AssetImage(serviceTypeIcon),
                            size: 30,
                            color: prudColorTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
