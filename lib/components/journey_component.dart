import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/components/bus_brand_component.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/prud_data_viewer.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/bus_models.dart';
import '../models/theme.dart';
import '../pages/travels/tabs/buses/dashboard/operations/journey/journey_detail_view.dart';
import '../singletons/i_cloud.dart';

class JourneyComponent extends StatefulWidget {
  final Journey journey;
  final BusBrand brand;

  const JourneyComponent({
    super.key, required this.journey,
    required this.brand,
  });

  @override
  JourneyComponentState createState() => JourneyComponentState();
}

class JourneyComponentState extends State<JourneyComponent> {
  bool loading = false;
  BusBrand? brand;
  bool selected = false;

  Future<void> getBrand() async {
    await tryAsync("getBrand", () async {
      if(mounted) {
        setState(() {
          loading = true;
          brand = widget.brand;
        });
      }
      if(brand == null) {
        BusBrand? dBrand = await busNotifier.getBusBrandById(widget.journey.brandId);
        if (mounted) setState(() => brand = dBrand);
      }
      if (mounted) setState(() => loading = false);
    }, error: (){
      if (mounted) setState(() => loading = false);
    });
  }

  void select(){
    if(mounted && brand != null){
      busNotifier.updateSelectedJourney(widget.journey);
      iCloud.goto(
        context,
        JourneyDetailView(
          journey: widget.journey,
          brand: brand!,
          isOperator: true,
        )
      );
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getBrand();
    });
    super.initState();
    busNotifier.addListener((){
      if(busNotifier.selectedJourney != null && busNotifier.selectedJourney!.id == widget.journey.id){
        if(mounted) setState(() => selected = true);
      }else{
        if(mounted) setState(() => selected = false);
      }
    });
  }


  @override
  void dispose(){
    busNotifier.removeListener((){});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    dynamic currencySymbol = tabData.getCurrencySymbol(widget.journey.priceCurrencyCode);
    Size screen = MediaQuery.of(context).size;
    return InkWell(
      onTap: select,
      child: PrudContainer(
        hasPadding: true,
        hasOnlyTopRadius: true,
        child: Column(
          children: [
            spacer.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: screen.width/3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ImageIcon(
                        AssetImage(prudImages.resort),
                        size: 25,
                        color: prudColorTheme.lineC,
                      ),
                      spacer.width,
                      Stack(
                        children: [
                          FittedBox(
                            child: Text(
                              widget.journey.departureCity,
                              style: prudWidgetStyle.typedTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: prudColorTheme.secondary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: FittedBox(
                              child: Text(
                                "${tabData.getCountry(widget.journey.departureCountry)?.name}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: prudColorTheme.primary,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: FittedBox(
                              child: Text(
                                DateFormat('dd MMM. hh:mm a').format(widget.journey.departureDate),
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: prudColorTheme.textB,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.double_arrow_sharp,
                        size: 20,
                        color: prudColorTheme.textB,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        "${widget.journey.duration.hours}h ${widget.journey.duration.minutes}m",
                        style: prudWidgetStyle.btnTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: prudColorTheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: screen.width/3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          FittedBox(
                            child: Text(
                              widget.journey.destinationCity,
                              style: prudWidgetStyle.typedTextStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: prudColorTheme.secondary,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: FittedBox(
                              child: Text(
                                "${tabData.getCountry(widget.journey.destinationCountry)?.name}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: prudColorTheme.primary,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: FittedBox(
                              child: Text(
                                DateFormat('dd MMM. hh:mm a').format(widget.journey.destinationDate),
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8,
                                  color: prudColorTheme.textB,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      spacer.width,
                      ImageIcon(
                        AssetImage(prudImages.resort),
                        size: 25,
                        color: prudColorTheme.lineC,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              indent: 0.0,
              endIndent: 0.0,
              height: 10,
              thickness: selected? 5:1,
              color: selected? prudColorTheme.primary : prudColorTheme.lineC,
            ),
            SizedBox(
              height: 60,
              child: ListView(
                // padding: const EdgeInsets.symmetric(horizontal: 5),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  PrudDataViewer(
                    field: "Economy",
                    value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.economySeatPrice)}",
                    valueIsMoney: true,
                    fontSize: 22,
                    size: PrudSize.smaller,
                    removeWidth: true,
                    headColor: prudColorTheme.primary,
                  ),
                  mediumSpacer.width,
                  PrudDataViewer(
                    field: "Business",
                    value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.businessSeatPrice)}",
                    valueIsMoney: true,
                    fontSize: 22,
                    size: PrudSize.smaller,
                    headColor: prudColorTheme.buttonA,
                  ),
                  spacer.width,
                  PrudDataViewer(
                    field: "Executive",
                    value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.executiveSeatPrice)}",
                    valueIsMoney: true,
                    fontSize: 22,
                    size: PrudSize.smaller,
                    headColor: prudColorTheme.primary,
                  ),
                ],
              ),
            ),
            Divider(
              indent: 0.0,
              endIndent: 0.0,
              height: 10,
              thickness: 1,
              color: prudColorTheme.lineC,
            ),
            loading || brand == null? LoadingComponent(
              isShimmer: false,
              defaultSpinnerType: false,
              size: 10,
              spinnerColor: prudColorTheme.buttonA,
            ) : BusBrandComponent(brand: brand!),
          ],
        )
      )
    );
  }
}
