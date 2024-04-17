import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_panel.dart';

import '../models/theme.dart';

class CountriesPicker extends StatefulWidget {
  final bool isMultiple;
  final List<dynamic> selected;
  final Function(List<String> selectedCountries) onChange;

  const CountriesPicker({
    super.key, required this.selected,
    this.isMultiple = true,
    required this.onChange
  });

  @override
  CountriesPickerState createState() => CountriesPickerState();
}

class CountriesPickerState extends State<CountriesPicker> {
  Country? selectedCountry;
  List<String>? selectedCountries = [];
  bool loading = false;
  bool unloading = false;

  @override
  void initState(){
    super.initState();
    if(mounted) setState(() => selectedCountries = widget.selected.cast<String>());
  }

  void addCountryDialog(){
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.pinkAccent),
        bottomSheetHeight: 500, // Optional. Country list modal height
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //Optional. Styles the search field.
        inputDecoration: getDeco('Search',
          hintText: 'Type to search',
          suffixIcon: const Icon(Icons.search),
        ),
      ),
      onSelect: (Country country) {
        try{
          Future.delayed(Duration.zero, () async {
            if(mounted) {
              setState(() {
                selectedCountry = country;
                if(selectedCountries != null){
                  if((widget.isMultiple && selectedCountries!.length <= 5) || selectedCountries!.isEmpty){
                    selectedCountries!.add(country.name);
                  }
                }
              });
              if(selectedCountries != null) {
                if(mounted) setState(() => loading = true);
                await widget.onChange(selectedCountries!);
                if(mounted) setState(() => loading = false);
              }
            }
          });
        }catch(ex){
          debugPrint("CountriesPicker Error: $ex");
        }
      },
    );
  }

  void removeCountryDialog(){
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.pinkAccent),
        bottomSheetHeight: 500, // Optional. Country list modal height
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        //Optional. Styles the search field.
        inputDecoration: getDeco('Search',
          hintText: 'Type to search',
          suffixIcon: const Icon(Icons.search),
        ),
      ),
      onSelect: (Country country) {
        try{
          Future.delayed(Duration.zero, () async {
            if(mounted) {
              setState(() {
                selectedCountry = country;
                if(selectedCountries != null) selectedCountries!.remove(country.name);
              });
              if(selectedCountries != null) {
                if(mounted) setState(() => unloading = true);
                await widget.onChange(selectedCountries!);
                if(mounted) setState(() => unloading = false);
              }
            }
          });
        }catch(ex){
          debugPrint("CountriesPicker Error: $ex");
        }
      },
    );
  }

  String turnListToString(List<String> arr) =>  arr.join(", ");

  @override
  Widget build(BuildContext context) {
    return PrudPanel(
      title: "Add Countries",
      bgColor: prudColorTheme.bgC,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedCountries != null? turnListToString(selectedCountries!) : "Select Country",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    color: prudColorTheme.textB
                ),
              ),
            ),
            spacer.width,
            loading?  SpinKitFadingCircle(size: 20, color: prudColorTheme.iconB,)
                :
            prudWidgetStyle.getIconButton(
              onPressed: addCountryDialog,
              isIcon: true,
              icon: Icons.plus_one,
            ),
            spacer.width,
            unloading?  SpinKitFadingCircle(size: 20, color: prudColorTheme.iconB,)
                :
            prudWidgetStyle.getIconButton(
              onPressed: removeCountryDialog,
              isIcon: true,
              makeLight: true,
              icon: Icons.exposure_minus_1,
            )
          ],
        ),
      )
    );
  }
}