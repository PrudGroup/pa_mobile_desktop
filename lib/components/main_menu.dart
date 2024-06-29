import 'package:flutter/material.dart';
import 'package:prudapp/components/main_menu_item.dart';

class Menu{
  String title;
  Widget page;
  String icon;

  Menu({required this.title, required this.page, required this.icon});
}

class MainMenuItemObject{
  Menu menu;
  Color bgColor;

  MainMenuItemObject({required this.menu, required this.bgColor});
}

class MainMenu extends StatelessWidget {
  final List<Menu> menus;
  final Color bgColor;
  final bool useWrap;

  const MainMenu({
    super.key,
    required this.menus,
    this.bgColor = Colors.transparent,
    this.useWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return useWrap? Wrap(
      direction: Axis.horizontal,
      runSpacing: 10.0,
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.start,
      children: menus.map((menu) => MainMenuItem(
        obj: MainMenuItemObject(
          menu: menu,
          bgColor: bgColor
        ),
      )).toList(),
    )
        :
    GridView.builder(
      itemCount: menus.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10.0,
      ),
      itemBuilder: (BuildContext ctx, index){
        return MainMenuItem(
          obj: MainMenuItemObject(
            menu: menus[index],
            bgColor: bgColor
          ),
        );
      }
    );
  }
}
