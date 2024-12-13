import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/models/bus_models.dart';

import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/i_cloud.dart';
import '../../../../../../../singletons/shared_local_storage.dart';
import '../../../../../../../singletons/tab_data.dart';

class AddBus extends StatefulWidget {
  const AddBus({super.key});

  @override
  AddBusState createState() => AddBusState();
}

class AddBusState extends State<AddBus> {

  bool loading = false;
  String plateNo = "";
  String busType = "Luxurious Bus";
  DateTime? boughtOn;
  String busNo = "";
  String busManufacturer = "";
  int manufacturedYear = 2024;
  int totalJourney = 0;
  String? createdBy = myStorage.user?.id;
  String? brandId = busNotifier.busBrandId;

  void clearInput(){
    setState(() {
      plateNo = "";
      busType = "Luxurious Bus";
      boughtOn = null;
      busNo = "";
      busManufacturer = "";
      manufacturedYear = 2024;
      totalJourney = 0;
      loading = false;
    });
  }

  bool validateForm(){
    return plateNo.isNotEmpty && createdBy != null && busNo.isNotEmpty &&
      boughtOn != null && totalJourney >= 0 && manufacturedYear <= 2024 && busManufacturer.isNotEmpty;
  }

  Future<void> addNewBus() async {
    if(busNotifier.busOperatorId != null && busNotifier.isActive){
      await tryAsync("addNewBus", () async {
        if(mounted) setState(() => loading = true);
        Bus newBus = Bus(
          brandId: brandId!,
          boughtOn: boughtOn!,
          busManufacturer: busManufacturer,
          busNo: busNo,
          busType: busType,
          createdBy: createdBy!,
          manufacturedYear: manufacturedYear,
          plateNo: plateNo,
          totalJourney: totalJourney
        );
        Bus? resBus = await busNotifier.createNewBus(newBus);
        if(resBus != null && mounted){
          iCloud.showSnackBar("Bus Created", context,title: "Success", type: 2);
          clearInput();
        }else{
          if(mounted) {
            iCloud.showSnackBar("Operation Failed", context);
            setState(() => loading = false);
          }
        }
      }, error: () {
        if(mounted) setState(() => loading = false);
      });
    }
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
            spacer.height,
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Bus Plate No *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: plateNo,
                    name: 'plateNo',
                    autofocus: true,
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Plate No",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => plateNo = value);
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(30),
                    ]),
                  ),
                  spacer.height
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Bus Type *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilder(
                    child: FormBuilderChoiceChip(
                      decoration: getDeco("type"),
                      backgroundColor: prudColorTheme.bgA,
                      disabledColor: prudColorTheme.bgD,
                      spacing: spacer.width.width!,
                      shape: prudWidgetStyle.choiceChipShape,
                      selectedColor: prudColorTheme.primary,
                      onChanged: (String? selected){
                        tryOnly("BusTypeSelector", (){
                          if(mounted && selected != null){
                            setState(() {
                              busType = selected;
                            });
                          }
                        });
                      },
                      name: "busType",
                      initialValue: busType,
                      options: busNotifier.busTypes.map((String ele) {
                        return FormBuilderChipOption(
                          value: ele,
                          child: Translate(
                            text: ele,
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                color: ele == busType?
                                prudColorTheme.bgA : prudColorTheme.primary
                            ),
                            align: TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Bus No *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: busNo,
                    name: 'busNo',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                      "Bus No",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => busNo = value);
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(30),
                    ]),
                  ),
                  spacer.height
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Bus Manufacturer *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: busManufacturer,
                    name: 'busManufacturer',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.text,
                    decoration: getDeco(
                        "Bus Manufacturer",
                        onlyBottomBorder: true,
                        borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => busManufacturer = value);
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(3),
                      FormBuilderValidators.maxLength(60),
                    ]),
                  ),
                  spacer.height
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Manufactured Year *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderTextField(
                    initialValue: "$manufacturedYear",
                    name: 'manufacturedYear',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.number,
                    decoration: getDeco(
                      "Manufactured Year",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => manufacturedYear = int.parse(value));
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.minLength(4),
                      FormBuilderValidators.maxLength(4),
                    ]),
                  ),
                  spacer.height
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Bought Date *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  FormBuilderDateTimePicker(
                    initialValue: boughtOn,
                    name: 'boughtOn',
                    style: tabData.npStyle,
                    inputType: InputType.date,
                    keyboardType: TextInputType.datetime,
                    decoration: getDeco(
                      "Bought On",
                      onlyBottomBorder: true,
                      borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (DateTime? value){
                      if(mounted && value != null) setState(() => boughtOn = value);
                    },
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.dateTime(),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
            ),
            spacer.height,
            PrudContainer(
              hasTitle: true,
              hasPadding: true,
              title: "Journeys *",
              titleBorderColor: prudColorTheme.bgC,
              titleAlignment: MainAxisAlignment.end,
              child: Column(
                children: [
                  mediumSpacer.height,
                  Translate(
                    text: "How many Journey has this bus made so far. ",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: prudColorTheme.textB
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  FormBuilderTextField(
                    initialValue: "$totalJourney",
                    name: 'journeys',
                    style: tabData.npStyle,
                    keyboardType: TextInputType.number,
                    decoration: getDeco(
                        "Journeys Made",
                        onlyBottomBorder: true,
                        borderColor: prudColorTheme.lineC
                    ),
                    onChanged: (String? value){
                      if(mounted && value != null) setState(() => totalJourney = int.parse(value));
                    },
                    valueTransformer: (text) => num.tryParse(text!),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.integer(),
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  spacer.height,
                ],
              )
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
                onPressed: addNewBus,
                text: "Add Bus"
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
