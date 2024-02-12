import 'dart:math' as math;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PushNotificationMessage {
  String? title;
  String? body;
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalRange;

  DecimalTextInputFormatter({required this.decimalRange});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;


    String value = newValue.text;
    if((value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) || (value.contains(",") &&
        value.substring(value.indexOf(",") + 1).length > decimalRange)){
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if(value == "." || value == ","){
      truncated = "0.";
      int minimum = math.min(truncated.length, truncated.length + 1);
      newSelection = newValue.selection.copyWith(
        baseOffset: minimum,
        extentOffset: minimum
      );
    }
    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty
    );
  }
}

enum CheckOutPage{
  channel,
  transaction,
  transactionStatus
}

enum PaymentType{
  payIn,
  payOut,
  walletPayIn,
  walletPayOut,
}

enum PaymentStatus{
  succeeded,
  failed,
  confirmed,
  processing,
  pending
}


class Location{
  double? longitude;
  double? latitude;
  String? address;
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum TransactionType{
  debit,
  credit,
}

class PushMessage{
  final Map<String, dynamic> msg;
  RemoteNotification? notice;

  PushMessage(this.msg, this.notice);
}
