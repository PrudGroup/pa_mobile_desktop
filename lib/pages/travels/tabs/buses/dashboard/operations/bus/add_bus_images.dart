import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_image_picker.dart';
import 'package:prudapp/models/bus_models.dart';

import '../../../../../../../components/bus_component.dart';
import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/select_bus_component.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/i_cloud.dart';
import '../../../../../../../singletons/shared_local_storage.dart';
import '../../../../../../../singletons/tab_data.dart';

class AddBusImages extends StatefulWidget {
  const AddBusImages({super.key});

  @override
  AddBusImagesState createState() => AddBusImagesState();
}

class AddBusImagesState extends State<AddBusImages> {
  bool loading = false;
  String? createdBy = myStorage.user?.id;
  String? brandId = busNotifier.busBrandId;
  String busId = "";
  String imgUrl = "";
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
      imgUrl = "";
      loading = false;
    });
  }

  bool validateForm(){
    return busId.isNotEmpty && createdBy != null && imgUrl.isNotEmpty;
  }

  Future<void> addNewBusImage() async {
    if(busNotifier.busOperatorId != null && busNotifier.isActive){
      await tryAsync("addNewBusImage", () async {
        if(mounted) setState(() => loading = true);
        BusImage newBusImage = BusImage(
          createdBy: createdBy!, 
          imgUrl: imgUrl, 
          busId: busId
        );
        BusImage? resImage = await busNotifier.createBusImage(newBusImage);
        if(resImage != null && mounted){
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
            if(busId.isNotEmpty) PrudImagePicker(
              destination: "bus_brands/$brandId/buses/$busId/bus_images",
              saveToCloud: true,
              reset: shouldReset,
              onSaveToCloud: (String? url){
                tryOnly("Picker onSaveToCloud", (){
                  if(mounted && url != null) setState(() => imgUrl = url);
                });
              },
              onError: (err){
                debugPrint("Picker Error: $err");
              },
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
                onPressed: addNewBusImage,
                text: "Add Bus Image"
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
