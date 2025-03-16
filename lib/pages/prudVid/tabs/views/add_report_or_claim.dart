import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
    
class AddReportOrClaim extends StatefulWidget {
  final ChannelVideo video;
  
  const AddReportOrClaim({super.key, required this.video});

  @override
  // ignore: library_private_types_in_public_api
  _AddReportOrClaimState createState() => _AddReportOrClaimState();
}

class _AddReportOrClaimState extends State<AddReportOrClaim> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Container(),
    );
  }
}