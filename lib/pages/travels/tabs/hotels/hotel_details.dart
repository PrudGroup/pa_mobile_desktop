import 'package:flutter/material.dart';

class HotelDetails extends StatefulWidget {
  final String hotelId;
  final String? affLinkId;
  const HotelDetails({super.key, required this.hotelId, this.affLinkId});

  @override
  HotelDetailsState createState() => HotelDetailsState();
}

class HotelDetailsState extends State<HotelDetails> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
