
import 'package:flutter/material.dart';

class AdsNotifier extends ChangeNotifier {
  static final AdsNotifier _adsNotifier = AdsNotifier._internal();
  static get adsNotifier => _adsNotifier;

  factory AdsNotifier(){
    return _adsNotifier;
  }



  AdsNotifier._internal();
}

final adsNotifier = AdsNotifier();
