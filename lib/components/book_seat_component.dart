import 'package:flutter/material.dart';
import 'package:prudapp/singletons/bus_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

import '../models/bus_models.dart';
import '../models/theme.dart';
import '../singletons/i_cloud.dart';
import '../singletons/tab_data.dart';
import 'bus_seat_component.dart';
import 'loading_component.dart';

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

  bool booking = false;
  bool booked = false;
  JourneyPassenger? bookedPassenger;

  Future<void> bookSeat() async {
    if(myStorage.user != null && myStorage.user!.id != null) {
      await tryAsync("bookSeat", () async {
        if (mounted) setState(() => booking = true);
        JourneyPassenger newPas = JourneyPassenger(
          journeyId: widget.journeyId,
          affId: myStorage.user!.id!,
          bookedAt: DateTime.now(),
          seatId: widget.seat.id!
        );
        JourneyPassenger? jp = await busNotifier.bookPassengerForJourney(newPas);
        if(jp != null){
          if(mounted){
            setState((){
              booked = true;
              bookedPassenger = jp;
              booking = false;
            });
          }
        }else{
          if (mounted) {
            iCloud.showSnackBar("Unable to book seat", context, type: 3);
            setState(() => booking = false);
          }
        }
      }, error: () {
        if (mounted) setState(() => booking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: prudColorTheme.bgD
      ),
      child: Column(
        children: [
          BusSeatComponent(seat: widget.seat),
          Divider(
            indent: 0.0,
            endIndent: 0.0,
            thickness: 2,
            height: 10,
            color: prudColorTheme.lineC,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    "${tabData.getCurrencySymbol(widget.currency)}",
                    style: tabData.tBStyle.copyWith(
                      fontSize: 14,
                      color: prudColorTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${tabData.getFormattedNumber(widget.price)}",
                    style: prudWidgetStyle.btnTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: prudColorTheme.secondary,
                    ),
                  )
                ],
              ),
              mediumSpacer.width,
              booking? LoadingComponent(
                isShimmer: false,
                spinnerColor: prudColorTheme.primary,
                size: 25,
              ) : (
                booked? Text(
                  "Booked",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.success,
                    fontSize: 16,
                  ),
                ) : prudWidgetStyle.getShortButton(
                  onPressed: bookSeat,
                  text: "Book Now",
                )
              )
            ]
          )
        ],
      ),
    );
  }
}
