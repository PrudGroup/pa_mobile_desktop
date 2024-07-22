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
import '../giftcards/gift_cards.dart';
import '../recharge/recharge.dart';
import '../settings/legal.dart';
import '../support/support.dart';
import '../travels/switz_travels.dart';

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
                maxHeight: 60.0,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(
                prudImages.logo,
                width: 50.0,
                fit: BoxFit.contain
              ),
            ),
            Divider(
              height: 10.0,
              thickness: 3.0,
              indent: 0.0,
              endIndent: 0.0,
              color: prudColorTheme.primary
            ),
            SideMenuItem(
              text: "Gift Cards",
              page: const GiftCards(),
              isIcon: false,
              image: prudImages.gift,
            ),
            SideMenuItem(
              text: "Airtime",
              page: const Recharge(tab: 0,),
              isIcon: false,
              image: prudImages.airtime,
            ),
            SideMenuItem(
              text: "Data Bundles",
              page: const Recharge(tab: 1,),
              isIcon: false,
              image: prudImages.dataBundle,
            ),
            SideMenuItem(
              text: "Bills & Utilities",
              page: const Recharge(tab: 2,),
              isIcon: false,
              image: prudImages.smartTv1,
            ),
            Divider(
              height: 3.0,
              thickness: 1.0,
              indent: 0.0,
              endIndent: 0.0,
              color: prudColorTheme.secondary
            ),
            SideMenuItem(
              text: "SwitzTravels",
              page: const SwitzTravels(),
              isIcon: false,
              image: prudImages.travel1,
            ),
            SideMenuItem(
              text: "Flights",
              page: const SwitzTravels(tab: 1,),
              isIcon: false,
              image: prudImages.flight,
            ),
            SideMenuItem(
              text: "Buses",
              page: const SwitzTravels(tab: 0,),
              isIcon: false,
              image: prudImages.transport,
            ),
            SideMenuItem(
              text: "Hotels",
              page: const SwitzTravels(tab: 2,),
              isIcon: false,
              image: prudImages.resort,
            ),
            Divider(
              height: 3.0,
              thickness: 1.0,
              indent: 0.0,
              endIndent: 0.0,
              color: prudColorTheme.secondary
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
            Divider(
              height: 3.0,
              thickness: 1.0,
              indent: 0.0,
              endIndent: 0.0,
              color: prudColorTheme.secondary
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
