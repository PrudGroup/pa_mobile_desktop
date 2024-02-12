import 'package:flutter/material.dart';
import 'package:prudapp/components/translate.dart';
import 'package:prudapp/models/theme.dart';

import '../singletons/i_cloud.dart';

class SideMenuItem extends StatelessWidget {
  final Widget page;
  final bool isIcon;
  final IconData? icon;
  final String? image;
  final String text;

  const SideMenuItem({
    Key? key,
    required this.text,
    required this.page,
    this.icon,
    this.image,
    this.isIcon = true,
  }) : assert(isIcon? icon != null : image != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => iCloud.goto(context, page),
      leading: isIcon? Icon(icon, color: Colors.black,) : Image(
        image: AssetImage(image!),
        width: 30,
      ),
      title: Translate(
        text: text,
        style: pagadoWidgetStyle.typedTextStyle,
      ),
    );
  }
}
