import 'package:flutter/material.dart';
import 'package:prudapp/components/main_menu.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';

import '../singletons/i_cloud.dart';

class MainMenuItem extends StatelessWidget {
  final MainMenuItemObject obj;
  const MainMenuItem({super.key, required this.obj});


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => iCloud.goto(context, obj.menu.page),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: prudColorTheme.bgE,
              border: Border.all(color: prudColorTheme.bgD,width: 3,),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: obj.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Image(
                    image: AssetImage(obj.menu.icon),
                    width: 30.0,
                    color: prudColorTheme.primary
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80.0,
            child: Translate(
              text: obj.menu.title,
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              align: TextAlign.center,
            )
          ),
        ],
      ),
    );
  }
}
