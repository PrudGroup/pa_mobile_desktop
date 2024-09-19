import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../../../components/bus_component.dart';
import '../../../../../../../components/bus_feature_component.dart';
import '../../../../../../../components/bus_seat_component.dart';
import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/prud_network_image.dart';
import '../../../../../../../components/select_bus_component.dart';
import '../../../../../../../components/select_bus_feature_component.dart';
import '../../../../../../../components/select_bus_image_component.dart';
import '../../../../../../../components/select_bus_seat_component.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/bus_models.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/i_cloud.dart';
import '../../../../../../../singletons/tab_data.dart';

class RemoveOperations extends StatefulWidget {
  const RemoveOperations({super.key});

  @override
  RemoveOperationsState createState() => RemoveOperationsState();
}

class RemoveOperationsState extends State<RemoveOperations> {
  bool loading = false;
  String? brandId = busNotifier.busBrandId;
  String seatId= "";
  String featureId = "Economy";
  String imageId = "";
  String operation = "Photo";
  String busId = "";
  BusDetail? selectedBus;
  BusFeature? selectedFeature;
  BusImage? selectedImage;
  BusSeat? selectedSeat;
  bool shouldReset = false;
  List<String> operations = ["Photo", "Feature", "Seat"];
  bool showButton = false;

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
          if(busNotifier.selectedBusSeat != null){
            imageId = "";
            featureId = "";
            selectedSeat = busNotifier.selectedBusSeat;
            if(selectedSeat!.id != null) seatId = selectedSeat!.id!;
          }
          if(busNotifier.selectedBusFeature != null){
            imageId = "";
            seatId = "";
            selectedFeature = busNotifier.selectedBusFeature;
            if(selectedFeature!.id != null) featureId = selectedFeature!.id!;
          }
          if(busNotifier.selectedBusImage != null){
            selectedImage = busNotifier.selectedBusImage;
            if(selectedImage!.id != null) imageId = selectedImage!.id!;
            featureId = "";
            seatId = "";
          }
          bool res = validateForm();
          if(res == true) showButton = true;
        });

      }
    });
  }

  void clearInput(){
    setState(() {
      shouldReset = true;
      seatId = "";
      featureId = "";
      imageId = "";
      loading = false;
      showButton = false;
      selectedSeat = null;
      selectedFeature = null;
      selectedImage = null;
    });
  }

  bool validateForm(){
    switch(operation.toLowerCase()){
      case "photo": return imageId.isNotEmpty;
      case "feature": return featureId.isNotEmpty;
      default: return seatId.isNotEmpty;
    }
  }

  Future<void> deleteOperation() async {
    if(busNotifier.busOperatorId != null && busNotifier.isActive){
      await tryAsync("deleteOperation", () async {
        if(mounted) setState(() => loading = true);
        bool succeeded = false;
        switch(operation.toLowerCase()){
          case "photo": {
            bool imgRes = await busNotifier.deleteBusImage(busId, imageId);
            // bool res = await iCloud.deleteFileFromCloud(selectedImage!.imgUrl);
            succeeded = imgRes/* && res*/;
          }
          case "feature": {
            succeeded = await busNotifier.deleteBusFeature(busId, featureId);
          }
          default: {
            succeeded = await busNotifier.deleteBusSeat(busId, seatId);
          }
        }
        if(succeeded && mounted){
          iCloud.showSnackBar("Operation deleted", context,title: "Success", type: 2);
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

  void getBusImage(){
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
      builder: (BuildContext context) => SelectBusImageComponent(onlyActive: false, busId: busId),
    );
  }

  void getBusFeature(){
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
      builder: (BuildContext context) => SelectBusFeatureComponent(onlyActive: false, busId: busId,),
    );
  }

  void getBusSeat(){
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
      builder: (BuildContext context) => SelectBusSeatComponent(onlyActive: false, busId: busId,),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    String ops = operation.toLowerCase();
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
                  title: "Operation",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      FormBuilder(
                        child: FormBuilderChoiceChip(
                          decoration: getDeco("Delete What?"),
                          backgroundColor: prudColorTheme.bgA,
                          disabledColor: prudColorTheme.bgD,
                          spacing: spacer.width.width!,
                          shape: prudWidgetStyle.choiceChipShape,
                          selectedColor: prudColorTheme.primary,
                          onChanged: (String? selected){
                            tryOnly("OperationSelector", (){
                              if(mounted && selected != null){
                                setState(() {
                                  operation = selected;
                                  showButton = false;
                                });
                              }
                            });
                          },
                          name: "operation",
                          initialValue: operation,
                          options: operations.map((String ele) {
                            return FormBuilderChipOption(
                              value: ele,
                              child: Translate(
                                text: ele,
                                style: prudWidgetStyle.btnTextStyle.copyWith(
                                  color: ele == operation?
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
                if(ops == 'photo') PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Image ID *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        InkWell(
                          onTap: getBusImage,
                          child: selectedImage != null? PrudNetworkImage(
                            url: selectedImage!.imgUrl,
                            height: 100,
                          ) : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Translate(
                                  text: "Select Bus Photo"
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
                if(ops == 'photo') spacer.height,
                if(ops == 'feature') PrudContainer(
                  hasTitle: true,
                  hasPadding: true,
                  title: "Feature ID *",
                  titleBorderColor: prudColorTheme.bgC,
                  titleAlignment: MainAxisAlignment.end,
                  child: Column(
                    children: [
                      mediumSpacer.height,
                      InkWell(
                        onTap: getBusFeature,
                        child: selectedFeature != null? BusFeatureComponent(feature: selectedFeature!,) : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Translate(
                                text: "Select Bus Feature"
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
                if(ops == 'feature') spacer.height,
                if(ops == 'seat') PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Seat ID *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        InkWell(
                          onTap: getBusSeat,
                          child: selectedSeat != null? BusSeatComponent(seat: selectedSeat!,) : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Translate(
                                  text: "Select Bus Seat"
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
                if(ops == 'seat') spacer.height,
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
                showButton? prudWidgetStyle.getLongButton(
                  onPressed: deleteOperation,
                  text: "Delete $operation"
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
