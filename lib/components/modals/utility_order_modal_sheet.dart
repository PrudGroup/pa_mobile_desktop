import 'package:flutter/material.dart';
import 'package:prudapp/models/reloadly.dart';

import '../../models/theme.dart';
import '../../singletons/i_cloud.dart';
import '../loading_component.dart';
import '../prud_showroom.dart';

class UtilityOrderModalSheet extends StatefulWidget {
  final UtilityOrder order;
  final double amountToPay;
  final double customerDiscount;
  final String currencyCode;

  const UtilityOrderModalSheet({
    super.key, required this.order,
    required this.amountToPay,
    required this.customerDiscount,
    required this.currencyCode
  });

  @override
  UtilityOrderModalSheetState createState() => UtilityOrderModalSheetState();
}

class UtilityOrderModalSheetState extends State<UtilityOrderModalSheet> {
  bool loading = true;
  List<Widget> showroom = [];

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      if(mounted) {
        setState(() {
          showroom = iCloud.getShowroom(context,showroomItems: 4);
        });
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double height = screen.height * 0.75;
    return Container(
      height: height,
      decoration: BoxDecoration(
          color: prudColorTheme.bgC,
          borderRadius: prudRad
      ),
      child: ClipRRect(
          borderRadius: prudRad,
          child: SizedBox(
            height: double.maxFinite,
            child: Column(
              children: [
                if(loading) const LoadingComponent(
                  isShimmer: false,
                  size: 30,
                  defaultSpinnerType: false,
                ),
                if(loading) Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: PrudShowroom(items: showroom,),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
