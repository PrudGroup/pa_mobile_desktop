import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:prudapp/components/biller_component.dart';
import 'package:prudapp/components/loading_component.dart';
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
  TextEditingController txtCtrl = TextEditingController();
  String? searchText;
  List<Biller> foundBillers = utilityNotifier.billers;
  Widget noSearchedBillerFound = tabData.getNotFoundWidget(
    title: "Searched Biller No Found",
    desc: "No biller was found matching the searched text above, try changing the name and search again"
  );
  Widget noBiller = tabData.getNotFoundWidget(
    title: "Billers Not Found",
    desc: "We are working round the clock to add more billers. We don't have the biller matching your filter. Kindly change your filters."
  );

  bool checkIfBillerIsSelected(int billerId){
    return utilityNotifier.selectedBiller != null &&
      utilityNotifier.selectedBiller!.id != null &&
      utilityNotifier.selectedBiller!.id! == billerId;
  }


  void search(){
    tryAsync("Utilities.Search()", (){
      if(searchText != null && utilityNotifier.billers.isNotEmpty){
        List<Biller> bis = utilityNotifier.billers.where((bill) => bill.name!.toLowerCase().contains(searchText!.toLowerCase())).toList();
        if(bis.isNotEmpty && mounted) setState(() => foundBillers = bis);
      }
    });
  }

  void refreshSearch(){
    if(mounted){
      setState(() {
        searchText = null;
        txtCtrl.text = "";
        foundBillers = utilityNotifier.billers;
      });
    }
  }

  void setBiller(){
    LastBillersUsed lastBiller = utilityNotifier.lastBillerUsed!;
    switch(billerType){
      case BillerType.electricity: {
        setState(() {
          selectedBiller = lastBiller.electricity;
          deviceNo = lastBiller.lastDeviceUsedOnElectricity;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.electricity!.id!,
            no: deviceNo!,
            type: lastBiller.electricity!.type!,
            serviceType: lastBiller.electricity!.serviceType!,
            countryIsoCode: lastBiller.electricity!.countryCode!,
          );
        });
        break;
      }
      case BillerType.water: {
        setState(() {
          selectedBiller = lastBiller.water;
          deviceNo = lastBiller.lastDeviceUsedOnWater;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.water!.id!,
            no: deviceNo!,
            type: lastBiller.water!.type!,
            serviceType: lastBiller.water!.serviceType!,
            countryIsoCode: lastBiller.water!.countryCode!,
          );
        });
        break;
      }
      case BillerType.tv: {
        setState(() {
          selectedBiller = lastBiller.tv;
          deviceNo = lastBiller.lastDeviceUsedOnTv;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.tv!.id!,
            no: deviceNo!,
            type: lastBiller.tv!.type!,
            serviceType: lastBiller.tv!.serviceType!,
            countryIsoCode: lastBiller.tv!.countryCode!,
          );
        });
        break;
      }
      default: {
        setState(() {
          selectedBiller = lastBiller.internet;
          deviceNo = lastBiller.lastDeviceUsedOnInternet;
          selectedDevice = UtilityDevice(
            billerId: lastBiller.internet!.id!,
            no: deviceNo!,
            type: lastBiller.internet!.type!,
            serviceType: lastBiller.internet!.serviceType!,
            countryIsoCode: lastBiller.internet!.countryCode!,
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
              utilityNotifier.selectedServiceType = null;
            }
            if(utilityNotifier.selectedBiller != null){
              selectedBiller = utilityNotifier.selectedBiller;
              utilityNotifier.selectedBiller = null;
            }
            if(utilityNotifier.selectedUtilityType != null){
              billerType = utilityNotifier.selectedUtilityType!;
              typeIcon = getUtilityTypeIcon();
              utilityNotifier.selectedUtilityType = null;
            }
            if(utilityNotifier.selectedDeviceNumber != null){
              selectedDevice = utilityNotifier.selectedDeviceNumber;
              deviceNo = selectedDevice!.no;
              billerType = utilityNotifier.translateToType(selectedDevice!.type);
              typeIcon = getUtilityTypeIcon();
              serviceType = utilityNotifier.translateToService(selectedDevice!.serviceType);
              serviceTypeIcon = getServiceTypeIcon();
              selectedCountry = tabData.getCountry(selectedDevice!.countryIsoCode);
            }
            if(utilityNotifier.billers.isNotEmpty) billers = utilityNotifier.billers;
          });
          if(utilityNotifier.selectedDeviceNumber != null){
            utilityNotifier.selectedDeviceNumber = null;
            await getBiller();
          }
        }
      }catch(ex){
        debugPrint("utilityNotifier Error: $ex");
      }
    });
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    utilityNotifier.removeListener((){});
    super.dispose();
  }

  Future<void> getBillers() async {
    tryAsync("getBillers", () async {
      if(selectedCountry != null && utilityNotifier.billers.isEmpty){
        if(mounted) setState(() => loading = true);
        UtilitySearch search = UtilitySearch(
          type: utilityNotifier.translateType(billerType),
          serviceType: utilityNotifier.translateService(serviceType),
          countryISOCode: selectedCountry!.countryCode,
        );
        await utilityNotifier.getBillers(search);
        if(mounted) {
          if(utilityNotifier.billers.isNotEmpty) {
            utilityNotifier.updateLastSearch(search);
            setState(() {
              foundBillers = utilityNotifier.billers;
            });
          }
          setState(() => loading = false);
        }
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> getBiller() async {
    tryAsync("getBiller", () async {
      if(selectedDevice != null){
        if(mounted) setState(() => loading = true);
        Biller? bi = await utilityNotifier.getBillerById(selectedDevice!.billerId);
        if(mounted) {
          setState(() {
            if(bi != null) selectedBiller = bi;
            loading = false;
          });
        }
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
      body: Container(
        padding: const EdgeInsets.all(5),
        height: screen.height,
        child: Column(
          children: [
            PrudPanel(
              title: "Filters",
              titleSize: 13,
              titleColor: prudColorTheme.primary,
              bgColor: prudColorTheme.bgC,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: InkWell(
                        onTap: selectCountry,
                        child: Stack(
                          children: [
                            Translate(
                              text: "Country",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: prudColorTheme.secondary
                              ),
                              align: TextAlign.center,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: selectedCountry != null? Text(
                                "${selectedCountry?.flagEmoji}",
                                style: const TextStyle(fontSize: 30),
                              ) : Icon(FontAwesome5Solid.flag, size: 30, color: prudColorTheme.textB,),
                            ),
                          ],
                        ),
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
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: prudColorTheme.secondary
                            ),
                            align: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
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
                      onTap: selectServiceTypes,
                      child: Stack(
                        children: [
                          Translate(
                            text: "Service",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: prudColorTheme.secondary
                            ),
                            align: TextAlign.center,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Image(
                              image: AssetImage(serviceTypeIcon),
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    spacer.width,
                    Expanded(
                      child: FormBuilderTextField(
                        controller: txtCtrl,
                        name: "search",
                        style: tabData.npStyle.copyWith(
                            fontSize: 13,
                            color: prudColorTheme.textA
                        ),
                        keyboardType: TextInputType.text,
                        decoration: getDeco("Biller Name",
                            hasBorders: false,
                            labelStyle: prudWidgetStyle.tabTextStyle.copyWith(
                                color: prudColorTheme.textB,
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh),
                              color: prudColorTheme.primary,
                              onPressed: refreshSearch,
                            ),
                            hintSize: 13
                        ),
                        onChanged: (String? value){
                          try{
                            setState(() {
                              searchText = value?.trim();
                              search();
                            });
                          }catch(ex){
                            debugPrint("Search changed Error: $ex");
                          }
                        },
                      ),
                    ),
                    spacer.width,
                    loading? LoadingComponent(
                      isShimmer: false,
                      spinnerColor: prudColorTheme.primary,
                      size: 30,
                    )
                        :
                    prudWidgetStyle.getIconButton(
                      onPressed: () async {
                        utilityNotifier.billers = [];
                        await getBillers();
                      },
                      isIcon: false,
                      image: typeIcon
                    ),
                  ],
                ),
              ),
            ),
            if(foundBillers.isNotEmpty) Expanded(
              child: ListView.builder(
                itemCount: foundBillers.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index){
                  Biller bi = foundBillers[index];
                  return bi.id != null? BillerComponent(
                    biller: bi,
                    selected: checkIfBillerIsSelected(bi.id!)
                  ) : const SizedBox();
                }
              ),
            ),
            if(foundBillers.isEmpty && utilityNotifier.billers.isNotEmpty) noSearchedBillerFound,
            if(foundBillers.isEmpty && utilityNotifier.billers.isEmpty) noBiller,
            if(selectedBiller != null && selectedBiller!.id != null) BillerComponent(
              biller: selectedBiller!,
              selected: checkIfBillerIsSelected(selectedBiller!.id!)
            )
          ],
        ),
      ),
    );
  }
}
