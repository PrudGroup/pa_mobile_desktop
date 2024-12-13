import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:intl/intl.dart';
import 'package:prudapp/components/prud_container.dart';
import 'package:prudapp/components/seats_component.dart';
import 'package:prudapp/models/bus_models.dart';
import 'package:prudapp/singletons/bus_notifier.dart';

import '../../../../../../../components/bus_component.dart';
import '../../../../../../../components/dashboard_driver_component.dart';
import '../../../../../../../components/passenger_component.dart';
import '../../../../../../../components/prud_data_viewer.dart';
import '../../../../../../../components/prud_panel.dart';
import '../../../../../../../components/select_bus_component.dart';
import '../../../../../../../components/select_driver_component.dart';
import '../../../../../../../components/translate_text.dart';
import '../../../../../../../models/theme.dart';
import '../../../../../../../singletons/shared_local_storage.dart';
import '../../../../../../../singletons/tab_data.dart';

class JourneyDetailView extends StatefulWidget {
  final Journey journey;
  final BusBrand brand;
  final bool isOperator;
  final String? exchangeFromJourneyId;
  final String? exchangePassengerId;

  const JourneyDetailView({
    super.key,
    required this.journey,
    required this.brand,
    this.isOperator = false,
    this.exchangeFromJourneyId,
    this.exchangePassengerId
  });

  @override
  JourneyDetailViewState createState() => JourneyDetailViewState();
}

class JourneyDetailViewState extends State<JourneyDetailView> {
  bool loading = false;
  DriverDetails? driver;
  BusDetail? bus;
  List<PassengerDetail> passengers = [];
  int totalVacantSeats = 0;
  int takenSeats = 0;
  bool booked = false;
  List<BusSeat> availableSeats = [];
  bool userIsPassenger = false;

  bool isUserAPassenger(){
    if(passengers.isNotEmpty){
      List<PassengerDetail> existing = passengers.where((pas) => pas.user.id == myStorage.user?.id).toList();
      return existing.isNotEmpty;
    }
    return false;
  }


  Future<void> startBoarding() async {

  }

  Future<void> cancelJourney() async {

  }

  Future<void> haltJourney() async {

  }

  Future<void> haltBoarding() async {

  }

  Future<void> completeJourney() async {

  }

  Future<void> rateJourney() async {

  }

  Future<void> rateBus() async {

  }

  Future<void> rateDriver() async {

  }

  List<BusSeat> setSeats(){
    List<String> takenSeatIds = [];
    if(passengers.isNotEmpty){
      takenSeatIds = passengers.map<String>((PassengerDetail pas) => pas.passenger.seatId).toList();
    }
    List<BusSeat> seats = bus!.seats.where((BusSeat seat) => takenSeatIds.contains(seat.id!) != true).toList();
    return seats;
  }

  Future<void> getDetails() async {
    await tryAsync("getDetails", () async {
      if(mounted) setState(() => loading = true);
      DriverDetails? driverWithDetails = await busNotifier.getDriverById(widget.journey.driverId);
      BusDetail? busWithDetails = await busNotifier.getBusByIdFromCloud(widget.journey.busId);
      List<PassengerDetail> dPassengers = await busNotifier.getJourneyPassengersFromCloud(
          widget.journey.id!, widget.journey.busId
      );
      if(mounted) {
        setState(() {
          bus = busWithDetails;
          driver = driverWithDetails;
          passengers = dPassengers;
          takenSeats = dPassengers.length;
          if(bus != null) totalVacantSeats = bus!.seats.length - takenSeats;
          booked = totalVacantSeats > 0;
          availableSeats = setSeats();
          userIsPassenger = isUserAPassenger();
          loading = false;
        });
      }
    }, error: (){
      if(mounted) setState(() => loading = false);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      busNotifier.selectedBus = null;
      busNotifier.selectedDriver = null;
      await getDetails();
    });
    super.initState();
    busNotifier.addListener((){
      if(mounted && busNotifier.selectedBus != null){
        setState(() {
          bus = null;
          bus = busNotifier.selectedBus;
        });
        busNotifier.selectedBus = null;
      }
      if(mounted && busNotifier.selectedDriver != null){
        setState(() {
          driver = busNotifier.selectedDriver;
        });
        busNotifier.selectedDriver = null;
      }
    });
  }

  void bookNow() {

  }

