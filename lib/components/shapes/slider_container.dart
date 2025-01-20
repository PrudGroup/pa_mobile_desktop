import 'package:carousel_slider/carousel_slider.dart' as caro;
import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_network_image.dart';

import '../../models/theme.dart';
import 'curve_container.dart';

// ignore: must_be_immutable
class SliderContainer extends StatelessWidget {

  final Color color;
  final Color frontColor;
  final double arcHeight;
  final String position;
  final bool equality;
  final Widget child;
  final double width;
  final double height;
  final bool clock;
  final Radius radius;
  final int type;
  final double space;
  final List<String> images;

  caro.CarouselController carouselController = caro.CarouselController();

  SliderContainer({
    super.key,
    required this.color,
    required this.frontColor,
    required this.arcHeight,
    required this.child,
    required this.images,
    this.radius = const Radius.circular(10),
    this.position = "Bottom",
    this.equality = false,
    this.width = double.infinity,
    this.height = double.infinity,
    this.clock = false,
    this.type = 1,
    this.space = 0.10
  }): assert(images.length>1);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        caro.CarouselSlider.builder(
          options: caro.CarouselOptions(
            height: height/2,
            viewportFraction: 1,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 20),
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          ),
          itemCount: images.length,
          itemBuilder: (BuildContext context, int itemIndex, int page) => PrudNetworkImage(
            url: images[itemIndex],
            width: width,
            height: height/2,
          ),
          carouselController: carouselController,
        ),
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: ArcCurveContainer(
              color: color,
              arcHeight: arcHeight,
              position: position,
              equality: equality,
              clock: clock,
              radius: radius,
              type: type
            ),
          ),
        ),
        SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: ArcCurveContainer(
                color: frontColor,
                arcHeight: (arcHeight+space),
                position: position,
                equality: equality,
                clock: clock,
                radius: radius,
                type: type
            ),
            child: Padding(
              padding: EdgeInsets.only(top: height - (height*(arcHeight + 0.3))),
              child: Container(
                padding: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                  color: prudColorTheme.bgA.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.elliptical(width/4.5, height/4.5),
                    topLeft: Radius.elliptical(width/4.5, height/4.5),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.elliptical(width/3.5, height/4.5),
                    topLeft: Radius.elliptical(width/3.5, height/4.5),
                  ),
                  child: Container(
                    color: prudColorTheme.bgA,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: height/2.2),
          child: Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
                iconSize: 30,
                onPressed: () => carouselController.previousPage(),
                hoverColor: prudColorTheme.primary,
                splashColor: prudColorTheme.primary.withValues(alpha: 0.4),
                tooltip: 'Previous Photo',
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: prudColorTheme.bgA,),
                iconSize: 30,
                onPressed: () => carouselController.nextPage(),
                tooltip: 'Next Photo',
                hoverColor: prudColorTheme.primary,
                splashColor: prudColorTheme.primary.withValues(alpha: 0.4),
              )
            ],
          ),
        )
      ],
    );
  }

}
