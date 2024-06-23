import 'package:flutter/material.dart';

class AdsDetails extends StatefulWidget {
  final String adsId;
  final String? affLinkId;
  const AdsDetails({
    super.key,
    required this.adsId,
    this.affLinkId});

  @override
  AdsDetailsState createState() => AdsDetailsState();
}

class AdsDetailsState extends State<AdsDetails> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
