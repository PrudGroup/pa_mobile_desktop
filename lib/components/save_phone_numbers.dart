import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:prudapp/singletons/recharge_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';

import '../models/theme.dart';

class SavePhoneNumbers extends StatelessWidget {

  const SavePhoneNumbers({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.75,
      decoration: BoxDecoration(
        borderRadius: prudRad,
      ),
      child: ClipRRect(
        borderRadius: prudRad,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: rechargeNotifier.phoneNumbers.length,
          itemBuilder: (context, index){
            List<PhoneNumber> phones = rechargeNotifier.phoneNumbers.reversed.toList();
            PhoneNumber phone = phones[index];
            return InkWell(
              onTap: () => rechargeNotifier.updateSelectedPhone(phone),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: prudColorTheme.primary, width: 5
                        )
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${phone.dialCode}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: prudColorTheme.textB
                          ),
                        ),
                        Text(
                          "${phone.phoneNumber}",
                          style: prudWidgetStyle.tabTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: prudColorTheme.secondary
                          ),
                        ),
                      ],
                    ),
                    if(phone.isoCode != null) Row(
                      children: [
                        Text(
                          "${tabData.getCountryFlag(phone.isoCode!)}",
                          style: prudWidgetStyle.typedTextStyle.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          child: Text(
                            "${tabData.getCountry(phone.isoCode!)?.displayName}",
                            style: prudWidgetStyle.tabTextStyle.copyWith(
                                fontWeight: FontWeight.w500,
                                fontSize: 9,
                                color: prudColorTheme.primary
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}