  void getBus(){
    if(widget.isOperator && bus != null) {
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        enableDrag: true,
        showDragHandle: true,
        backgroundColor: prudColorTheme.bgA,
        elevation: 10,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: prudRad,
        ),
        builder: (BuildContext context) =>
        SelectBusComponent(onlyActive: true, onlyOfType: bus!.bus.busType,),
      );
    }
  }

  void getDriver(){
    if(widget.isOperator) {
      showModalBottomSheet(
        context: context,
        useSafeArea: true,
        enableDrag: true,
        showDragHandle: true,
        backgroundColor: prudColorTheme.bgA,
        elevation: 10,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: prudRad,
        ),
        builder: (BuildContext context) =>
        const SelectDriverComponent(onlyActive: true,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic currencySymbol = tabData.getCurrencySymbol(widget.journey.priceCurrencyCode);
    Size screen = MediaQuery.of(context).size;
    double brandRating = widget.brand.getRating();
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 130,
            width: screen.width,
            decoration: BoxDecoration(
              color: prudColorTheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                onError: (obj, stack){
                  debugPrint("NetworkImage Error: $obj : $stack");
                },
                image: FastCachedImageProvider(
                  widget.brand.logo,
                )
              ),
            ),
            child: Column(
              children: [
                mediumSpacer.height,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new),
                        color: prudColorTheme.bgA,
                      ),
                      if(!booked) IconButton(
                        onPressed: bookNow,
                        icon: const Icon(Icons.camera_outdoor),
                        color: prudColorTheme.bgA,
                        tooltip: "Book Now",
                        visualDensity: const VisualDensity(
                          horizontal: 0.7,
                          vertical: 0.7
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  spacer.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        tabData.shortenStringWithPeriod(widget.brand.brandName),
                        style: prudWidgetStyle.typedTextStyle.copyWith(
                          color: prudColorTheme.secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if(widget.brand.slogan != null) Translate(
                        text: widget.brand.slogan!,
                        style: prudWidgetStyle.tabTextStyle.copyWith(
                            color: prudColorTheme.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                        align: TextAlign.center,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GFRating(
                            onChanged: (rate){},
                            value: brandRating,
                          ),
                          spacer.width,
                          Translate(
                            text: tabData.getRateInterpretation(brandRating),
                            style: prudWidgetStyle.btnTextStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: prudColorTheme.success
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  spacer.height,
                  Column(
                    children: [
                      Divider(
                        indent: 0.0,
                        endIndent: 0.0,
                        height: 10,
                        thickness: 2,
                        color: prudColorTheme.lineC,
                      ),
                      FittedBox(
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PrudDataViewer(
                              field: "Economy",
                              value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.economySeatPrice)}",
                              valueIsMoney: true,
                              fontSize: 22,
                              size: PrudSize.smaller,
                              removeWidth: true,
                              makeTransparent: true,
                              headColor: prudColorTheme.primary,
                            ),
                            SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                indent: 0.0,
                                endIndent: 0.0,
                                width: 10,
                                thickness: 2,
                                color: prudColorTheme.lineC,
                              ),
                            ),
                            PrudDataViewer(
                              field: "Business",
                              value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.businessSeatPrice)}",
                              valueIsMoney: true,
                              fontSize: 22,
                              size: PrudSize.smaller,
                              removeWidth: true,
                              makeTransparent: true,
                              headColor: prudColorTheme.buttonA,
                            ),
                            SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                indent: 0.0,
                                endIndent: 0.0,
                                width: 10,
                                thickness: 2,
                                color: prudColorTheme.lineC,
                              ),
                            ),
                            PrudDataViewer(
                              field: "Executive",
                              value: "$currencySymbol${tabData.getFormattedNumber(widget.journey.executiveSeatPrice)}",
                              valueIsMoney: true,
                              fontSize: 22,
                              removeWidth: true,
                              makeTransparent: true,
                              size: PrudSize.smaller,
                              headColor: prudColorTheme.primary,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 0.0,
                        endIndent: 0.0,
                        height: 10,
                        thickness: 2,
                        color: prudColorTheme.lineC,
                      ),
                    ],
                  ),
                  spacer.height,
                  if(!booked) prudWidgetStyle.getLongButton(
                    onPressed: bookNow,
                    text: "Book A Seat Now",
                    shape: 1
                  ),
                  spacer.height,
                  Column(
                    children: [
                      Divider(
                        indent: 0.0,
                        endIndent: 0.0,
                        height: 10,
                        thickness: 2,
                        color: prudColorTheme.lineC,
                      ),
                      FittedBox(
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PrudDataViewer(
                              field: "Departure City",
                              value: widget.journey.departureCity,
                              valueIsMoney: true,
                              fontSize: 22,
                              size: PrudSize.smaller,
                              removeWidth: true,
                              makeTransparent: true,
                              headColor: prudColorTheme.primary,
                            ),
                            SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                indent: 0.0,
                                endIndent: 0.0,
                                width: 10,
                                thickness: 2,
                                color: prudColorTheme.lineC,
                              ),
                            ),
                            PrudDataViewer(
                              field: "Duration",
                              value: "${widget.journey.duration.hours}hrs ${widget.journey.duration.minutes}mins",
                              valueIsMoney: true,
                              fontSize: 22,
                              size: PrudSize.smaller,
                              removeWidth: true,
                              makeTransparent: true,
                              headColor: prudColorTheme.buttonA,
                            ),
                            SizedBox(
                              height: 50,
                              child: VerticalDivider(
                                indent: 0.0,
                                endIndent: 0.0,
                                width: 10,
                                thickness: 2,
                                color: prudColorTheme.lineC,
                              ),
                            ),
                            PrudDataViewer(
                              field: "Destination City",
                              value: widget.journey.destinationCity,
                              valueIsMoney: true,
                              fontSize: 22,
                              removeWidth: true,
                              makeTransparent: true,
                              size: PrudSize.smaller,
                              headColor: prudColorTheme.primary,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        indent: 0.0,
                        endIndent: 0.0,
                        height: 10,
                        thickness: 2,
                        color: prudColorTheme.lineC,
                      ),
                    ],
                  ),
                  spacer.height,
                  PrudContainer(
                    hasPadding: true,
                    hasOnlyTopRadius: true,
                    hasTitle: true,
                    title: "Dates & Time",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.center,
                    child: Column(
                      children: [
                        spacer.height,
                        FittedBox(
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PrudDataViewer(
                                field: "Departure",
                                subValue: DateFormat('hh:mm a').format(widget.journey.departureDate),
                                value: DateFormat('dd MMM, yyyy').format(widget.journey.departureDate),
                                valueIsMoney: true,
                                fontSize: 22,
                                size: PrudSize.smaller,
                                removeWidth: true,
                                makeTransparent: true,
                                headColor: prudColorTheme.textB,
                              ),
                              SizedBox(
                                height: 50,
                                child: VerticalDivider(
                                  indent: 0.0,
                                  endIndent: 0.0,
                                  width: 10,
                                  thickness: 2,
                                  color: prudColorTheme.lineC,
                                ),
                              ),
                              PrudDataViewer(
                                field: "Arrival",
                                subValue: DateFormat('hh:mm a').format(widget.journey.destinationDate),
                                value: DateFormat('dd MMM, yyyy').format(widget.journey.destinationDate),
                                valueIsMoney: true,
                                fontSize: 22,
                                size: PrudSize.smaller,
                                removeWidth: true,
                                makeTransparent: true,
                                headColor: prudColorTheme.textB,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                  spacer.height,
                  PrudContainer(
                    hasPadding: true,
                    hasOnlyTopRadius: true,
                    title: "Country",
                    hasTitle: true,
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.center,
                    child: Column(
                      children: [
                        spacer.height,
                        FittedBox(
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PrudDataViewer(
                                field: "Departure",
                                value: "${tabData.getCountryFlag(widget.journey.departureCountry)}  ${tabData.getCountryName(widget.journey.departureCountry)}",
                                valueIsMoney: true,
                                fontSize: 22,
                                size: PrudSize.smaller,
                                removeWidth: true,
                                makeTransparent: true,
                                headColor: prudColorTheme.primary,
                              ),
                              SizedBox(
                                height: 50,
                                child: VerticalDivider(
                                  indent: 0.0,
                                  endIndent: 0.0,
                                  width: 10,
                                  thickness: 2,
                                  color: prudColorTheme.lineC,
                                ),
                              ),
                              PrudDataViewer(
                                field: "Arrival",
                                value: "${tabData.getCountryFlag(widget.journey.destinationCountry)}  ${tabData.getCountryName(widget.journey.destinationCountry)}",
                                valueIsMoney: true,
                                fontSize: 22,
                                size: PrudSize.smaller,
                                removeWidth: true,
                                makeTransparent: true,
                                headColor: prudColorTheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                  spacer.height,
                  PrudContainer(
                    hasPadding: true,
                    hasOnlyTopRadius: true,
                    hasTitle: true,
                    title: "Seat Details",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.center,
                    child: Column(
                      children: [
                        spacer.height,
                        FittedBox(
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PrudDataViewer(
                                field: "Vacant",
                                value: totalVacantSeats,
                                valueIsMoney: true,
                                fontSize: 22,
                                size: PrudSize.smaller,
                                removeWidth: true,
                                makeTransparent: true,
                              ),
                              SizedBox(
                                height: 50,
                                child: VerticalDivider(
                                  indent: 0.0,
                                  endIndent: 0.0,
                                  width: 10,
                                  thickness: 2,
                                  color: prudColorTheme.lineC,
                                ),
                              ),
                              PrudDataViewer(
                                field: "Occupied",
                                value: takenSeats,
                                valueIsMoney: true,
                                fontSize: 22,
                                size: PrudSize.smaller,
                                removeWidth: true,
                                makeTransparent: true,
                                headColor: prudColorTheme.textD,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                  spacer.height,
                  PrudContainer(
                    hasTitle: true,
                    hasPadding: true,
                    hasOnlyTopRadius: true,
                    title: "Bus Details",
                    titleBorderColor: prudColorTheme.bgC,
                    titleAlignment: MainAxisAlignment.center,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        InkWell(
                          onTap: getBus,
                          child: bus != null? BusComponent(bus: bus!,) : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Translate(
                                  text: "Select Bus"
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_sharp,
                                size: 30,
                                color: prudColorTheme.lineB,
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                  spacer.height,
                  PrudContainer(
                      hasTitle: true,
                      hasPadding: true,
                      hasOnlyTopRadius: true,
                      title: "Driver Details",
                      titleBorderColor: prudColorTheme.bgC,
                      titleAlignment: MainAxisAlignment.center,
                      child: Column(
                        children: [
                          mediumSpacer.height,
                          InkWell(
                            onTap: getDriver,
                            child: driver != null? DashboardDriverComponent(driver: driver!, isDashboard: widget.isOperator,) : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Translate(text: "Select Driver"),
                                Icon(
                                  Icons.keyboard_arrow_down_sharp,
                                  size: 30,
                                  color: prudColorTheme.lineB,
                                ),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                  spacer.height,
                  if(!booked) prudWidgetStyle.getLongButton(
                    onPressed: bookNow,
                    text: "Book A Seat Now",
                    shape: 1
                  ),
                  spacer.height,
                  if(passengers.isNotEmpty) PrudPanel(
                    title: "Passengers",
                    hasPadding: true,
                    titleColor: prudColorTheme.primary,
                    bgColor: prudColorTheme.bgC,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            physics: const BouncingScrollPhysics(),
                            itemCount: passengers.length,
                            itemBuilder: (context, index){
                              return PassengerComponent(
                                passenger: passengers[index],
                              );
                            },
                          ),
                        ),
                        spacer.height
                      ],
                    ),
                  ),
                  spacer.height,
                  if(availableSeats.isNotEmpty) PrudPanel(
                    title: "Available Seats",
                    hasPadding: true,
                    titleColor: prudColorTheme.primary,
                    bgColor: prudColorTheme.bgC,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        SeatsComponent(
                          seats: availableSeats,
                          economyPrice: widget.journey.economySeatPrice,
                          businessPrice: widget.journey.businessSeatPrice,
                          executivePrice: widget.journey.executiveSeatPrice,
                          currency: widget.journey.priceCurrencyCode,
                          journeyId: widget.journey.id!,
                          exchangePassengerId: widget.exchangePassengerId,
                          exchangeFromJourneyId: widget.exchangeFromJourneyId,
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  spacer.height,
                  if(widget.isOperator) PrudPanel(
                    title: "Admin Operations",
                    hasPadding: true,
                    bgColor: prudColorTheme.bgC,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        prudWidgetStyle.getLongButton(
                            onPressed: startBoarding,
                            text: "Start Boarding",
                            shape: 1
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                            onPressed: haltJourney,
                            text: "Halt Journey",
                            shape: 1
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                            onPressed: haltBoarding,
                            text: "Halt Boarding",
                            shape: 1
                        ),
                        spacer.height,
                        prudWidgetStyle.getLongButton(
                            onPressed: cancelJourney,
                            text: "Cancel Journey",
                            shape: 1
                        ),
                        spacer.height,
                      ],
                    ),
                  ),
                  if(!widget.isOperator && userIsPassenger) PrudPanel(
                    title: "Passenger Operations",
                    bgColor: prudColorTheme.bgC,
                    hasPadding: true,
                    child: Column(
                      children: [
                        mediumSpacer.height,
                        if(widget.journey.status.toLowerCase() == "active") prudWidgetStyle.getLongButton(
                            onPressed: completeJourney,
                            text: "Complete Journey",
                            shape: 1
                        ),
                        if(widget.journey.status.toLowerCase() == "completed") spacer.height,
                        if(widget.journey.status.toLowerCase() == "completed") prudWidgetStyle.getLongButton(
                            onPressed: rateJourney,
                            text: "Rate Journey",
                            shape: 1
                        ),
                        if(widget.journey.status.toLowerCase() == "completed") spacer.height,
                        if(widget.journey.status.toLowerCase() == "completed") prudWidgetStyle.getLongButton(
                            onPressed: rateBus,
                            text: "Rate Bus",
                            shape: 1
                        ),
                        if(widget.journey.status.toLowerCase() == "completed") spacer.height,
                        if(widget.journey.status.toLowerCase() == "completed") prudWidgetStyle.getLongButton(
                            onPressed: rateDriver,
                            text: "Rate Driver",
                            shape: 1
                        ),
                        spacer.height
                      ],
                    ),
                  ),
                  xLargeSpacer.height,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
