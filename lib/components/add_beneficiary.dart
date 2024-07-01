import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_panel.dart';

import '../models/theme.dart';

class AddBeneficiary extends StatefulWidget {
  const AddBeneficiary({super.key});

  @override
  AddBeneficiaryState createState() => AddBeneficiaryState();
}

class AddBeneficiaryState extends State<AddBeneficiary> {
  
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

          ],
        ),
      ),
    );
  }
}
