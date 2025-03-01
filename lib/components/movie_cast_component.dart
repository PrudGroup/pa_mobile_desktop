import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/components/prud_network_image.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class MovieCastComponent extends StatelessWidget {
  final bool isClickable;
  final VideoMovieCast cast;

  const MovieCastComponent({ super.key, required this.isClickable, required this.cast });
  
  void openModalSheet() {
    // TODO: Implement modal sheet for cast details
  }

  @override
  Widget build(BuildContext context) {
    Widget dCast = Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 150,
          width: 70,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(color: prudColorTheme.lineC, width: 2,),
            borderRadius: BorderRadius.circular(15),
            color: prudColorTheme.lineC,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: PrudNetworkImage(
              url: cast.castPhotoUrl,
              authorizeUrl: true,
              width: 70,
              height: 150,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 90),
          child: Container(
            height: 60,
            width: 70,
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: prudColorTheme.lineC, width: 2,),
              borderRadius: BorderRadius.circular(15),
              color: prudColorTheme.lineC.withValues(alpha: 0.8),
            ),
            child: Stack(
              children: [
                Text(
                  tabData.shortenStringWithPeriod(cast.fullname, length: 20),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: prudColorTheme.secondary,
                  ),
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GFRating(
                        onChanged: (rate){},
                        value: cast.getRating(),
                        size: 10,
                      ),
                      Text(
                        "${cast.getRating()}",
                        style: prudWidgetStyle.hintStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: prudColorTheme.primary,
                        ),
                        textAlign: TextAlign.right,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: FittedBox(
                    child: Row(
                      children: [
                        Translate(
                          text: 'Role:',
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textB,
                          ),
                        ),
                        spacer.width,
                        Text(
                          cast.roleName,
                          style: prudWidgetStyle.hintStyle.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: prudColorTheme.textA,
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ],
    );
    return isClickable? InkWell(
      onTap: openModalSheet,
      child: dCast,
    ) : dCast;
  }
}