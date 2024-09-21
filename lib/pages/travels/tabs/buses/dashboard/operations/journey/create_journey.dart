import 'package:country_picker/country_picker.dart';
import 'package:country_state_city/models/city.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:country_state_city/models/country.dart' as mc;
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../../components/bus_component.dart';
import '../../../../../../../components/city_picker.dart';
import '../../../../../../../components/country_picker.dart';
import '../../../../../../../components/dashboard_driver_component.dart';
import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/prud_panel.dart';
import '../../../../../../../components/select_bus_component.dart';
import '../../../../../../../components/select_driver_component.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/bus_models.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/i_cloud.dart';
import '../../../../../../../singletons/tab_data.dart';
import 'package:country_state_city/country_state_city.dart' as csc;

class CreateJourney extends StatefulWidget {
  const CreateJourney({super.key});

  @override
  CreateJourneyState createState() => CreateJourneyState();
}

class CreateJourneyState extends State<CreateJourney> {
  bool loading = false;
  String? createdBy = busNotifier.busOperatorId;
  String? brandId = busNotifier.busBrandId;
  String busId = "";
  BusDetail? selectedBus;
  bool shouldReset = false;
  String? driverId;
  DriverDetails? selectedDriver;
  String? departureCity;
  JourneyPoint? depPoint;
  JourneyPoint? arrPoint;
  String? depTerminal;
  String? arrTerminal;
  String? departureCountry;
  DateTime? departureDate;
  String? destinationCity;
  String? destinationCountry;
  DateTime? destinationDate;
  JourneyDuration? duration;
  double businessSeatPrice = 0;
  double economySeatPrice = 0;
  double executiveSeatPrice = 0;
  String? priceCurrencyCode;
  bool loadingDepCities = false;
  bool loadingDesCities = false;
  List<City> depCities = [];
  List<City> desCities = [];
  Currency? selectedCurrency;


