import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:country_state_city/models/country.dart' as mc;
import 'package:country_state_city/country_state_city.dart' as csc;

import '../models/theme.dart';

class CountryPicker extends StatefulWidget {
  final List<String>? countries;
  final Function(mc.Country) onChange;

  const CountryPicker({super.key, this.countries, required this.onChange});

  @override
  CountryPickerState createState() => CountryPickerState();
}

class CountryPickerState extends State<CountryPicker> {
  mc.Country? selectedCountry;
  bool loading = false;

  void showCountryDialog(){
    showCountryPicker(
      context: context,
      countryFilter: widget.countries,
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
            mc.Country? dCountry = await csc.getCountryFromCode(country.countryCode);
            if(mounted) {
              setState(() {
                selectedCountry = dCountry;
              });
            }
            if(selectedCountry != null) {
              if(mounted) setState(() => loading = true);
              await widget.onChange(selectedCountry!);
              if(mounted) setState(() => loading = false);
            }
          });
        }catch(ex){
          debugPrint("Country Picker Error: $ex");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: showCountryDialog,
      child: PrudPanel(
          title: "Select Country",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedCountry?.name?? "Select Country",
                style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    color: prudColorTheme.textB
                ),
              ),
              loading?  SpinKitFadingCircle(size: 20, color: prudColorTheme.iconB,)
                  : const Icon(Icons.keyboard_arrow_down)
            ],
          )
      ),
    );
  }
}