import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/models/images.dart';

import '../../../../../../../components/prud_network_image.dart';

class BusDetailsView extends StatefulWidget {
  final BusDetail detail;
  final bool isOperator;

  const BusDetailsView({super.key, required this.detail, this.isOperator = false});

  @override
  BusDetailsViewState createState() => BusDetailsViewState();
}

class BusDetailsViewState extends State<BusDetailsView> {
  List<Widget> carousels = [];

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Stack(
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
        if(widget.detail.images.isNotEmpty) Image.asset(prudImages.err),
      ],
    );
  }
}
