import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/bus_select_operators_component.dart';
import 'package:prudapp/components/operator_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../../../../../../../components/loading_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/translate_text.dart';
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
  OperatorDetails? selectedOperator;
  int journeys = 0;
  String? addedBy = myStorage.user?.id;
  String rank = "Junior";
  bool loading = false;
  bool isSuper = true;
  Widget notSuper = Center(
    child: tabData.getNotFoundWidget(
      title: "Access Denied",
      desc: "You do not have sufficient privileges to add new drivers."
    ),
  );
  List<String>? excludeIds;


  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  void setExistingDriversIds(){
    if(busNotifier.driverDetails.isNotEmpty){
      List<String> existingIds = busNotifier.driverDetails.map((item) => item.dr.operatorId).toList();
      setState(() => excludeIds = existingIds);
    }
  }


  @override
  void initState(){
    tryOnly("initState", () async {
      if(mounted){
        setExistingDriversIds();
        setState(() {
          isSuper = busNotifier.busBrandRole != null && busNotifier.busBrandRole!.toUpperCase() == "SUPER";
        });
      }
      if(busNotifier.operatorDetails.isEmpty) await getOperators();
    });
    super.initState();
    busNotifier.addListener((){
      tryOnly("busNotifier Listens", (){
        if(mounted) {
          setState((){
            selectedOperator = busNotifier.selectedOperator;
            if(selectedOperator != null && selectedOperator!.op.id != null) operatorId = selectedOperator!.op.id!;
          });
        }
      });
    });
  }

  void clearInput(){
    setState(() {
      joinedDate = null;
      operatorId = "";
      selectedOperator = null;
      journeys = 0;
      rank = "Junior";
      loading = false;
    });
  }

  bool validateForm(){
    return rank.isNotEmpty && addedBy != null && operatorId.isNotEmpty &&
      joinedDate != null && journeys >= 0 && isSuper;
  }


  Future<void> getOperators() async {
    if(busNotifier.operatorDetails.isEmpty){
      await tryAsync("getOperators", () async {
        if(mounted) setState(() => loading = true);
        await busNotifier.getOperators();
        if(mounted) setState(() => loading = false);
      }, error: (){
        if(mounted) setState(() => loading = false);
      });
    }
  }


  Future<void> addNewDriver() async {
    if(busNotifier.busOperatorId != null && busNotifier.isActive){
      await tryAsync("addNewDriver", () async {
        if(mounted) setState(() => loading = true);
        BusBrandDriver newDr = BusBrandDriver(
          operatorId: operatorId,
          joinedDate: joinedDate!,
          addedBy: busNotifier.busOperatorId!,
          rank: rank,
          journeys: journeys
        );
        BusBrandDriver? dr = await busNotifier.createNewDriver(newDr);
        if(dr != null && mounted){
          iCloud.showSnackBar("Driver Created", context,title: "Success", type: 2);
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
      builder: (BuildContext context) => BusSelectOperatorsComponent(
        onlyRole: "driver",
        excludeIds: excludeIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: isSuper?
        (
            loading? Center(
              child: LoadingComponent(
                isShimmer: false,
                size: 50,
                spinnerColor: prudColorTheme.bgA,
              ),
            )
                :
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
                          child: selectedOperator != null? OperatorComponent(operator: selectedOperator!) : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Translate(
                                  text: "Click & Select Operator"
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
                PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Rank *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilder(
                          child: FormBuilderChoiceChip(
                            decoration: getDeco("Rank"),
                            backgroundColor: prudColorTheme.bgA,
                            disabledColor: prudColorTheme.bgD,
                            spacing: spacer.width.width!,
                            shape: prudWidgetStyle.choiceChipShape,
                            selectedColor: prudColorTheme.primary,
                            onChanged: (String? selected){
                              tryOnly("RankSelector", (){
                                if(mounted && selected != null){
                                  setState(() {
                                    rank = selected;
                                  });
                                }
                              });
                            },
                            name: "rank",
                            initialValue: rank,
                            options: busNotifier.driverRanks.map((String ele) {
                              return FormBuilderChipOption(
                                value: ele,
                                child: Translate(
                                  text: ele,
                                  style: prudWidgetStyle.btnTextStyle.copyWith(
                                      color: ele == rank?
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
                    title: "Joined Date *",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilderDateTimePicker(
                          initialValue: joinedDate,
                          name: 'joinedDate',
                          style: tabData.npStyle,
                          inputType: InputType.date,
                          keyboardType: TextInputType.datetime,
                          decoration: getDeco(
                              "Joined On",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (DateTime? value){
                            if(mounted && value != null) setState(() => joinedDate = value);
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
                          text: "How many Journeys has this driver made so far while working with your company/brand. ",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: prudColorTheme.textB
                          ),
                          align: TextAlign.center,
                        ),
                        spacer.height,
                        FormBuilderTextField(
                          initialValue: "$journeys",
                          name: 'journeys',
                          style: tabData.npStyle,
                          keyboardType: TextInputType.number,
                          decoration: getDeco(
                              "How Many Journeys Taken",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                          ),
                          onChanged: (String? value){
                            if(mounted && value != null) setState(() => journeys = int.parse(value));
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
                        onPressed: addNewDriver,
                        text: "Add Driver"
                    ) : const SizedBox()
                ),
                largeSpacer.height,
                xLargeSpacer.height,
              ],
            )
        )
            :
        notSuper,
      ),
    );
  }
}
