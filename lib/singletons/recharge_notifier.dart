
import 'package:flutter/material.dart';

import '../constants.dart';

class RechargeNotifier extends ChangeNotifier {
  static final RechargeNotifier _rechargeNotifier = RechargeNotifier._internal();
  static get rechargeNotifier => _rechargeNotifier;

  factory RechargeNotifier(){
    return _rechargeNotifier;
  }



  RechargeNotifier._internal();
}

String rechargeApiUrl = Constants.apiStatues == 'production'? "https://topups.reloadly.com" : "https://topups-sandbox.reloadly.com";
final rechargeNotifier = RechargeNotifier();
