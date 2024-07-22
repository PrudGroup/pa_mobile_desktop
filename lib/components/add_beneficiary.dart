
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/pages/beneficiaries/my_beneficiaries.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';

import '../models/theme.dart';
import 'translate.dart';

class AddBeneficiary extends StatefulWidget {
  const AddBeneficiary({super.key});

  @override
  AddBeneficiaryState createState() => AddBeneficiaryState();
}

class AddBeneficiaryState extends State<AddBeneficiary> {
  List<Beneficiary> selectedBeneficiaries = beneficiaryNotifier.selectedBeneficiaries;

  final RestrictedPositions settings = RestrictedPositions(
    maxCoverage: 0.3,
    minCoverage: 0.2,
    align: StackAlign.left,
    infoIndent: 15,
  );

  void showBeneficiaryModel(){
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgA,
      elevation: 5,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: prudRad,
      ),
      builder: (BuildContext context) {
        return const MyBeneficiaries(isPage: false);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    beneficiaryNotifier.addListener((){
      if(mounted){
        setState(() {
          selectedBeneficiaries = beneficiaryNotifier.selectedBeneficiaries;
        });
      }
    });
  }

  @override
  void dispose() {
    beneficiaryNotifier.removeListener((){});
    super.dispose();
  }

  ImageProvider<Object> getAvatar(Beneficiary ben) {
    dynamic avatar = ben.isAvatar? AssetImage(ben.avatar) : MemoryImage(ben.photo);
    return avatar;
  }

  Widget _infoWidget(int surplus, BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '+$surplus',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return PrudPanel(
      title: "Add Beneficiary",
      titleColor: prudColorTheme.textB,
      bgColor: prudColorTheme.bgC,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 15),
        child: Column(
          children: [
            spacer.height,
            if(selectedBeneficiaries.isNotEmpty) AvatarStack(
              height: 50,
              settings: settings,
              infoWidgetBuilder: (surplus) => _infoWidget(surplus, context),
              avatars: [for (var n = 0; n < selectedBeneficiaries.length; n++) getAvatar(selectedBeneficiaries[n])],
            ),
            if(selectedBeneficiaries.isEmpty) Translate(
              text: "Beneficiaries you intend to send this gift card will appear you. start adding beneficiaries.",
              align: TextAlign.center,
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 12
              )
            ),
            Divider(
              height: 15,
              thickness: 2.0,
              indent: 20,
              endIndent: 20,
              color: prudColorTheme.lineC,
            ),
            Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: showBeneficiaryModel,
                  text: "Add Beneficiary"
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
