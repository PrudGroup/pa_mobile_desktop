import 'dart:io';

import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/models/reloadly.dart';
import 'package:prudapp/pages/beneficiaries/my_beneficiaries.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';

import '../models/theme.dart';

class AddBeneficiary extends StatefulWidget {
  const AddBeneficiary({super.key});

  @override
  AddBeneficiaryState createState() => AddBeneficiaryState();
}

class AddBeneficiaryState extends State<AddBeneficiary> {
  List<Beneficiary> selectedBeneficiaries = beneficiaryNotifier.selectedBeneficiaries;

  final RestrictedPositions settings = RestrictedPositions(
    maxCoverage: 0.3,
    minCoverage: 0.1,
    align: StackAlign.right,
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
        selectedBeneficiaries = beneficiaryNotifier.selectedBeneficiaries;
      }
    });
  }

  @override
  void dispose() {
    beneficiaryNotifier.removeListener((){
      selectedBeneficiaries = [];
    });
    super.dispose();
  }

  Widget getAvatarWidget(Beneficiary ben) {
    dynamic avatar = ben.isAvatar? AssetImage(ben.avatar) : File(ben.avatar);
    return InkWell(
      onDoubleTap: () => beneficiaryNotifier.removeBeneficiary(ben),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GFAvatar(
            backgroundImage: avatar,
            shape: GFAvatarShape.circle,
            size: 60.0,
          ),
          spacer.height,
          SizedBox(
            width: 80,
            child: FittedBox(
              child: Text(
                ben.fullName,
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: prudColorTheme.textB,
                ),
              ),
            ),
          )
        ],
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
            if(selectedBeneficiaries.isNotEmpty) WidgetStack(
              positions: settings,
              stackedWidgets: [for (var n = 0; n < selectedBeneficiaries.length; n++) getAvatarWidget(selectedBeneficiaries[n])],
              buildInfoWidget: (surplus) {
                return Center(
                  child: Text(
                    '+$surplus',
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                );
              },
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
