import 'package:flutter/material.dart';
import 'package:prudapp/components/bus_select_operators_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/tab_data.dart';

class NewDriver extends StatefulWidget {
  const NewDriver({super.key});

  @override
  NewDriverState createState() => NewDriverState();
}

class NewDriverState extends State<NewDriver> {
  DateTime? joinedDate;
  String operatorId = "";
  BusBrandOperator? selectedOperator;
  int journeys = 0;
  String? addedBy = myStorage.user?.id;
  String rank = "Junior";
  bool loading = false;
  bool isSuper = false;
  Widget notSuper = Center(
    child: tabData.getNotFoundWidget(
      title: "Access Denied",
      desc: "You do not have sufficient privileges to add new drivers."
    ),
  );


  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }


  @override
  void initState(){
    tryOnly("initState", (){
      if(mounted){
        setState(() {
          isSuper = busNotifier.busBrandRole != null && busNotifier.busBrandRole!.toUpperCase() == "SUPER";
        });
      }
    });
    super.initState();
    busNotifier.addListener((){
      tryOnly("busNotifier Listens", (){
        if(mounted) {
          setState((){
            selectedOperator = busNotifier.selectedOperator;
            if(selectedOperator != null && selectedOperator!.id != null) operatorId = selectedOperator!.id!;
          });
        }
      });
    });
  }

  void clearInput(){
    if(mounted){
      setState(() {
        joinedDate = null;
        operatorId = "";
        journeys = 0;
        rank = "Junior";
        loading = false;
      });
    }
  }

  bool validateForm(){
    return rank.isNotEmpty && addedBy != null && operatorId.isNotEmpty &&
      joinedDate != null && journeys >= 0 && isSuper;
  }


  Future<void> addNewDriver() async {
    if(
      busNotifier.busBrandId != null &&
      busNotifier.busBrandRole != null &&
      busNotifier.isActive
    ){
      await tryAsync("addNewOperator", () async {
        if(mounted) setState(() => loading = true);

        if(mounted) setState(() => loading = false);
      }, error: () {
        if(mounted) setState(() => loading = false);
      });
    }
  }

  void getOperator(){
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
      builder: (BuildContext context) => const BusSelectOperatorsComponent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      physics: const BouncingScrollPhysics(),
      child: isSuper?
      Column(
        children: [
          spacer.height,
          spacer.height,
          PrudContainer(
            hasTitle: true,
            hasPadding: true,
            title: "Operator ID *",
            titleBorderColor: prudColorTheme.bgC,
            titleAlignment: MainAxisAlignment.end,
            child: Column(
              children: [
                mediumSpacer.height,
                InkWell(
                  onTap: getOperator,
                  child: Container(),
                )
              ],
            )
          ),
          spacer.height,
          PrudContainer(
            hasTitle: true,
            hasPadding: true,
            title: "Prudapp ID",
            titleBorderColor: prudColorTheme.bgC,
            titleAlignment: MainAxisAlignment.end,
            child: Column(
              children: [
                spacer.height,
                spacer.height
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
                  onPressed: addNewDriver,
                  text: "Add Driver"
              ) : const SizedBox()
          ),
          largeSpacer.height,
          xLargeSpacer.height,
        ],
      )
          :
      notSuper,
    );
  }
}
