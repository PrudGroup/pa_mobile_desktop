import 'package:flutter/material.dart';
import 'package:prudapp/components/page_transitions/scale.dart';

import 'translate_text.dart';

class PrudGridMenuItem{
  final String field;
  final Widget value;
  final Widget page;

  PrudGridMenuItem({
    required this.value,
    required this.field,
    required this.page
  }): assert(field !="");
}

class GridMenuComponent extends StatelessWidget{

  final List<PrudGridMenuItem> menus;
  final double bRadius;
  final Color bgColor;
  final Color fgColor;

  const GridMenuComponent({
    super.key,
    required this.menus,
    this.bRadius= 25,
    this.bgColor= const Color(0xffc3c3c3),
    this.fgColor= const Color(0xff000000),
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 50),
      child: Wrap(
        spacing: 10,
        runSpacing: 20,
        alignment: WrapAlignment.spaceBetween,
        children: menus.map((menu) => InkWell(
          onTap: () => Navigator.push(context, ScaleRoute(page: menu.page)),
          splashColor: bgColor.withOpacity(0.7),
          hoverColor: bgColor.withOpacity(0.7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.6),
                  border: Border.all(color: bgColor, width: 5),
                  borderRadius: BorderRadius.circular(bRadius),
                ),
                child: Center(child: menu.value,),
              ),
              const SizedBox(height: 3,),
              Translate(
                  text: menu.field,
                  align: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      fontFamily: "Party LET",
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none
                  )
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

}
