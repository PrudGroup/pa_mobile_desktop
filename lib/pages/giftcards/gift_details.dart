import 'package:flutter/material.dart';
import 'package:prudapp/components/gift_cart_icon.dart';
import 'package:prudapp/models/reloadly.dart';

import '../../components/Translate.dart';
import '../../models/theme.dart';

class GiftDetails extends StatefulWidget {
  final GiftProduct gift;
  const GiftDetails({super.key, required this.gift});

  @override
  GiftDetailsState createState() => GiftDetailsState();
}

class GiftDetailsState extends State<GiftDetails> {
  dynamic brandLogo;
  late GiftProduct gift;

  void refresh(){

  }

  @override
  void initState() {
    if(mounted){
      setState(() {
        gift = widget.gift;
        brandLogo = gift.logoUrls?[0];
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(screen.width/2),
                  bottomLeft: Radius.circular(screen.width/2),
                ),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    brandLogo,
                  )
                )
              ),
              child: Column(
                children: [
                  Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 20,
                      ),
                      Row(
                        children: [
                          const GiftCartIcon(),
                          spacer.width,
                          IconButton(
                            onPressed: refresh,
                            icon: const Icon(Icons.refresh),
                            color: prudColorTheme.bgA,
                            splashColor: prudColorTheme.bgD,
                            splashRadius: 10.0,
                          ),
                        ],
                      )
                    ],
                  ),
                  mediumSpacer.height,
                  FittedBox(
                    child: Text(
                      "${gift.brand?.brandName}",
                      style: prudWidgetStyle.logoStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        color: prudColorTheme.success,
                        shadows: [
                          Shadow(
                            color: prudColorTheme.bgC,
                            blurRadius: 0.5,
                            offset: Offset.fromDirection(0.5),
                          ),
                          Shadow(
                            color: prudColorTheme.bgC,
                            blurRadius: 0.5,
                            offset: Offset.fromDirection(1.5),
                          )
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ),
            mediumSpacer.height,
            FittedBox(
              child: Text(
                "${gift.productName}",
                style: prudWidgetStyle.hintStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: prudColorTheme.textA,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
