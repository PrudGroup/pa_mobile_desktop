import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../models/images.dart';
import '../models/theme.dart';

class BusFeatureComponent extends StatelessWidget {
  final BusFeature feature;

  const BusFeatureComponent({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: prudColorTheme.bgA,
        border: Border(
          bottom: BorderSide(
            color: prudColorTheme.lineC,
            width: 5.0
          )
        )
      ),
      child: Row(
        children: [
          GFAvatar(
            backgroundColor: prudColorTheme.lineC,
            size: GFSize.SMALL,
            child: Center(
              child: ImageIcon(AssetImage(prudImages.videoAd), size: 30,),
            ),
          ),
          spacer.width,
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  feature.featureName,
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.textA,
                    fontSize: 13,
                  ),
                ),
              ),
              GFRating(
                onChanged: (rate){},
                value: feature.getRating(),
                size: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${feature.status} | ${myStorage.ago(dDate: feature.statusDate!, isShort: false)}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.iconC,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    "Fixed: ${feature.fixed} | ${myStorage.ago(dDate: feature.fixedDate!, isShort: false)}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.iconB,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              FittedBox(
                child: Text(
                  feature.description,
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.iconB,
                    fontSize: 9,
                  ),
                ),
              ),
              FittedBox(
                child: Text(
                  feature.howTo,
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.secondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
