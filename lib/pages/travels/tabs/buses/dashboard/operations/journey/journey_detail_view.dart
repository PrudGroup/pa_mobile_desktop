import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/bus_notifier.dart';

import '../../../../../../../components/prud_data_viewer.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/tab_data.dart';

class JourneyDetailView extends StatefulWidget {
  final Journey journey;
  final BusBrand brand;
  final bool isOperator;

  const JourneyDetailView({
    super.key,
    required this.journey,
    required this.brand,
    this.isOperator = false,
  });

  @override
  JourneyDetailViewState createState() => JourneyDetailViewState();
}

class JourneyDetailViewState extends State<JourneyDetailView> {
  bool loading = false;
  DriverDetails? driver;
  BusDetail? bus;

  Future<void> getDetails() async {
    await tryAsync("getDetails", () async {
      if(mounted) setState(() => loading = true);
      DriverDetails? driverWithDetails = await busNotifier.getDriverById(widget.journey.driverId);
      BusDetail? busWithDetails = await busNotifier.getBusByIdFromCloud(widget.journey.busId);
      if(mounted) {
        setState(() {
          bus = busWithDetails;
          driver = driverWithDetails;
          loading = false;
        });
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await getDetails();
    });
    super.initState();
  }

  void bookNow() {

  }

  @override
  Widget build(BuildContext context) {
    dynamic currencySymbol = tabData.getCurrencySymbol(widget.journey.priceCurrencyCode);
    Size screen = MediaQuery.of(context).size;
    double brandRating = widget.brand.getRating();
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 130,
            width: screen.width,
            decoration: BoxDecoration(
              color: prudColorTheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              image: DecorationImage(
                fit: BoxFit.contain,
                onError: (obj, stack){
                  debugPrint("NetworkImage Error: $obj : $stack");
                },
                image: FastCachedImageProvider(
                  widget.brand.logo,
                )
              ),
            ),
            child: Column(
              children: [
                spacer.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: prudColorTheme.bgA,
                      ),
                      IconButton(
                        onPressed: bookNow,
                        icon: const Icon(Icons.camera_outdoor),
                        color: prudColorTheme.bgA,
                        tooltip: "Book Now",
                        visualDensity: const VisualDensity(
                          horizontal: 0.7,
                          vertical: 0.7
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  spacer.height,
                  Stack(
                    children: [
                      Text(
                        tabData.shortenStringWithPeriod(widget.brand.brandName),
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                          color: prudColorTheme.secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if(widget.brand.slogan != null) Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Translate(
                          text: widget.brand.slogan!,
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                          ),
                          align: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GFRating(
                              onChanged: (rate){},
                              value: brandRating,
                            ),
                            spacer.width,
                            Translate(
                              text: tabData.getRateInterpretation(brandRating),
                              style: prudWidgetStyle.btnTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.success
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    indent: 0.0,
                    endIndent: 0.0,
                    height: 10,
                    thickness: 2,
                    color: prudColorTheme.lineC,
                  ),
                  FittedBox(
                    child: Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        PrudDataViewer(
                          field: "Business",
                          value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.businessSeatPrice)}",
                          valueIsMoney: true,
                          fontSize: 22,
                          size: PrudSize.smaller,
                          headColor: prudColorTheme.buttonA,
                        ),
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
                    thickness: 2,
                    color: prudColorTheme.lineC,
                  ),

                  xLargeSpacer.height,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
