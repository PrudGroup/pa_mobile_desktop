import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../components/spark_container.dart';
import '../../../components/translate.dart';
import '../../../models/spark.dart';
import '../../../models/theme.dart';
import '../../../singletons/currency_math.dart';
import '../../../singletons/i_cloud.dart';
import '../../../singletons/shared_local_storage.dart';
import '../spark_detail_page.dart';

class MySparks extends StatefulWidget {
  final Function(int)? goToTab;

  const MySparks({super.key, this.goToTab});

  @override
  MySparksState createState() => MySparksState();
}

class MySparksState extends State<MySparks> {

  bool loading = true;
  List<Spark> mySparks = [];
  String? searchText;
  List<Spark> foundSparks = [];
  TextEditingController txtCtrl = TextEditingController();
  int? selectedIndex;
  Widget noSpark = tabData.getNotFoundWidget(
    title: "No Spark",
    desc: "You don't have a spark yet. Create a spark today for your brand and see a drastic change.",
  );
  Widget noSparkFound = tabData.getNotFoundWidget(
    title: "No Spark Found",
    desc: "You have no spark that matches your search criteria. You can create a spark that fits this criteria.",
  );

  void search(){
    if(mounted) setState(() => loading = true);
    if(mySparks.isNotEmpty && searchText != null){
      List<Spark> spks = mySparks.where((Spark spk) =>
        spk.title!.toLowerCase().contains(searchText!.toLowerCase()) ||
          spk.description!.toLowerCase().contains(searchText!.toLowerCase())
      ).toList();
      if(spks.isNotEmpty){
        if(mounted) setState(() => foundSparks = spks);
      }
    }
    if(mounted) setState(() => loading = false);
  }

  void refresh() {
    if(mounted) setState(() => searchText = null);
    txtCtrl.text = "";
  }

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  Future<void> getSparks() async {
    if(iCloud.mySparks.isNotEmpty){
      if(mounted) setState(() => mySparks = iCloud.mySparks);
    }else{
      await currencyMath.loginAutomatically();
      debugPrint("userID: ${myStorage.user?.id} : NniMlp8xumSPUSASYjJA");
      if(iCloud.affAuthToken != null && myStorage.user?.id != null) {
        String url = "$apiEndPoint/sparks/aff/${myStorage.user?.id}";
        Response res = await prudDio.get(url, queryParameters: {
          "limit": 200
        });
        if (res.statusCode == 200) {
          List resData = res.data;
          if (resData.isNotEmpty) {
            List<Spark> spks = [];
            debugPrint("Length; $resData");
            for (var spk in resData) {
              spks.add(Spark.fromJson(spk));
            }
            iCloud.updateMySpark(spks);
            if (mounted) {
              setState(() {
                mySparks = spks.reversed.toList();
                foundSparks = mySparks;
              });
            }
          }
        }
      }
    }
  }

  @override
  void initState(){
    super.initState();
    txtCtrl.text = "";
    Future.delayed(Duration.zero, () async {
      try{
        if(myStorage.user != null && myStorage.user!.id != null) await getSparks();
      }catch(ex){
        debugPrint("MySparks initState: $ex");
      }
      if(mounted) setState(() => loading = false);
    });
  }

  void showDetails(Spark spark, int index){
    if(mounted) setState(() => selectedIndex = index);
    iCloud.goto(context, SparkDetailPage(
      spark: spark, canCreateAffLink: false,
    ));
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
        title: Translate(
          text: "My Sparks",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
      ),
      body: SizedBox(
        height: screen.height,
        child: loading?
        LoadingComponent(
          isShimmer: true,
          height: screen.height,
          shimmerType: 3,
        )
            :
        (
          mySparks.isEmpty?
          noSpark
          :
          Column(
            children: [
              if(mySparks.length >= 10) Column(
                children: [
                  spacer.height,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: FormBuilderTextField(
                            controller: txtCtrl,
                            name: 'search',
                            style: tabData.npStyle,
                            keyboardType: TextInputType.text,
                            decoration: getDeco("Search Spark by Title"),
                            onChanged: (dynamic value){
                              try{
                                if(mounted) {
                                  setState(() {
                                    searchText = value;
                                  });
                                  search();
                                }
                              }catch(ex){
                                debugPrint("Search Error $ex");
                              }
                            },
                            valueTransformer: (text) => num.tryParse(text!),
                          ),
                        ),
                        spacer.width,
                        prudWidgetStyle.getIconButton(
                          onPressed: refresh,
                          icon: Icons.refresh_outlined,
                          isIcon: true
                        )
                      ],
                    ),
                  ),
                  spacer.height,
                ],
              ),
              Expanded(
                child: searchText != null && foundSparks.isEmpty?
                noSparkFound
                    :
                ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: searchText != null? foundSparks.length : mySparks.length,
                  itemBuilder: (BuildContext context, int index) {
                    Spark mySpk = searchText != null? foundSparks[index] : mySparks[index];
                    return InkWell(
                      onTap: () => showDetails(mySpk, index),
                      child: SparkContainer(
                        spark: mySpk,
                        selected: selectedIndex == index,
                      ),
                    );
                  },
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}
