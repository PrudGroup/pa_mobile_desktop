import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

class PrudVideoPicker extends StatefulWidget {
  final Function(String?) onUrlChanged;
  final String destination;
  final String? existingUrl;
  final bool saveToCloud;
  final bool reset;

  const PrudVideoPicker({
    super.key, 
    required this.onUrlChanged, 
    required this.destination, 
    this.existingUrl, 
    this.saveToCloud = true, 
    this.reset = false,
  });

  @override
  PrudVideoPickerState createState() => PrudVideoPickerState();
}

class PrudVideoPickerState extends State<PrudVideoPicker> {
  @override
  Widget build(BuildContext context) {
    return WorkInProgress();
  }
}
