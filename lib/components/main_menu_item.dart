import 'package:flutter/material.dart';
import 'package:prudapp/components/main_menu.dart';
import 'package:prudapp/components/translate.dart';
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
            width: 90.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: obj.bgColor,
              // border: Border.all(color: prudColorScheme.lineB,width: 5,),
              // borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Image(
                image: AssetImage(obj.menu.icon),
                width: 80.0,
              ),
            ),
          ),
          Translate(
            text: obj.menu.title,
            style: pagadoWidgetStyle.tabTextStyle,
            align: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
