import 'package:country_state_city/models/city.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_panel.dart';

import '../models/theme.dart';
import 'modals/city_modal_sheet.dart';

class CityPicker extends StatefulWidget {
  final String? selected;
  final List<City> cities;
  final Function(City) onChange;

  const CityPicker({
    super.key,
    required this.cities,
    required this.onChange,
    this.selected
  });

  @override
  CityPickerState createState() => CityPickerState();
}

class CityPickerState extends State<CityPicker> {
  City? selectedCity;
  bool loading = false;
  BorderRadiusGeometry rad = const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );

  void showCityDialog(double height){
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: rad,
      ),
      builder: (BuildContext context) {
        return CityModalSheet(
          cities: widget.cities,
          onChange: (City? selected) {
            try{
              if(mounted) setState(() => loading = true);
              Future.delayed(Duration.zero, () async {
                if(selected != null) {
                  if(mounted) setState(() => selectedCity = selected);
                  await widget.onChange(selected);
                }
                if(mounted) setState(() => loading = false);
              });
            }catch(ex){
              if(mounted) setState(() => loading = false);
              debugPrint("CityPicker Error: $ex");
            }
          },
          radius: rad,
          height: height,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double modalHeight = screen.height * 0.65;
    return InkWell(
      onTap: () => showCityDialog(modalHeight),
      child: PrudPanel(
          title: "Select City",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selected?? selectedCity?.name?? "Select City",
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