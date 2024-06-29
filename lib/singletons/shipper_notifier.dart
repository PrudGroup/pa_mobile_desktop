
import 'package:flutter/material.dart';

class ShipperNotifier extends ChangeNotifier {
  static final ShipperNotifier _shipperNotifier = ShipperNotifier._internal();
  static get shipperNotifier => _shipperNotifier;

  factory ShipperNotifier(){
    return _shipperNotifier;
  }



  ShipperNotifier._internal();
}

final shipperNotifier = ShipperNotifier();
