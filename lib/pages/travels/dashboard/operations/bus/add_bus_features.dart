import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../../../../components/bus_component.dart';
import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/select_bus_component.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/bus_models.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/i_cloud.dart';
import '../../../../../../../singletons/tab_data.dart';

class AddBusFeatures extends StatefulWidget {
  const AddBusFeatures({super.key});

  @override
  AddBusFeaturesState createState() => AddBusFeaturesState();
}

class AddBusFeaturesState extends State<AddBusFeatures> {
  bool loading = false;
  String? createdBy = busNotifier.busOperatorId;
  String? brandId = busNotifier.busBrandId;
  String featureName = "";
  String subtitle = "";
  String description = "";
  String howTo = "";
  String status = "Bad";
  String busId = "";
  BusDetail? selectedBus;
  bool shouldReset = false;

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
    });
  }

  void clearInput(){
    setState(() {
      shouldReset = true;
      featureName = "";
      subtitle = "";
      description = "";
      howTo = "";
      status = "Bad";
      loading = false;
    });
  }

  bool validateForm(){
    return busId.isNotEmpty && createdBy != null && featureName.isNotEmpty &&
    subtitle.isNotEmpty && description.isNotEmpty && howTo.isNotEmpty && status.isNotEmpty &&
    busId.isNotEmpty;
  }

  Future<void> addNewBusFeature() async {
    if(busNotifier.busOperatorId != null && busNotifier.isActive){
      await tryAsync("addNewBusFeature", () async {
        if(mounted) setState(() => loading = true);
        BusFeature newBusFeature = BusFeature(
          createdBy: createdBy!,
          description: description,
          featureName: featureName,
          subtitle: subtitle,
          howTo: howTo,
          status: status,
          statusDate: DateTime.now(),
          busId: busId
        );
        BusFeature? resFeature = await busNotifier.createBusFeature(newBusFeature);
        if(resFeature != null && mounted){
          iCloud.showSnackBar("Bus Feature Created", context,title: "Success", type: 2);
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
      builder: (BuildContext context) => const SelectBusComponent(onlyActive: false,),
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
                            text: "Click & Select Bus"
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
            if(busId.isNotEmpty) Column(
              children: [
                spacer.height,
                PrudContainer(
                  hasTitle: true,
                  hasPadding: true,
                  title: "Feature Name *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      FormBuilderTextField(
                        initialValue: featureName,
                        name: 'name',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                            "Name/Title",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => featureName = value);
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
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
                  title: "Subtitle *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      FormBuilderTextField(
                        initialValue: subtitle,
                        name: 'subtitle',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                          "Subtitle",
                          onlyBottomBorder: true,
                          borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => subtitle = value);
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
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
                  title: "Status",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      FormBuilder(
                        child: FormBuilderChoiceChip(
                          decoration: getDeco("Status"),
                          backgroundColor: prudColorTheme.bgA,
                          disabledColor: prudColorTheme.bgD,
                          spacing: spacer.width.width!,
                          shape: prudWidgetStyle.choiceChipShape,
                          selectedColor: prudColorTheme.primary,
                          onChanged: (String? selected){
                            tryOnly("StatusSelector", (){
                              if(mounted && selected != null){
                                setState(() {
                                  status = selected;
                                });
                              }
                            });
                          },
                          name: "status",
                          initialValue: status,
                          options: busNotifier.statuses.map((String ele) {
                            return FormBuilderChipOption(
                              value: ele,
                              child: Translate(
                                text: ele,
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                    color: ele == status?
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
                  title: "Description *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      FormBuilderTextField(
                        initialValue: description,
                        name: 'desc',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                            "Description",
                            onlyBottomBorder: true,
                            borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => description = value);
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
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
                  title: "Usage *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      Translate(
                        text: "How do customers use this feature while on a journey or before journey begins. ",
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: prudColorTheme.textB
                        ),
                        align: TextAlign.center,
                      ),
                      spacer.height,
                      FormBuilderTextField(
                        initialValue: howTo,
                        name: 'howTo',
                        style: tabData.npStyle,
                        keyboardType: TextInputType.text,
                        decoration: getDeco(
                          "How To",
                          onlyBottomBorder: true,
                          borderColor: prudColorTheme.lineC
                        ),
                        onChanged: (String? value){
                          if(mounted && value != null) setState(() => howTo = value);
                        },
                        valueTransformer: (text) => num.tryParse(text!),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
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
                    onPressed: addNewBusFeature,
                    text: "Add Bus Feature"
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
