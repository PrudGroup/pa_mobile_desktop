import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import 'inner_menu.dart';

class MiddleMenuView extends StatefulWidget{

  final List<InnerMenuItem> topMenus;
  final List<InnerMenuItem> bottomMenus;
  final int type; //0 => Inner, 1 => deep
  final bool hasIcon;

  MiddleMenuView({
    super.key,
    required this.topMenus,
    required this.bottomMenus,
    this.type = 0,
    this.hasIcon = false
  })
      : assert(topMenus.isNotEmpty && bottomMenus.isNotEmpty);

  @override
  MiddleMenuViewState createState() => MiddleMenuViewState();
}

class MiddleMenuViewState extends State<MiddleMenuView> {

  Widget? _topWidget;
  Widget? _bottomWidget;
  int? selectedTopIndex;
  int? selectedBottomIndex;

  void changeTopWidget(Widget dWidget, int index) => Future.delayed(Duration.zero, (){
    if(mounted) {
      setState((){
        _topWidget = dWidget;
        selectedTopIndex = index;
      });
    }
  });

  void changeBottomWidget(Widget dWidget, int index) => Future.delayed(Duration.zero, (){
    if(mounted) {
      setState((){
        _bottomWidget = dWidget;
        selectedBottomIndex = index;
      });
    }
  });

  @override
  void initState() {
    super.initState();
    changeTopWidget(widget.topMenus[0].menu, 0);
    changeBottomWidget(widget.bottomMenus[0].menu, 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: _topWidget ?? const SizedBox(),
        ),
        Container(
          height: 60,
          color: widget.type == 0? prudTheme.cardColor : prudTheme.colorScheme.onSurface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.topMenus.length,
            itemBuilder: (context, int index) => GFButton(
              onPressed: () => changeTopWidget(widget.topMenus[index].menu, index),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: widget.type == 0? prudTheme.cardColor : prudTheme.colorScheme.onSurface,
              hoverColor: widget.type == 0? prudTheme.colorScheme.onSurface.withValues(alpha: 0.7) : prudTheme.cardColor.withValues(alpha: 0.7),
              splashColor: widget.type == 0? prudTheme.colorScheme.onSurface.withValues(alpha: 0.7) : prudTheme.cardColor.withValues(alpha: 0.7),
              shape: GFButtonShape.square,
              elevation: 0.0,
              icon: widget.hasIcon? (
                  widget.topMenus[index].imageIcon == null?
                  Icon(
                    widget.topMenus[index].icon,
                    color: selectedTopIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
                  )
                      :
                  ImageIcon(
                    AssetImage(widget.topMenus[index].imageIcon!),
                    color: selectedTopIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
                  )
              ) : const SizedBox(),
              hoverElevation: 0.0,
              focusElevation: 0.0,
              size: GFSize.LARGE,
              text: widget.topMenus[index].title,
              textColor: selectedTopIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
              child: const Center(),
            ),
          ),
        ),
        Divider(
          color: prudTheme.primaryColor,
          thickness: 1.3,
          height: 2.0,
        ),
        Container(
          height: 60,
          color: widget.type == 0? prudTheme.cardColor : prudTheme.colorScheme.onSurface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.bottomMenus.length,
            itemBuilder: (context, int index) => GFButton(
              onPressed: () => changeBottomWidget(widget.bottomMenus[index].menu, index),
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              color: widget.type == 0? prudTheme.cardColor : prudTheme.colorScheme.onSurface,
              hoverColor: widget.type == 0? prudTheme.colorScheme.onSurface.withValues(alpha: 0.7) : prudTheme.cardColor.withValues(alpha: 0.7),
              splashColor: widget.type == 0? prudTheme.colorScheme.onSurface.withValues(alpha: 0.7) : prudTheme.cardColor.withValues(alpha: 0.7),
              shape: GFButtonShape.square,
              elevation: 0.0,
              icon: widget.hasIcon? (
                  widget.bottomMenus[index].imageIcon == null?
                  Icon(
                    widget.bottomMenus[index].icon,
                    color: selectedBottomIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
                  )
                      :
                  ImageIcon(
                    AssetImage(widget.bottomMenus[index].imageIcon!),
                    color: selectedBottomIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
                  )
              ) : const SizedBox(),
              hoverElevation: 0.0,
              focusElevation: 0.0,
              size: GFSize.LARGE,
              text: widget.bottomMenus[index].title,
              textColor: selectedBottomIndex == index? prudTheme.indicatorColor : prudTheme.primaryColor,
              child: const Center(),
            ),
          ),
        ),
        Expanded(
          child: _bottomWidget?? const SizedBox(),
        ),
      ],
    );
  }
}
