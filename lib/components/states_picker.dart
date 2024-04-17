import 'package:flutter/material.dart';
import 'package:country_state_city/models/state.dart' as ms;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_panel.dart';
import '../models/theme.dart';
import 'modals/state_modal_sheet.dart';

class StatesPicker extends StatefulWidget {
  final bool isMultiple;
  final List<ms.State> allStates;
  final List<dynamic> selected;
  final Function(List<String>, String?) onChange;

  const StatesPicker({
    super.key, required this.selected,
    this.isMultiple = true,
    required this.onChange,
    required this.allStates
  });

  @override
  StatesPickerState createState() => StatesPickerState();
}

class StatesPickerState extends State<StatesPicker> {

  List<String>? selectedStates = [];
  String? firstItemCode;
  bool loading = false;
  bool unloading = false;
  BorderRadiusGeometry rad = const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );

  @override
  void initState(){
    super.initState();
    if(mounted) setState(() => selectedStates = widget.selected.cast<String>());
  }

  void addStateDialog(double height){
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
          states: widget.allStates,
          onChange: (ms.State? selected) {
            try{
              if(mounted) setState(() => loading = true);
              Future.delayed(Duration.zero, () async {
                if(mounted && selected != null && selectedStates != null) {
                  setState(() {
                    if((widget.isMultiple && selectedStates!.length <= 5) || selectedStates!.isEmpty){
                      if(selectedStates!.isEmpty) firstItemCode = selected.isoCode;
                      selectedStates!.add(selected.name);
                    }
                  });
                  await widget.onChange(selectedStates!, firstItemCode);
                }
                if(mounted) setState(() => loading = false);
              });
            }catch(ex){
              if(mounted) setState(() => loading = false);
              debugPrint("StatesPicker Error: $ex");
            }
          },
          radius: rad,
          height: height,
        );
      },
    );
  }

  void removeStateDialog(double height){
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
          states: widget.allStates,
          onChange: (ms.State? selected) {
            try{
              if(mounted) setState(() => unloading = true);
              Future.delayed(Duration.zero, () async {
                if(mounted && selected != null && selectedStates != null) {
                  setState(() {
                    if(selectedStates!.isNotEmpty){
                      selectedStates!.remove(selected.name);
                    }
                  });
                  await widget.onChange(selectedStates!, firstItemCode);
                }
                if(mounted) setState(() => unloading = false);
              });
            }catch(ex){
              if(mounted) setState(() => unloading = false);
              debugPrint("StatesPicker Error: $ex");
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
        title: "Add State(s)",
        bgColor: prudColorTheme.bgC,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  selectedStates != null? turnListToString(selectedStates!) : "Select State",
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
                onPressed: () => addStateDialog(modalHeight),
                isIcon: true,
                icon: Icons.plus_one,
              ),
              spacer.width,
              unloading?  SpinKitFadingCircle(size: 20, color: prudColorTheme.iconB,)
                  :
              prudWidgetStyle.getIconButton(
                onPressed: () => removeStateDialog(modalHeight),
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