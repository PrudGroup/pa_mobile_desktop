import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/settings/policy.dart';
import 'package:prudapp/pages/settings/settings.dart';

import '../../components/side_menu_item.dart';
import '../../models/images.dart';
import '../settings/legal.dart';
import '../support/support.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  HomeDrawerState createState() => HomeDrawerState();
}

class HomeDrawerState extends State<HomeDrawer> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 700,
        child: ListView(
          children: [
            Container(
              width: 200.0,
              margin: const EdgeInsets.only(
                top: 24.0,
                bottom: 64.0,
              ),
              child: Image.asset(
                prudImages.prudIcon,
              ),
            ),
            Divider(
              height: 2.0,
              thickness: 1.0,
              indent: 10.0,
              endIndent: 10.0,
              color: prudColorTheme.lineA
            ),
            SideMenuItem(
              text: "Terms & Conditions",
              page: const LegalPage(),
              isIcon: false,
              image: prudImages.document,
            ),
            SideMenuItem(
              text: "Prud Policies",
              page: const PolicyPage(),
              isIcon: false,
              image: prudImages.document,
            ),
            SideMenuItem(
              text: "Settings",
              page: const Settings(),
              isIcon: false,
              image: prudImages.settings,
            ),
            SideMenuItem(
              text: "Support",
              page: const Support(),
              isIcon: false,
              image: prudImages.support,
            ),
          ],
        ),
      ),
    );
  }
}
