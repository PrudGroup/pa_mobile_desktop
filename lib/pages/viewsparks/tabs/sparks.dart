import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../components/loading_component.dart';
import '../../../components/spark_container.dart';
import '../../../components/translate.dart';
import '../../../models/location.dart';
import '../../../models/spark.dart';
import '../../../models/theme.dart';
import '../../../models/user.dart';
import '../../../singletons/i_cloud.dart';
import '../../../singletons/shared_local_storage.dart';
import '../../../singletons/tab_data.dart';
import '../spark_detail_page.dart';

class Sparks extends StatefulWidget {
  final Function(int)? goToTab;

  const Sparks({super.key, this.goToTab});

  @override
  SparksState createState() => SparksState();
}

class SparksState extends State<Sparks> {

  bool loading = true;
  List<Spark> sparks = [];
  String? searchText;
  List<Spark> foundSparks = [];
  TextEditingController txtCtrl = TextEditingController();
  int? selectedIndex;
  Widget noSpark = tabData.getNotFoundWidget(
    title: "No Spark",
    desc: "There are presently no spark yet. You can become the first to add a spark.",
  );
  Widget noSparkFound = tabData.getNotFoundWidget(
    title: "No Spark Found",
    desc: "There is no spark that matches your search criteria. Try changing your criteria.",
  );

  void search(){
    if(mounted) setState(() => loading = true);
    if(sparks.isNotEmpty && searchText != null){
      List<Spark> spks = sparks.where((Spark spk) =>
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
    if(iCloud.sparks.isNotEmpty){
      if(mounted) setState(() => sparks = iCloud.sparks);
    }else{
      User user = myStorage.user!;
      String url = "$apiEndPoint/sparks/locates/by_location";
      Location local = Location(
        country: user.country,
        state: user.state,
        city: user.city,
        town: user.town,
        limit: 200,
      );
      Response res = await prudDio.get(url, queryParameters: {
        "location": local.toJson(),
        "exclude_aff_id": myStorage.user!.id,
        "limit": 200
      });
      if(res.statusCode == 200){
        var resData = res.data;
        if(resData.length > 0) {
          List<Spark> spks = [];
          resData.forEach((dynamic spk) {
            spks.add(Spark.fromJson(spk));
          });
          iCloud.updateMySpark(spks);
          if(mounted) {
            setState(() {
              sparks = spks;
              foundSparks = spks;
            });
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
      spark: spark, canCreateAffLink: true,
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
          text: "Sparks",
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
            sparks.isEmpty?
            noSpark
                :
            Column(
              children: [
                if(sparks.length >= 10) Column(
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
                    itemCount: searchText != null? foundSparks.length : sparks.length,
                    itemBuilder: (BuildContext context, int index) {
                      Spark dSpk = searchText != null? foundSparks[index] : sparks[index];
                      return InkWell(
                        onTap: () => showDetails(dSpk, index),
                        child: SparkContainer(
                          spark: dSpk,
                          canCreateAffLink: true,
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