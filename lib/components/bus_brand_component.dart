import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';

class BusBrandComponent extends StatelessWidget {
  final BusBrand brand;

  const BusBrandComponent({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GFAvatar(
          size: GFSize.SMALL,
          backgroundColor: prudColorTheme.lineC,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: PrudNetworkImage(
              url: brand.logo,
              width: 40,
            ),
          ),
        ),
        spacer.height,
        Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tabData.shortenStringWithPeriod(brand.brandName, length: 30),
              style: prudWidgetStyle.typedTextStyle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: prudColorTheme.textA
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  GFRating(
                    onChanged: (rate){},
                    value: brand.getRating(),
                    size: 18,
                  ),
                  spacer.width,
                  Translate(
                    text: tabData.getRateInterpretation(brand.getRating()),
                    style: prudWidgetStyle.hintStyle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: prudColorTheme.success
                    ),
                  )
                ],
              ),
            ),
            if(brand.slogan != null) Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SizedBox(
                width: screen.width - 100,
                child: Text(
                  "${brand.slogan}",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: prudColorTheme.textB
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
