import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/bus_brand_roles_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../../../../components/prud_container.dart';
import '../../../../../components/translate_text.dart';
import '../../../../../singletons/tab_data.dart';

class NewBusBrandOperator extends StatefulWidget {
  final bool isPage;
  const NewBusBrandOperator({super.key, this.isPage = true});

  @override
  NewBusBrandOperatorState createState() => NewBusBrandOperatorState();
}

class NewBusBrandOperatorState extends State<NewBusBrandOperator> {
  String role = "";
  String affId = "";
  bool loading = false;

  void clearInput(){
    if(mounted){
      setState(() {
        role = "";
        affId = "";
        loading = false;
      });
    }
  }


  Future<void> addNewOperator() async {
    if(
      busNotifier.busBrandId != null &&
      busNotifier.busBrandRole != null &&
      busNotifier.busBrandRole!.toLowerCase() == "super" &&
      busNotifier.isActive
    ){
      await tryAsync("addNewOperator", () async {
        if(mounted) setState(() => loading = true);
        BusBrandOperator newOpr = BusBrandOperator(
          affId: affId,
          status: "ACTIVE",
          brandId: busNotifier.busBrandId!,
          role: role
        );
        BusBrandOperator? opr = await busNotifier.createNewOperator(newOpr);
        if(mounted && opr != null) {
          clearInput();
          iCloud.showSnackBar("Created Successfully.", context, title: "Saved", type: 2);
        }else{
          if(mounted) iCloud.showSnackBar("Unable To Create New Operator", context, type: 3);
        }
        if(mounted) setState(() => loading = false);
      }, error: () {
        if(mounted) setState(() => loading = false);
      });
    }
  }


  void getRoles(){
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
      builder: (BuildContext context) => const BusBrandRolesComponent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          spacer.height,
          spacer.height,
          PrudContainer(
            hasTitle: true,
            hasPadding: true,
            title: "Role *",
            titleBorderColor: prudColorTheme.bgC,
            titleAlignment: MainAxisAlignment.end,
            child: Column(
              children: [
                mediumSpacer.height,
                InkWell(
                  onTap: getRoles,
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        child: Row(
                          children: [
                            if(role.isNotEmpty) Text(
                              role,
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 20.0
                              ),
                            ),
                            spacer.width,
                            Translate(
                              text: role.isNotEmpty? role : "Select Role",
                              style: prudWidgetStyle.tabTextStyle.copyWith(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_sharp,
                        size: 20,
                        color: prudColorTheme.lineB,
                      )
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
            title: "Prudapp ID",
            titleBorderColor: prudColorTheme.bgC,
            titleAlignment: MainAxisAlignment.end,
            child: Column(
              children: [
                spacer.height,
                FormBuilderTextField(
                  initialValue: affId,
                  name: 'affiliateId',
                  style: tabData.npStyle,
                  keyboardType: TextInputType.text,
                  decoration: getDeco(
                    "Prudapp Affiliate ID",
                    onlyBottomBorder: true,
                    borderColor: prudColorTheme.lineC
                  ),
                  onChanged: (String? value){
                    if(mounted && value != null) setState(() => affId = value);
                  },
                  valueTransformer: (text) => num.tryParse(text!),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.minLength(3),
                    FormBuilderValidators.maxLength(50),
                    FormBuilderValidators.required(),
                  ]),
                ),
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
            role.isNotEmpty && affId.isNotEmpty? prudWidgetStyle.getLongButton(
              onPressed: addNewOperator,
              text: "Add Operator"
            ) : const SizedBox()
          ),
          largeSpacer.height,
          xLargeSpacer.height,
        ],
      ),
    );

    return widget.isPage? Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "New Operator",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: content,
    ) : content;
  }
}
