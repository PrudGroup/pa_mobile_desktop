
import 'package:flutter/material.dart';

import '../constants.dart';

class UtilityNotifier extends ChangeNotifier {
  static final UtilityNotifier _utilityNotifier = UtilityNotifier._internal();
  static get utilityNotifier => _utilityNotifier;

  factory UtilityNotifier(){
    return _utilityNotifier;
  }



  UtilityNotifier._internal();
}

String utilityApiUrl = Constants.apiStatues == 'production'? "https://utilities.reloadly.com" : "https://utilities-sandbox.reloadly.com";
final utilityNotifier = UtilityNotifier();
