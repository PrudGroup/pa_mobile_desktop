
import 'package:flutter/material.dart';

class HotelNotifier extends ChangeNotifier {
  static final HotelNotifier _hotelNotifier = HotelNotifier._internal();
  static get hotelNotifier => _hotelNotifier;

  factory HotelNotifier(){
    return _hotelNotifier;
  }



  HotelNotifier._internal();
}

final hotelNotifier = HotelNotifier();
