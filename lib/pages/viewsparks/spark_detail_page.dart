import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/translate.dart';
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
  bool linkExist = false;

  Future<bool> createAffLink() async {
    bool created = false;
    if(myStorage.user != null && myStorage.user!.id != null && widget.spark.id != null) {
      try{
        String url = "$apiEndPoint/sparks/spk_aff_links/${widget.spark.id}/${myStorage.user!.id}";
        Response res = await prudDio.get(url);
        if(res.statusCode == 200){
          created = res.data;
        }
      }catch(ex){
        debugPrint("createAffLink Error: $ex");
      }
    }
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
        if(res.statusCode == 200){
          result = res.data;
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
        actions: [
          checkingLink? SpinKitFadingCircle(
            color: prudColorTheme.textHeader,
            size: 25
          ) :
          (
            widget.canCreateAffLink && linkExist? getTextButton(
              title: "Create Aff Link",
              color: prudColorTheme.textHeader,
              onPressed: createAffLink
            ) : const SizedBox()
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            spacer.height,
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: prudWidgetStyle.getLongButton(
                onPressed: gotoUrl,
                text: "Watch/Visit Now",
                shape: 1
              ),
            ),
          ],
        ),
      ),
    );
  }
}