import 'package:flutter/material.dart';

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

class CreateJourney extends StatefulWidget {
  const CreateJourney({super.key});

  @override
  CreateJourneyState createState() => CreateJourneyState();
}

class CreateJourneyState extends State<CreateJourney> {
  bool loading = false;
  String? createdBy = busNotifier.busOperatorId;
  String? brandId = busNotifier.busBrandId;
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
      loading = false;
    });
  }

  bool validateForm(){
    return busId.isNotEmpty && createdBy != null;
  }

  Future<void> addNewJourney() async {
    if(createdBy != null && brandId != null && busNotifier.isActive){
      await tryAsync("addNewJourney", () async {
        if(mounted) setState(() => loading = true);
        Journey newJourney = Journey(
          createdBy: createdBy!,
          driverId: driverId,
          busId: busId,
          departureCity: departureCity,
          depPoint: depPoint,
          departureCountry: departureCountry,
          departureDate: departureDate,
          destinationCity: destinationCity,
          destinationCountry: destinationCountry,
          destinationDate: destinationDate,
          duration: duration,
          brandId: brandId!,
          businessSeatPrice: businessSeatPrice,
          economySeatPrice: economySeatPrice,
          executiveSeatPrice: executiveSeatPrice,
          arrPoint: arrPoint,
          priceCurrencyCode: priceCurrencyCode
        );
        Journey? res = await busNotifier.createNewJourney(newJourney);
        if(res != null && mounted){
          iCloud.showSnackBar("Journey Created", context,title: "Success", type: 2);
          clearInput();
        }else{
          if(mounted) {
            iCloud.showSnackBar("Journey Failed", context);
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
      builder: (BuildContext context) => const SelectBusComponent(onlyActive: true,),
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
                            text: "Select Bus"
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
                    title: "Seat No *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilderTextField(
                          initialValue: seatNo,
                          name: 'seatNo',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Seat No",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => seatNo = value);
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
                    title: "Seat Type",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilder(
                          child: FormBuilderChoiceChip(
                            decoration: getDeco("Seat Type"),
                            backgroundColor: prudColorTheme.bgA,
                            disabledColor: prudColorTheme.bgD,
                            spacing: spacer.width.width!,
                            shape: prudWidgetStyle.choiceChipShape,
                            selectedColor: prudColorTheme.primary,
                            onChanged: (String? selected){
                              tryOnly("SeatTypeSelector", (){
                                if(mounted && selected != null){
                                  setState(() {
                                    seatType = selected;
                                  });
                                }
                              });
                            },
                            name: "seatType",
                            initialValue: seatType,
                            options: busNotifier.seatTypes.map((String ele) {
                              return FormBuilderChipOption(
                                value: ele,
                                child: Translate(
                                  text: ele,
                                  style: prudWidgetStyle.btnTextStyle.copyWith(
                                      color: ele == seatType?
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
                    title: "Position *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        Translate(
                          text: "Where is this seat located in the bus. (e.g Left-Middle)",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: position,
                          name: 'position',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.text,
                          decoration: getDeco(
                              "Seat Position",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => position = value);
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
                    onPressed: addNewBusSeat,
                    text: "Add Bus Seat"
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
