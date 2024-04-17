import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/register/login.dart';
import 'package:prudapp/pages/settings/policy.dart';
import 'package:prudapp/pages/settings/settings.dart';
import 'package:prudapp/pages/shippers/shippers.dart';
import 'package:prudapp/pages/shorteners/shortener.dart';
import 'package:prudapp/pages/switzstores/switz_stores.dart';
import 'package:prudapp/pages/viewsparks/view_spark.dart';

import '../../components/side_menu_item.dart';
import '../../models/images.dart';
import '../ads/ads.dart';
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
              constraints: const BoxConstraints(
                maxHeight: 120.0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                prudImages.logo,
                width: 100.0,
                fit: BoxFit.contain
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
              text: "Ads & Promotions",
              page: const Ads(),
              isIcon: false,
              image: prudImages.videoAd,
            ),
            SideMenuItem(
              text: "Views & Audience",
              page: const ViewSpark(),
              isIcon: false,
              image: prudImages.watchVideo,
            ),
            SideMenuItem(
              text: "Switz Stores",
              page: const SwitzStores(),
              isIcon: false,
              image: prudImages.stores,
            ),
            SideMenuItem(
              text: "Shortener",
              page: const Shortener(),
              isIcon: false,
              image: prudImages.shortener,
            ),
            SideMenuItem(
              text: "Shippers & Delivery",
              page: const Shippers(),
              isIcon: false,
              image: prudImages.shipper,
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
            const SideMenuItem(
              text: "LogIn",
              page: Login(),
              isIcon: true,
              icon: Icons.signpost_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
