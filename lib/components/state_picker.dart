import 'package:flutter/material.dart';
import 'package:country_state_city/models/state.dart' as ms;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/components/modals/state_modal_sheet.dart';

import '../models/theme.dart';

class StatePicker extends StatefulWidget {
  final List<ms.State> states;
  final Function(ms.State) onChange;

  const StatePicker({super.key, required this.states, required this.onChange});

  @override
  StatePickerState createState() => StatePickerState();
}

class StatePickerState extends State<StatePicker> {

  ms.State? selectedState;
  bool loading = false;
  BorderRadiusGeometry rad = const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );

  void showStateDialog(double height){
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgA,
      elevation: 10,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: rad,
      ),
      builder: (BuildContext context) {
        return StateModalSheet(
          states: widget.states,
          onChange: (ms.State? selected) {
            try{
              if(mounted) setState(() => loading = true);
              Future.delayed(Duration.zero, () async {
                if(selected != null) {
                  if(mounted) setState(() => selectedState = selected);
                  await widget.onChange(selected);
                }
                if(mounted) setState(() => loading = false);
              });
            }catch(ex){
              if(mounted) setState(() => loading = false);
              debugPrint("State Picker Error: $ex");
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
      onTap: () => showStateDialog(modalHeight),
      child: PrudPanel(
          title: "Select State/Province",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedState?.name?? "Select State/Province",
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