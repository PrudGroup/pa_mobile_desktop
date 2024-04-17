import 'package:flutter/material.dart';
import 'package:country_state_city/models/city.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_panel.dart';

import '../models/theme.dart';
import 'modals/city_modal_sheet.dart';

class CitiesPicker extends StatefulWidget {
  final bool isMultiple;
  final List<City> cities;
  final List<dynamic> selected;
  final Function(List<String>) onChange;

  const CitiesPicker({
    super.key,
    required this.onChange,
    required this.cities,
    required this.selected,
    this.isMultiple = true,
  });

  @override
  CitiesPickerState createState() => CitiesPickerState();
}

class CitiesPickerState extends State<CitiesPicker> {
  List<String>? selectedCities = [];
  bool loading = false;
  bool unloading = false;
  BorderRadiusGeometry rad = const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );

  @override
  void initState(){
    super.initState();
    if(mounted) setState(() => selectedCities = widget.selected.cast<String>());
  }

  void addCityDialog(double height){
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
                if(mounted && selected != null && selectedCities != null) {
                  setState(() {
                    if((widget.isMultiple && selectedCities!.length <= 5)|| selectedCities!.isEmpty){
                      selectedCities!.add(selected.name);
                    }
                  });
                  await widget.onChange(selectedCities!);
                }
                if(mounted) setState(() => loading = false);
              });
            }catch(ex){
              if(mounted) setState(() => loading = false);
              debugPrint("CitiesPicker Error: $ex");
            }
          },
          radius: rad,
          height: height,
        );
      },
    );
  }

  void removeCityDialog(double height){
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
              if(mounted) setState(() => unloading = true);
              Future.delayed(Duration.zero, () async {
                if(mounted && selected != null && selectedCities != null) {
                  setState(() {
                    if(selectedCities!.isNotEmpty){
                      selectedCities!.remove(selected.name);
                    }
                  });
                  await widget.onChange(selectedCities!);
                }
                if(mounted) setState(() => unloading = false);
              });
            }catch(ex){
              if(mounted) setState(() => unloading = false);
              debugPrint("CitiesPicker Error: $ex");
            }
          },
          radius: rad,
          height: height,
        );
      },
    );
  }

  String turnListToString(List<String> arr) =>  arr.join(", ");

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double modalHeight = screen.height * 0.65;
    return PrudPanel(
        title: "Add City(ies)",
        bgColor: prudColorTheme.bgC,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedCities != null? turnListToString(selectedCities!) : "Select City",
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
                onPressed: () => addCityDialog(modalHeight),
                isIcon: true,
                icon: Icons.plus_one,
              ),
              spacer.width,
              unloading?  SpinKitFadingCircle(size: 20, color: prudColorTheme.iconB,)
                  :
              prudWidgetStyle.getIconButton(
                onPressed: () => removeCityDialog(modalHeight),
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