  void calculateDuration(){
    if(departureDate != null && destinationDate != null){
      int minutes = destinationDate!.difference(departureDate!).inMinutes;
      if(minutes > 0){
        int hours = minutes > 60?  (minutes/60).floor() : 0;
        int remainingMinutes = minutes % 60;
        if(mounted) setState(() => duration = JourneyDuration(hours: hours, minutes: remainingMinutes));
      }
    }
  }


  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    busNotifier.addListener((){
      if(mounted && busNotifier.selectedBus != null){
        setState(() {
          selectedBus = busNotifier.selectedBus;
          if(selectedBus != null && selectedBus!.bus.id != null) busId = selectedBus!.bus.id!;
        });
      }
      if(mounted && busNotifier.selectedDriver != null){
        setState(() {
          selectedDriver = busNotifier.selectedDriver;
          if(selectedDriver != null && selectedDriver!.dr.id != null) driverId = selectedDriver!.dr.id!;
        });
      }
    });
  }

  void clearInput(){
    setState(() {
      shouldReset = true;
      loading = false;
      busId = "";
      selectedBus = null;
      selectedDriver = null;
      driverId = null;
      departureCity = null;
      depPoint = null;
      arrPoint = null;
      depTerminal = null;
      arrTerminal = null;
      departureDate = null;
      departureCountry = null;
      destinationDate = null;
      destinationCountry = null;
      destinationCity = null;
      duration = null;
      businessSeatPrice = 0;
      economySeatPrice = 0;
      executiveSeatPrice = 0;
      priceCurrencyCode = null;
    });
  }

  bool validateForm(){
    return busId.isNotEmpty && createdBy != null &&
      busId != "" &&
      driverId != null &&
      departureCity != null &&
      depTerminal != null &&
      arrTerminal != null &&
      departureDate != null &&
      departureCountry != null &&
      destinationDate != null &&
      destinationCountry != null &&
      destinationCity != null &&
      duration != null &&
      businessSeatPrice != 0 &&
      economySeatPrice != 0 &&
      executiveSeatPrice != 0 &&
      priceCurrencyCode != null;
  }

  void selectCurrency() {
    showCurrencyPicker(
      context: context,
      favorite: ["NGN", "GBP", "USD", "EUR", "CAD"],
      onSelect: (Currency cur) async {
        tryOnly("selectCurrency", (){
          if(mounted){
            setState(() {
              selectedCurrency = cur;
              priceCurrencyCode = cur.code;
            });
          }
        });
      }
    );
  }

  void selectCountry(bool isDeparture){
    showCountryPicker(
      context: context,
      onSelect: (country) {
        tryOnly("selectCountry", () {
          if (mounted) {
            setState(() {
              if (isDeparture) {
                departureCountry = country.countryCode;
              } else {
                destinationCountry = country.countryCode;
              }
            });
          }
        });
      },
    );
  }


  Future<void> addNewJourney() async {
    if(createdBy != null && brandId != null && busNotifier.isActive){
      await tryAsync("addNewJourney", () async {
        if(mounted) setState(() => loading = true);
        Journey newJourney = Journey(
          createdBy: createdBy!,
          driverId: driverId!,
          busId: busId,
          departureCity: departureCity!,
          depPoint: depPoint,
          departureCountry: departureCountry!,
          departureDate: departureDate!,
          destinationCity: destinationCity!,
          destinationCountry: destinationCountry!,
          destinationDate: destinationDate!,
          duration: duration!,
          brandId: brandId!,
          businessSeatPrice: businessSeatPrice,
          economySeatPrice: economySeatPrice,
          executiveSeatPrice: executiveSeatPrice,
          arrPoint: arrPoint,
          priceCurrencyCode: priceCurrencyCode!,
          depTerminal: depTerminal!,
          arrTerminal: arrTerminal!
        );
        Journey? res = await busNotifier.createNewJourney(newJourney);
        if(res != null && mounted){
          iCloud.showSnackBar("Journey Created", context,title: "Success", type: 2);
          clearInput();
        }else{
          if(mounted) {
            iCloud.showSnackBar("Journey Failed", context);
            setState(() => loading = false);
          }
        }
      }, error: () {
        if(mounted) setState(() => loading = false);
      });
    }
  }

  void getBus(){
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
      builder: (BuildContext context) => const SelectBusComponent(onlyActive: true,),
    );
  }

  void getDriver(){
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
      builder: (BuildContext context) => const SelectDriverComponent(onlyActive: true,),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: loading?
      Center(
        child: LoadingComponent(
          isShimmer: false,
          size: 50,
          spinnerColor: prudColorTheme.primary,
        ),
      )
          :
      SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            mediumSpacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Bus ID *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  InkWell(
                    onTap: getBus,
                    child: selectedBus != null? BusComponent(bus: selectedBus!,) : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Translate(
                            text: "Select Bus"
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 30,
                          color: prudColorTheme.lineB,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Driver ID *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  InkWell(
                    onTap: getDriver,
                    child: selectedDriver != null? DashboardDriverComponent(driver: selectedDriver!,) : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Translate(text: "Select Driver"),
                        Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 30,
                          color: prudColorTheme.lineB,
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
            spacer.height,
            if(busId.isNotEmpty && driverId != null) Column(
              children: [
                spacer.height,
                PrudContainer(
                  hasTitle: true,
                  hasPadding: true,
                  title: "Departure *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      CountryPicker(
                        selected: departureCountry,
                        onChange: (mc.Country ctry) async {
                          if(mounted) {
                            setState(() => loadingDepCities = true);
                            List<City> dCities = await csc.getCountryCities(ctry.isoCode);
                            setState(() {
                              departureCountry = ctry.isoCode;
                              depCities = dCities;
                              loadingDepCities = false;
                            });
                          }
                        },
                      ),
                      if(departureCountry != null) Column(
                        children: [
                          spacer.height,
                          loadingDepCities? LoadingComponent(
                            isShimmer: false,
                            defaultSpinnerType: false,
                            size: 25,
                            spinnerColor: prudColorTheme.lineB,
                          ) :  CityPicker(
                              selected: departureCity,
                              cities: depCities,
                              onChange: (City city) async {
                                if(mounted) {
                                  setState(() {
                                    departureCity = city.name;
                                  });
                                }
                              }
                          ),
                          spacer.height,
                          FormBuilderDateTimePicker(
                            initialValue: departureDate,
                            name: 'depDate',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.text,
                            decoration: getDeco(
                                "Date/Time",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                            ),
                            onChanged: (DateTime? value){
                              if(mounted && value != null) setState(() => departureDate = value);
                              calculateDuration();
                            },
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.dateTime()
                            ]),
                          ),
                          spacer.height,
                          FormBuilderTextField(
                            initialValue: depTerminal,
                            name: 'depAddress',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.text,
                            decoration: getDeco(
                                "Departure Terminal",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                            ),
                            onChanged: (String? value){
                              if(mounted && value != null) setState(() => depTerminal = value);
                            },
                            valueTransformer: (text) => num.tryParse(text!),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.street()
                            ]),
                          ),
                          spacer.height,
                          Row(
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  initialValue: "${depPoint?.latitude?? 0}",
                                  name: 'depLatitude',
                                  style: tabData.npStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: getDeco(
                                      "Latitude",
                                      onlyBottomBorder: true,
                                      borderColor: prudColorTheme.lineC
                                  ),
                                  onChanged: (String? value){
                                    if(mounted && value != null) {
                                      setState(() {
                                        depPoint ??= JourneyPoint(latitude: 0, longitude: 0);
                                        depPoint?.latitude = double.parse(value);
                                      });
                                    }
                                  },
                                  valueTransformer: (text) => num.tryParse(text!),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.latitude()
                                  ]),
                                ),
                              ),
                              spacer.width,
                              Expanded(
                                child: FormBuilderTextField(
                                  initialValue: "${depPoint?.longitude?? 0}",
                                  name: 'depLongitude',
                                  style: tabData.npStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: getDeco(
                                      "Longitude",
                                      onlyBottomBorder: true,
                                      borderColor: prudColorTheme.lineC
                                  ),
                                  onChanged: (String? value){
                                    if(mounted && value != null) {
                                      setState(() {
                                        depPoint ??= JourneyPoint(latitude: 0, longitude: 0);
                                        depPoint?.longitude = double.parse(value);
                                      });
                                    }
                                  },
                                  valueTransformer: (text) => num.tryParse(text!),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.longitude()
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      spacer.height,
                    ],
                  )
                ),
                spacer.height,
                PrudContainer(
                  hasTitle: true,
                  hasPadding: true,
                  title: "Destination *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      CountryPicker(
                        selected: destinationCountry,
                        onChange: (mc.Country ctry) async {
                          if(mounted) {
                            setState(() => loadingDesCities = true);
                            List<City> dCities = await csc.getCountryCities(ctry.isoCode);
                            setState(() {
                              destinationCountry = ctry.isoCode;
                              desCities = dCities;
                              loadingDesCities = false;
                            });
                          }
                        },
                      ),
                      if(destinationCountry != null) Column(
                        children: [
                          spacer.height,
                          loadingDesCities? LoadingComponent(
                            isShimmer: false,
                            defaultSpinnerType: false,
                            size: 25,
                            spinnerColor: prudColorTheme.lineB,
                          ) :  CityPicker(
                              selected: destinationCity,
                              cities: desCities,
                              onChange: (City city) async {
                                if(mounted) {
                                  setState(() {
                                    destinationCity = city.name;
                                  });
                                }
                              }
                          ),
                          spacer.height,
                          FormBuilderDateTimePicker(
                            initialValue: destinationDate,
                            name: 'desDate',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.text,
                            decoration: getDeco(
                                "Date/Time",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                            ),
                            onChanged: (DateTime? value){
                              if(mounted && value != null) setState(() => destinationDate = value);
                              calculateDuration();
                            },
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.dateTime()
                            ]),
                          ),
                          spacer.height,
                          FormBuilderTextField(
                            initialValue: arrTerminal,
                            name: 'arrAddress',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.text,
                            decoration: getDeco(
                                "Destination Terminal",
                                onlyBottomBorder: true,
                                borderColor: prudColorTheme.lineC
                            ),
                            onChanged: (String? value){
                              if(mounted && value != null) setState(() => arrTerminal = value);
                            },
                            valueTransformer: (text) => num.tryParse(text!),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.street()
                            ]),
                          ),
                          spacer.height,
                          Row(
                            children: [
                              Expanded(
                                child: FormBuilderTextField(
                                  initialValue: "${arrPoint?.latitude?? 0}",
                                  name: 'arrLatitude',
                                  style: tabData.npStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: getDeco(
                                      "Latitude",
                                      onlyBottomBorder: true,
                                      borderColor: prudColorTheme.lineC
                                  ),
                                  onChanged: (String? value){
                                    if(mounted && value != null) {
                                      setState(() {
                                        arrPoint ??= JourneyPoint(latitude: 0, longitude: 0);
                                        arrPoint?.latitude = double.parse(value);
                                      });
                                    }
                                  },
                                  valueTransformer: (text) => num.tryParse(text!),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.latitude()
                                  ]),
                                ),
                              ),
                              spacer.width,
                              Expanded(
                                child: FormBuilderTextField(
                                  initialValue: "${arrPoint?.longitude?? 0}",
                                  name: 'arrLongitude',
                                  style: tabData.npStyle,
                                  keyboardType: TextInputType.text,
                                  decoration: getDeco(
                                      "Longitude",
                                      onlyBottomBorder: true,
                                      borderColor: prudColorTheme.lineC
                                  ),
                                  onChanged: (String? value){
                                    if(mounted && value != null) {
                                      setState(() {
                                        arrPoint ??= JourneyPoint(latitude: 0, longitude: 0);
                                        arrPoint?.longitude = double.parse(value);
                                      });
                                    }
                                  },
                                  valueTransformer: (text) => num.tryParse(text!),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.longitude()
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      spacer.height,
                    ],
                  )
                ),
                spacer.height,
                InkWell(
                  onTap: selectCurrency,
                  child: PrudPanel(
                    title: "Currency",
                    titleColor: prudColorTheme.iconB,
                    bgColor: prudColorTheme.bgC,
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          child: Row(
                            children: [
                              if(selectedCurrency != null) Text(
                                "${selectedCurrency!.flag}",
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                    fontSize: 18.0
                                ),
                              ),
                              spacer.width,
                              Translate(
                                text: selectedCurrency != null? selectedCurrency!.name : "Select Currency",
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 20,
                          color: prudColorTheme.lineB,
                        )
                      ],
                    ),
                  ),
                ),
                spacer.height,
                PrudContainer(
                  hasTitle: true,
                  hasPadding: true,
                  title: "Seat Price *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      FormBuilderTextField(
                        initialValue: "$economySeatPrice",
                        name: 'economySeatPrice',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.number,
                        decoration: getDeco(
                            "Economy",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => economySeatPrice = double.parse(value.trim()));
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric()
                        ]),
                      ),
                      spacer.height,
                      FormBuilderTextField(
                        initialValue: "$businessSeatPrice",
                        name: 'businessSeatPrice',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.number,
                        decoration: getDeco(
                            "Business",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => businessSeatPrice = double.parse(value.trim()));
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric()
                        ]),
                      ),
                      spacer.height,
                      FormBuilderTextField(
                        initialValue: "$executiveSeatPrice",
                        name: 'executiveSeatPrice',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.number,
                        decoration: getDeco(
                            "Executive",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => executiveSeatPrice = double.parse(value.trim()));
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric()
                        ]),
                      ),
                      spacer.height,
                    ],
                  )
                ),
                spacer.height,
              ],
            ),
            spacer.height,
            loading?
            LoadingComponent(
              isShimmer: false,
              size: 30,
              spinnerColor: prudColorTheme.primary,
            )
                :
            (
                validateForm()? prudWidgetStyle.getLongButton(
                    onPressed: addNewJourney,
                    text: "Create Journey"
                ) : const SizedBox()
            ),
            largeSpacer.height,
            xLargeSpacer.height,
          ],
        ),
      ),
    );
  }
}
