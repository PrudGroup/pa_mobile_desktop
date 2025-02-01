import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class SelectableCreatorComponent extends StatelessWidget {

  final Color borderColor;
  final CreatorDetail creator;

  const SelectableCreatorComponent({
    super.key, required this.borderColor, required this.creator,
  });

  @override
  Widget build(BuildContext context) {
    BorderSide bSide = BorderSide(width: 4, color: borderColor);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              border: Border.all(width: 4, color: borderColor),
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: AssetImage(prudImages.user),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Container(
              height: 40,
              width: 90,
              decoration: BoxDecoration(
                border: Border(
                  bottom: bSide,
                  left: bSide,
                  right: bSide
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                gradient: LinearGradient(
                  colors: [
                    borderColor.withValues(alpha: 0.8),
                    borderColor.withValues(alpha: 0.9)
                  ]
                )
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: FittedBox(
                      child: SizedBox(
                        width: 70,
                        child: Text(
                          tabData.shortenStringWithPeriod(creator.detail.fullName!),
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: borderColor == prudColorTheme.primary? prudColorTheme.bgA : prudColorTheme.secondary,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}