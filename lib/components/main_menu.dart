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

  const MainMenu({
    super.key,
    required this.menus,
    this.bgColor = Colors.transparent
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: menus.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
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
