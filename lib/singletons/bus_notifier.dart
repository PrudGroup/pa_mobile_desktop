
import 'package:flutter/material.dart';

class BusNotifier extends ChangeNotifier {
  static final BusNotifier _busNotifier = BusNotifier._internal();
  static get busNotifier => _busNotifier;

  factory BusNotifier(){
    return _busNotifier;
  }



  BusNotifier._internal();
}

final busNotifier = BusNotifier();
