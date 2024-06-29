
import 'package:flutter/material.dart';

class FlightNotifier extends ChangeNotifier {
  static final FlightNotifier _flightNotifier = FlightNotifier._internal();
  static get flightNotifier => _flightNotifier;

  factory FlightNotifier(){
    return _flightNotifier;
  }



  FlightNotifier._internal();
}

final flightNotifier = FlightNotifier();
