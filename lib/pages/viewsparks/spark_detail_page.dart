import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/components/prud_panel.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/modals/link_modal_sheet.dart';
import '../../components/translate.dart';
import '../../models/aff_link.dart';
import '../../models/spark.dart';
import '../../models/theme.dart';
import '../../singletons/shared_local_storage.dart';
import '../../singletons/tab_data.dart';

class SparkDetailPage extends StatefulWidget {

  final Spark spark;
  final bool canCreateAffLink;

  const SparkDetailPage({
    super.key,
    required this.spark,
    this.canCreateAffLink = false,
  });

  @override
  SparkDetailPageState createState() => SparkDetailPageState();
}

class SparkDetailPageState extends State<SparkDetailPage> {
  bool checkingLink = false;
  AffLink? affLink;
  bool linkExist = false;
  bool creatingLink = false;
  BorderRadiusGeometry rad = const BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(30),
  );

  void showLinkDetails(double height) {
    if(affLink != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: prudColorTheme.bgA,
        elevation: 10,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: rad,
        ),
        builder: (BuildContext context) => Scaffold(
          body: LinkModalSheet(
            affLink: affLink!,
            radius: rad,
            height: height,
          ),
        ),
      );
    }
  }

  Future<bool> createAffLink() async {
    bool created = false;
    if(myStorage.user != null && myStorage.user!.id != null && widget.spark.id != null) {
      try{
        if(mounted) setState(() => creatingLink = true);
        String url = "$apiEndPoint/sparks/spk_aff_links/";
        AffLink afLink = AffLink(sparkId: widget.spark.id, affId: myStorage.user!.id);
        Response res = await prudDio.post(url, data: afLink.toJson());
        if(res.statusCode == 201 && mounted){
          created = true;
          setState(() {
            affLink = AffLink.fromJson(res.data);
            linkExist = true;
          });
        }
      }catch(ex){
        debugPrint("createAffLink Error: $ex");
      }
    }
    if(mounted) setState(() => creatingLink = false);
    return created;
  }

  Future<void> gotoUrl() async {
    String? link = widget.spark.targetLink;
    if(link != null) {
      final Uri url = Uri.parse(link);
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  Future<bool> checkIfAffLinkExists() async {
    bool result = false;
    if(myStorage.user != null && myStorage.user!.id != null && widget.spark.id != null) {
      try{
        String url = "$apiEndPoint/sparks/spk_aff_links/check_if_exists/${widget.spark.id}/${myStorage.user!.id}";
        Response res = await prudDio.get(url);
        debugPrint("Result: ${res.data}: ${res.statusCode}");
        if(res.statusCode == 200){
          if(res.data != false){
            result = true;
            if(mounted) setState(() => affLink = AffLink.fromJson(res.data));
          }
        }
      }catch(ex){
        debugPrint("checkIfAffLinkExists Error: $ex");
      }
    }
    return result;
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async {
      // if(to)
      if(mounted) setState(() => checkingLink = true);
      bool exists = await checkIfAffLinkExists();
      if(mounted){
        setState(() {
          linkExist = exists;
          checkingLink = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        backgroundColor: prudColorTheme.primary,
        title: Wrap(
          direction: Axis.vertical,
          spacing: 2,
          children: [
            Translate(
              text: tabData.shortenStringWithPeriod(widget.spark.title!),
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 16,
                color: prudColorTheme.bgA
              ),
            ),
            SizedBox(
              width: 180,
              child: Translate(
                text: tabData.shortenStringWithPeriod(
                  "${widget.spark.sparkCategory} | ${widget.spark.status} | ${widget.spark.targetSparks} sparks targeted",
                  length: 50
                ),
                style: prudWidgetStyle.tabTextStyle.copyWith(
                  fontSize: 10,
                  color: prudColorTheme.textA
                ),
              ),
            ),
          ]
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            spacer.height,
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                children: [
                  PrudDataViewer(field: "Status", value: widget.spark.status),
                  spacer.width,
                  PrudDataViewer(field: "Sparks Achieved", value: widget.spark.sparksCount),
                  spacer.width,
                  PrudDataViewer(field: "Target", value: "${widget.spark.targetSparks}"),
                  spacer.height,
                ],
              ),
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(widget.canCreateAffLink) Expanded(
                    child: checkingLink? SpinKitFadingCircle(
                      color: prudColorTheme.textHeader,
                      size: 25
                    ) :
                    (
                      linkExist? prudWidgetStyle.getLongButton(
                        onPressed: () => showLinkDetails(screen.height * 0.75),
                        text: "Check Link",
                        shape: 2,
                        makeLight: true
                      ) : (
                        creatingLink? SpinKitFadingCircle(
                          color: prudColorTheme.textHeader,
                          size: 25
                        ) : prudWidgetStyle.getLongButton(
                          onPressed: createAffLink,
                          text: "Create Affiliate Link",
                          shape: 2,
                          makeLight: true
                        )
                      )
                    ),
                  ),
                  Expanded(
                    child: prudWidgetStyle.getLongButton(
                      onPressed: gotoUrl,
                      text: "Watch/Visit Now",
                      shape: 2
                    ),
                  )
                ],
              ),
            ),
            spacer.height,
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                children: [
                  PrudDataViewer(field: "Type", value: widget.spark.sparkType),
                  spacer.width,
                  PrudDataViewer(field: "Category", value: widget.spark.sparkCategory),
                  spacer.width,
                  PrudDataViewer(field: "Targeted Sparks", value: widget.spark.targetSparks),
                ],
              ),
            ),
            spacer.height,
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: PrudPanel(
                title: "Description",
                bgColor: prudColorTheme.bgC,
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                        child: Translate(
                          text: "${widget.spark.description}",
                          align: TextAlign.center,
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.iconB,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
            spacer.height,
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(10),
                children: [
                  PrudDataViewer(field: "Coverage", value: widget.spark.locationTarget),
                  spacer.width,
                  PrudDataViewer(field: "Duration (Months)", value: widget.spark.duration),
                  spacer.width,
                  PrudDataViewer(field: "Month/Year", value: "${widget.spark.monthCreated}/${widget.spark.yearCreated}"),
                  spacer.height,
                ],
              ),
            ),
            spacer.height,
            if(widget.spark.targetCountries.isNotEmpty) Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: PrudPanel(
                title: "Targeted Countries",
                bgColor: prudColorTheme.bgC,
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Translate(
                        text: widget.spark.targetCountries.join(", "),
                        align: TextAlign.center,
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.iconB,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
            if(widget.spark.targetCountries.isNotEmpty) spacer.height,
            if(widget.spark.targetStates.isNotEmpty) Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: PrudPanel(
                title: "Targeted States",
                bgColor: prudColorTheme.bgC,
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Translate(
                        text: widget.spark.targetStates.join(", "),
                        align: TextAlign.center,
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.iconB,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
            if(widget.spark.targetStates.isNotEmpty) spacer.height,
            if(widget.spark.targetCities.isNotEmpty) Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: PrudPanel(
                title: "Targeted Cities",
                bgColor: prudColorTheme.bgC,
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Translate(
                        text: widget.spark.targetCities.join(", "),
                        align: TextAlign.center,
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.iconB,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
            if(widget.spark.targetCities.isNotEmpty) spacer.height,
            if(widget.spark.targetTowns.isNotEmpty) Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: PrudPanel(
                title: "Targeted Towns",
                bgColor: prudColorTheme.bgC,
                child: Column(
                  children: [
                    spacer.height,
                    SizedBox(
                      child: Translate(
                        text: widget.spark.targetTowns.join(", "),
                        align: TextAlign.center,
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                          color: prudColorTheme.iconB,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
            if(widget.spark.targetTowns.isNotEmpty) spacer.height,
            largeSpacer.height,
          ],
        ),
      ),
    );
  }
}