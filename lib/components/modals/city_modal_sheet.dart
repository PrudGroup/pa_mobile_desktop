import 'package:country_state_city/models/city.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class CityModalSheet extends StatefulWidget {
  final List<City> cities;
  final Function(City) onChange;
  final BorderRadiusGeometry radius;
  final double height;

  const CityModalSheet({
    super.key,
    required this.cities,
    required this.onChange,
    required this.radius,
    required this.height
  });

  @override
  CityModalSheetState createState() => CityModalSheetState();
}

class CityModalSheetState extends State<CityModalSheet> {
  City? selectedCity;
  List<City> foundCities = [];

  @override
  void initState(){
    super.initState();
    if(mounted){
      setState(() {
        foundCities = widget.cities;
      });
    }
  }

  void search(String? value){
    try{
      if(mounted){
        if(value == null || value == ""){
          setState(() => foundCities = widget.cities);
        }else{
          List<City> result = widget.cities.where((st) =>
              st.name.toLowerCase().contains(value.toLowerCase())).toList();
          setState(() => foundCities = result);
        }
      }
    }catch(ex){
      debugPrint("CityPicker Search Error: $ex");
    }
  }

  void onSelected(City selected){
    try{
      Future.delayed(Duration.zero, () async {
        if(mounted) {
          setState(() {
            selectedCity = selected;
          });
        }
        if(selectedCity != null) {
          await widget.onChange(selectedCity!);
        }
      });
      Navigator.pop(context);
    }catch(ex){
      debugPrint("CityPicker State Error: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry rad = widget.radius;
    double height = widget.height;
    return ClipRRect(
      borderRadius: rad,
      child: Container(
          height: height,
          constraints: BoxConstraints(maxHeight: height),
          decoration: BoxDecoration(
              borderRadius: rad,
              color: prudColorTheme.bgA
          ),
          padding: const EdgeInsets.only(left: 5, right: 5, top: 30),
          child: Column(
            children: [
              FormBuilderTextField(
                initialValue: "",
                name: 'search',
                style: tabData.npStyle,
                keyboardType: TextInputType.name,
                decoration: getDeco("Search"),
                onChanged: (String? value){
                  search(value);
                },
                valueTransformer: (text) => num.tryParse(text!),
              ),
              spacer.height,
              Expanded(
                  child: ListView.builder(
                      itemCount: foundCities.length,
                      itemBuilder: (context, index){
                        City dCity = foundCities[index];
                        return InkWell(
                          onTap: () => onSelected(dCity),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5.6),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                color: prudColorTheme.bgC,
                                borderRadius: BorderRadius.circular(7.0)
                            ),
                            child: FittedBox(child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Text(
                                      dCity.countryCode,
                                      style: prudWidgetStyle.typedTextStyle.copyWith(
                                          color: prudColorTheme.iconB,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600
                                      ),
                                    ),
                                    spacer.width,
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 7),
                                      child: Text(
                                        dCity.name,
                                        style: prudWidgetStyle.tabTextStyle.copyWith(
                                          color: prudColorTheme.textA,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    "${dCity.latitude},${dCity.longitude}",
                                    style: prudWidgetStyle.typedTextStyle.copyWith(
                                        fontSize: 10,
                                        color: prudColorTheme.iconB
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                )
                              ],
                            ),),
                          ),
                        );
                      }
                  )
              )
            ],
          )
      ),
    );
  }
}