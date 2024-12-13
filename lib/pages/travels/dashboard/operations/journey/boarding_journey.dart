import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../../components/journey_component.dart';
import '../../../../../../../components/loading_component.dart';
import '../../../../../../../models/bus_models.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/bus_notifier.dart';
import '../../../../../../../singletons/tab_data.dart';

class BoardingJourney extends StatefulWidget {
  const BoardingJourney({super.key});

  @override
  BoardingJourneyState createState() => BoardingJourneyState();
}

class BoardingJourneyState extends State<BoardingJourney> {
  List<JourneyWithBrand> journeys = busNotifier.brandBoardingJourneys;
  bool loading = false;
  Widget noJourney = tabData.getNotFoundWidget(
    title: "No Journey",
    desc: "No journey found. Things can change at anytime."
  );
  bool showFloatingButton = busNotifier.showFloatingButton;



  Future<void> getJourneyFromCloud() async {
    await tryAsync("getJourneyFromCloud", () async {
      if(mounted) setState(() => loading = true);
      List<JourneyWithBrand> found = await busNotifier.getBrandJourneysFromCloud(1, busNotifier.busBrandId!);
      if(mounted) {
        busNotifier.brandBoardingJourneys = found;
        setState(() {
          journeys = found;
          loading = false;
        });
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  Future<void> getJourneys() async {
    if(journeys.isEmpty) await getJourneyFromCloud();
  }

  Future<void> refresh() async {
    await getJourneyFromCloud();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getJourneys();
    });
    super.initState();
    busNotifier.addListener((){
      if(mounted) setState(() => showFloatingButton = busNotifier.showFloatingButton);
    });
  }

  @override
  void dispose() {
    busNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height,
      child: loading? LoadingComponent(
        shimmerType: 3,
        height: screen.height,
      )
          :
      Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(journeys.isNotEmpty) Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: journeys.length,
                    itemBuilder: (context, index){
                      JourneyWithBrand jb = journeys[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: JourneyComponent(journey: jb.journey, brand: jb.brand,),
                      );
                    }
                ),
              ),
              if(busNotifier.brandBoardingJourneys.isEmpty) Expanded(
                  child: Center(child: noJourney,)
              ),
              spacer.height
            ],
          ),
          if(showFloatingButton) Positioned(
              right: 15,
              bottom: 80,
              child: FloatingActionButton.small(
                foregroundColor: prudColorTheme.bgC,
                backgroundColor: prudColorTheme.primary,
                tooltip: "Refreshes data from PrudServices",
                onPressed: refresh,
                child: loading? LoadingComponent(
                  isShimmer: false,
                  size: 25,
                  spinnerColor: prudColorTheme.bgA,
                ) : const Icon(FontAwesomeIcons.arrowsRotate, size: 25,),
              )
          )
        ],
      ),
    );
  }
}
