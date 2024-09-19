import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:prudapp/models/bus_models.dart';

import '../models/theme.dart';
import '../singletons/shared_local_storage.dart';

class BusSeatComponent extends StatelessWidget {
  final BusSeat seat;

  const BusSeatComponent({super.key, required this.seat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10,5,10,5),
      decoration: BoxDecoration(
        color: prudColorTheme.bgA,
        border: Border(
          bottom: BorderSide(
            color: prudColorTheme.lineC,
            width: 5.0
          )
        )
      ),
      child: Row(
        children: [
          GFAvatar(
            backgroundColor: prudColorTheme.lineC,
            size: GFSize.SMALL,
            child: const Center(
              child: Icon(Icons.event_seat_outlined, size: 30,),
            ),
          ),
          spacer.width,
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  "${seat.seatNo} | ${seat.seatType}",
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.textA,
                    fontSize: 13,
                  ),
                ),
              ),
              GFRating(
                onChanged: (rate){},
                value: seat.getRating(),
                size: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${seat.status} | ${myStorage.ago(dDate: seat.statusDate!, isShort: false)}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.iconC,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    "Fixed: ${seat.fixed} | ${myStorage.ago(dDate: seat.fixedDate!, isShort: false)}",
                    style: prudWidgetStyle.tabTextStyle.copyWith(
                      color: prudColorTheme.iconB,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              FittedBox(
                child: Text(
                  seat.description,
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.iconB,
                    fontSize: 9,
                  ),
                ),
              ),
              FittedBox(
                child: Text(
                  seat.position,
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    color: prudColorTheme.secondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
