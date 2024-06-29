import 'package:flutter/material.dart';

import '../../../../components/Translate.dart';
import '../../../../components/work_in_progress.dart';
import '../../../../models/theme.dart';

class HotelDetails extends StatefulWidget {
  final String hotelId;
  final String? affLinkId;
  const HotelDetails({super.key, required this.hotelId, this.affLinkId});

  @override
  HotelDetailsState createState() => HotelDetailsState();
}

class HotelDetailsState extends State<HotelDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        title: Translate(
          text: "Hotel",
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
