import 'package:flutter/material.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/home/home.dart';
import 'package:prudapp/pages/prudStreams/prud_streams.dart';
import 'package:prudapp/pages/prudStreams/studio/prud_stream_studio.dart';
import 'package:prudapp/pages/prudVid/prud_vid.dart';
import 'package:prudapp/pages/prudVid/prud_vid_studio.dart';
import 'package:prudapp/pages/prudVid/thrillers.dart';
import 'package:prudapp/pages/register/login.dart';
import 'package:prudapp/pages/settings/policy.dart';
import 'package:prudapp/pages/settings/settings.dart';
import 'package:prudapp/pages/shorteners/shortener.dart';

import '../../components/side_menu_item.dart';
import '../../models/images.dart';
import '../ads/ads.dart';
import '../beneficiaries/my_beneficiaries.dart';
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
              text: "Main Menu",
              page: MyHomePage(title: 'Prudapp',),
              isIcon: false,
              image: prudImages.prudIcon,
            ),
            SideMenuItem(
              text: "Thrillers",
              page: const Thrillers(),
              isIcon: false,
              image: prudImages.thriller,
            ),
            SideMenuItem(
              text: "PrudVid",
              page: const PrudVid(),
              isIcon: false,
              image: prudImages.prudVid,
            ),
            SideMenuItem(
              text: "PrudStreams",
              page: const PrudStreams(),
              isIcon: false,
              image: prudImages.stream,
            ),
            SideMenuItem(
              text: "PrudVid Studio",
              page: const PrudVidStudio(),
              isIcon: false,
              image: prudImages.prudVidStudio,
            ),
            SideMenuItem(
              text: "PrudStreams Studio",
              page: const PrudStreamStudio(),
              isIcon: false,
              image: prudImages.streamStudio,
            ),
            SideMenuItem(
              text: "Beneficiaries",
              page: const MyBeneficiaries(),
              isIcon: false,
              image: prudImages.avatar_2,
            ),
            Divider(
              height: 3.0,
              thickness: 1.0,
              indent: 0.0,
              endIndent: 0.0,
              color: prudColorTheme.secondary
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
              text: "Shortener",
              page: const Shortener(),
              isIcon: false,
              image: prudImages.shortener,
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
