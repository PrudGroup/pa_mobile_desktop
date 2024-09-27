import 'package:flutter/material.dart';
import 'package:prudapp/models/bus_models.dart';

import 'book_seat_component.dart';

class SeatsComponent extends StatefulWidget {
  final List<BusSeat> seats;
  final double economyPrice;
  final double businessPrice;
  final double executivePrice;
  final double height;
  final String currency;
  final String journeyId;
  final String? exchangeFromJourneyId;
  final String? exchangePassengerId;

  const SeatsComponent({
    super.key, required this.seats,
    required this.economyPrice,
    required this.businessPrice,
    required this.executivePrice,
    required this.currency,
    required this.journeyId,
    this.height = 300,
    this.exchangeFromJourneyId,
    this.exchangePassengerId
  });

  @override
  SeatsComponentState createState() => SeatsComponentState();
}

class SeatsComponentState extends State<SeatsComponent> {

  double getPrice(String type){
    switch(type.toLowerCase()){
      case "economy": return widget.economyPrice;
      case "business": return widget.businessPrice;
      default: return widget.executivePrice;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.seats.length,
        itemBuilder: (context, index){
          BusSeat seat = widget.seats[index];
          return BookSeatComponent(
            seat: seat,
            price: getPrice(seat.seatType),
            currency: widget.currency,
            journeyId: widget.journeyId,
            exchangeFromJourneyId: widget.exchangeFromJourneyId,
            exchangePassengerId: widget.exchangePassengerId,
          );
        },
      ),
    );
  }
}
