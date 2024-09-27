import 'package:flutter/material.dart';

import '../models/bus_models.dart';
import 'bus_seat_component.dart';

class BookSeatComponent extends StatefulWidget {
  final BusSeat seat;
  final double price;
  final String journeyId;
  final String currency;
  final String? exchangeFromJourneyId;
  final String? exchangePassengerId;

  const BookSeatComponent({
    super.key, required this.seat,
    required this.price,
    required this.journeyId,
    required this.currency,
    this.exchangeFromJourneyId,
    this.exchangePassengerId
  });

  @override
  BookSeatComponentState createState() => BookSeatComponentState();
}

class BookSeatComponentState extends State<BookSeatComponent> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          BusSeatComponent(seat: widget.seat),
        ],
      ),
    );
  }
}
