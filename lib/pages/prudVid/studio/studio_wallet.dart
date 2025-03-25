import 'package:flutter/material.dart';

import '../../../components/translate_text.dart';
import '../../../components/work_in_progress.dart';
import '../../../models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class StudioWallet extends StatefulWidget {
  final Function(int)? goToTab;
  const StudioWallet({super.key, this.goToTab});

  @override
  StudioWalletState createState() => StudioWalletState();
}

class StudioWalletState extends State<StudioWallet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Studio Wallet",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}
