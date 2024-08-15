import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/models/theme.dart';

import '../singletons/i_cloud.dart';
import '../singletons/shared_local_storage.dart';

class InnerMenu extends StatefulWidget {
  final List<InnerMenuItem> menus;
  final int type; //0 => Inner, 1 => deep
  final bool hasIcon;
  final int activeTab;

  const InnerMenu({super.key, required this.menus, this.type = 0, this.hasIcon= false, this.activeTab = 0});

  @override
  InnerMenuState createState() => InnerMenuState();
}

class InnerMenuItem{
  final String title;
  final Widget menu;
  final IconData? icon;
  final String? imageIcon;


  InnerMenuItem({required this.title, required this.menu, this.icon, this.imageIcon});
}

class InnerMenuState extends State<InnerMenu> {
  Widget? _widget;
  int selectedIndex = 0;
  bool showMenu = iCloud.showInnerTabsAndMenus;

  void changeWidget(Widget dWidget, int index) => Future.delayed(Duration.zero, (){
    if(mounted) {
      setState((){
        _widget = dWidget;
        selectedIndex = index;
      });
    }
  });

  @override
  void initState() {
    super.initState();
    changeWidget(widget.menus[widget.activeTab].menu, widget.activeTab);
    iCloud.addListener(() {
      try{
        if(showMenu != iCloud.showInnerTabsAndMenus && mounted) {
          Future.delayed(Duration.zero, () =>
            setState(() => showMenu = iCloud.showInnerTabsAndMenus));
        }
      }catch(ex){
        debugPrint("State Management Error: $ex");
      }
    });
  }

  @override
  void dispose() {
    iCloud.removeListener(() { });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color highLev = prudColorTheme.iconD;
    Color lowLev = prudColorTheme.lineC;
    return Column(
      children: [
        if(showMenu) Container(
          height: 60,
          color: widget.type == 0? highLev : lowLev,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.menus.length,
            itemBuilder: (context, int index) => GFButton(
              onPressed: () => changeWidget(widget.menus[index].menu, index),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: widget.type == 0? highLev : lowLev,
              hoverColor: widget.type == 0? lowLev.withOpacity(0.7) : highLev.withOpacity(0.7),
              splashColor: widget.type == 0? lowLev.withOpacity(0.7) : highLev.withOpacity(0.7),
              shape: GFButtonShape.square,
              elevation: 0.0,
              icon: widget.hasIcon? (
                  widget.menus[index].imageIcon == null?
                  Icon(
                    widget.menus[index].icon,
                    color: selectedIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
                  )
                      :
                  ImageIcon(
                    AssetImage(widget.menus[index].imageIcon!),
                    color: selectedIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
                  )
              ) : const SizedBox(),
              hoverElevation: 0.0,
              focusElevation: 0.0,
              size: GFSize.LARGE,
              text: widget.menus[index].title,
              textColor: selectedIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
              child: const Center(),
            ),
          ),
        ),
        Expanded(
          child: Listener(
            onPointerMove: (moveEvent){
              if(moveEvent.delta.dx > 0) {
                int newIndex = selectedIndex - 1;
                if(newIndex >= 0){
                  changeWidget(widget.menus[newIndex].menu, newIndex);
                }
              }
              if(moveEvent.delta.dx < 0){
                int newIndex = selectedIndex + 1;
                if(newIndex < widget.menus.length){
                  changeWidget(widget.menus[newIndex].menu, newIndex);
                }
              }
            },
            child: _widget?? const SizedBox() // or any other widget
          )
        ),
      ],
    );
  }
}
