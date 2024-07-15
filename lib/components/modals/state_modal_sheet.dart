import 'package:flutter/material.dart';
import 'package:country_state_city/models/state.dart' as ms;
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../models/theme.dart';
import '../../singletons/tab_data.dart';

class StateModalSheet extends StatefulWidget {
  final List<ms.State> states;
  final Function(ms.State) onChange;
  final BorderRadiusGeometry radius;
  final double height;

  const StateModalSheet({
    super.key,
    required this.states,
    required this.onChange,
    required this.radius,
    required this.height
  });

  @override
  StateModalSheetState createState() => StateModalSheetState();
}

class StateModalSheetState extends State<StateModalSheet> {
  ms.State? selectedState;
  List<ms.State> foundStates = [];

  @override
  void initState(){
    super.initState();
    if(mounted){
      setState(() {
        foundStates = widget.states;
      });
    }
  }

  void search(String? value){
    try{
      if(mounted){
        if(value == null || value == ""){
          setState(() => foundStates = widget.states);
        }else{
          List<ms.State> result = widget.states.where((st) =>
              st.name.toLowerCase().contains(value.toLowerCase())).toList();
          setState(() => foundStates = result);
        }
      }
    }catch(ex){
      debugPrint("StatePicker Search Error: $ex");
    }
  }

  void onSelected(ms.State selected){
    try{
      Future.delayed(Duration.zero, () async {
        if(mounted) {
          setState(() {
            selectedState = selected;
          });
        }
        if(selectedState != null) {
          await widget.onChange(selectedState!);
        }
      });
      Navigator.pop(context);
    }catch(ex){
      debugPrint("State Picker State Error: $ex");
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
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: foundStates.length,
                      itemBuilder: (context, index){
                        ms.State dState = foundStates[index];
                        return InkWell(
                          onTap: () => onSelected(dState),
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
                                      dState.isoCode,
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
                                        dState.name,
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
                                    "${dState.latitude},${dState.longitude}",
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