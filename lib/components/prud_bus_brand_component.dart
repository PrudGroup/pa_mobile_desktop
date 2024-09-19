import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/models/theme.dart';

import '../models/bus_models.dart';

class PrudBusBrandComponent extends StatelessWidget {
  final BusBrand brand;

  const PrudBusBrandComponent({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GFAvatar(
          size: GFSize.MEDIUM,
          backgroundColor: prudColorTheme.lineC,
          child: PrudNetworkImage(url: brand.logo, width: 30,),
        ),
        spacer.height,
        GFRating(
          onChanged: (rate){},
          value: brand.getRating(),
          size: 18,
        ),
        SizedBox(
          width: 100,
          child: Text(
            brand.brandName,
            style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: prudColorTheme.success,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
