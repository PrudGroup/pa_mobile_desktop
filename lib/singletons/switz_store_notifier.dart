
import 'package:flutter/material.dart';

class SwitzStoreNotifier extends ChangeNotifier {
  static final SwitzStoreNotifier _switzStoreNotifier = SwitzStoreNotifier._internal();
  static get switzStoreNotifier => _switzStoreNotifier;

  factory SwitzStoreNotifier(){
    return _switzStoreNotifier;
  }



  SwitzStoreNotifier._internal();
}

final switzStoreNotifier = SwitzStoreNotifier();
