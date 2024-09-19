import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/components/bus_seat_component.dart';
import 'package:prudapp/components/prud_bus_brand_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../../../../../../../components/bus_feature_component.dart';
import '../../../../../../../components/prud_container.dart';
import '../../../../../../../components/prud_data_viewer.dart';
import '../../../../../../../components/prud_network_image.dart';
import '../../../../../../../models/theme.dart';

class BusDetailsView extends StatefulWidget {
  final BusDetail detail;
  final bool isOperator;

  const BusDetailsView({super.key, required this.detail, this.isOperator = false});

  @override
  BusDetailsViewState createState() => BusDetailsViewState();
}

class BusDetailsViewState extends State<BusDetailsView> {
  List<Widget> carousels = [];
  BusBrand? brand;
  bool gettingBrand = false;

  void setBrand(){
    if(mounted) {
      setState(() {
        brand = busNotifier.busBrand;
        gettingBrand = false;
      });
    }
  }


  Future<void> getBusBrand() async {
    await tryAsync("getBusBrand", () async {
      if(mounted) setState(() => gettingBrand = true);
      if(busNotifier.busBrand != null){
        setBrand();
      }else{
        if(busNotifier.busBrandId != null){
          await busNotifier.getBusBrandById(busNotifier.busBrandId!);
          setBrand();
        }
      }
    }, error: (){
      if(mounted) setState(() => gettingBrand = false);
    });
  }

  @override
  void initState() {
    if(mounted && widget.detail.images.isNotEmpty) {
      setState(() {
        carousels = widget.detail.images.map((BusImage img){
          return PrudNetworkImage(
            url: img.imgUrl,
            width: double.maxFinite,
          );
        }).toList();
      });
    }
    Future.delayed(Duration.zero, () async {
      await getBusBrand();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double halfScreen = screen.height * 0.5;
    BorderRadius rad = const BorderRadius.only(
      topLeft: Radius.circular(60),
      topRight: Radius.circular(60)
    );
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if(widget.detail.images.isNotEmpty) GFCarousel(
              height: screen.height,
              autoPlay: true,
              aspectRatio: double.maxFinite,
              viewportFraction: 1.0,
              enlargeMainPage: true,
              enableInfiniteScroll: true,
              pauseAutoPlayOnTouch: const Duration(seconds: 10),
              autoPlayInterval: const Duration(seconds: 5),
              items: carousels
          ),
          if(widget.detail.images.isEmpty) Image.asset(prudImages.err, height: screen.height, fit: BoxFit.cover,),
          Container(
            margin: EdgeInsets.only(top: halfScreen),
            height: halfScreen,
            decoration: BoxDecoration(
              borderRadius: rad,
              color: prudColorTheme.bgC,
            ),
            child: ClipRRect(
              borderRadius: rad,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    mediumSpacer.height,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(brand != null) PrudBusBrandComponent(brand: brand!),
                          spacer.height,
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.detail.bus.busType} ${widget.detail.bus.busNo}",
                                style: prudWidgetStyle.typedTextStyle.copyWith(
                                    color: prudColorTheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18
                                ),
                              ),
                              Text(
                                "Bought On ${DateFormat('dd-MM-yyyy').format(widget.detail.bus.boughtOn)}",
                                style: prudWidgetStyle.hintStyle.copyWith(
                                    fontSize: 14,
                                    color: prudColorTheme.textB
                                ),
                              ),
                              Text(
                                "Journeys Made: ${widget.detail.bus.totalJourney}",
                                style: prudWidgetStyle.hintStyle.copyWith(
                                    fontSize: 14,
                                    color: prudColorTheme.iconB
                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                    spacer.height,
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          PrudDataViewer(
                            field: 'Total Journey Made',
                            value: widget.detail.bus.totalJourney,
                          ),
                          spacer.width,
                          PrudDataViewer(
                            field: 'Total Raters',
                            value: widget.detail.bus.voters,
                          ),
                          spacer.width,
                          PrudDataViewer(
                            field: 'Rate',
                            value: widget.detail.bus.getRating(),
                          ),
                          spacer.width,
                          PrudDataViewer(
                            field: 'Plate No',
                            value: widget.detail.bus.plateNo,
                          ),
                          spacer.width,
                          PrudDataViewer(
                            field: 'Brand',
                            value: widget.detail.bus.busManufacturer,
                          ),
                          spacer.width,
                          PrudDataViewer(
                            field: 'Manufacture Year',
                            value: widget.detail.bus.manufacturedYear,
                          ),
                        ],
                      ),
                    ),
                    spacer.height,
                    if(widget.detail.seats.isNotEmpty) Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: PrudContainer(
                        hasPadding: true,
                        hasTitle: true,
                        title: "Seats",
                        titleAlignment: MainAxisAlignment.start,
                        child: Column(
                          children: [
                            mediumSpacer.height,
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: widget.detail.seats.length,
                                itemBuilder: (contxt, index){
                                  return BusSeatComponent(seat: widget.detail.seats[index]);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    spacer.height,
                    if(widget.detail.features.isNotEmpty) Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: PrudContainer(
                          hasPadding: true,
                          hasTitle: true,
                          title: "Features",
                          titleAlignment: MainAxisAlignment.start,
                          child: Column(
                            children: [
                              mediumSpacer.height,
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: widget.detail.features.length,
                                  itemBuilder: (contxt, index){
                                    return BusFeatureComponent(feature: widget.detail.features[index]);
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                    ),

                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
