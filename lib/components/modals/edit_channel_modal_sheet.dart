import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../models/theme.dart';

class EditChannelModalSheet extends StatefulWidget {
  final double height;
  final String editType;
  final BorderRadiusGeometry radius;
  final VidChannel channel;
  


  const EditChannelModalSheet({
    super.key,
    required this.editType,
    required this.radius,
    required this.height,
    required this.channel,
  });

  @override
  EditChannelModalSheetState createState() => EditChannelModalSheetState();
}

class EditChannelModalSheetState extends State<EditChannelModalSheet> {

  TextEditingController txtCtrl = TextEditingController();
  double memberCost = 0;
  double membershipCostInEuro = 0;
  bool validated = false;
  bool saving = false;

  Future<bool> validateMemberCost() async {
    if(memberCost > 0){
      if(widget.channel.channelCurrency.toUpperCase() == "EUR"){
        membershipCostInEuro = memberCost;
        return memberCost >= 1.0 && memberCost <= 5.0;
      }else{
        double amount = await currencyMath.convert(
          amount: memberCost,
          quoteCode: "EUR",
          baseCode: widget.channel.channelCurrency
        );
        membershipCostInEuro = currencyMath.roundDouble(amount, 2);
        return amount >= 1.0 && amount <= 5.0;
      }
    }else{
      return false;
    }
  }

  Future<void> saveMembershipCost() async{
    await tryAsync("saveMembershipCost", () async {
      if(mounted) setState(() => saving = true);
      
    }, error: (){
      if(mounted) setState(() => saving = false);
    });
  }


  @override
  void initState() {
    super.initState();
    txtCtrl.text = widget.channel.monthlyMembershipCost.toString();
  }

  @override
  void dispose() {
    txtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadiusGeometry rad = widget.radius;
    double height = widget.height * 0.6;
    return ClipRRect(
      borderRadius: rad,
      child: Container(
        height: height,
        constraints: BoxConstraints(maxHeight: height),
        decoration: BoxDecoration(
          borderRadius: rad,
          color: prudColorTheme.bgC
        ),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              spacer.height,
              if(widget.editType == "membership_cost") Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  spacer.height,
                  Translate(
                    text: "How much would you charge for monthly membership subscription on "
                        "this channel? You must make sure that the amount is not less than 1(EURO) and not greater "
                        "than 5(Euro) in the currency of your channel.",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.textA,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    align: TextAlign.center,
                  ),
                  spacer.height,
                  PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    title: "Membership Cost(${widget.channel.channelCurrency})",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.end,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        FormBuilder(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: FormBuilderTextField(
                            controller: txtCtrl,
                            autofocus: true,
                            name: 'membershipCost',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.number,
                            decoration: getDeco(
                              "How Much",
                              onlyBottomBorder: true,
                              borderColor: prudColorTheme.lineC
                            ),
                            onChanged: (String? value) async {
                              await tryAsync("onChange", () async {
                                if(mounted && value != null && value.isNotEmpty) setState(() => memberCost = currencyMath.roundDouble(double.parse(value.trim()), 2));
                                bool cleared = await validateMemberCost();
                                if(mounted) setState(() => validated = cleared);
                              });
                            },
                            valueTransformer: (text) => num.tryParse(text!),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                            ]),
                          ),
                        ),
                        spacer.height,
                      ],
                    )
                  ),
                  spacer.height,
                  if(validated) prudWidgetStyle.getLongButton(
                    onPressed: saveMembershipCost, 
                    text: "Save Changes"
                  )
                ],
              ),
              if(widget.editType == "creator_membership_share") Column(),
              if(widget.editType == "streaming_cost") Column(),
              xLargeSpacer.height,
            ],
          ),
        )
      ),
    );
  }
}
