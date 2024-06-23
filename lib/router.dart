import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prudapp/pages/ads/ads.dart';
import 'package:prudapp/pages/ads/ads_details.dart';
import 'package:prudapp/pages/giftcards/gift_cards.dart';
import 'package:prudapp/pages/home/home.dart';
import 'package:prudapp/pages/influencers/influencers.dart';
import 'package:prudapp/pages/recharge/recharge.dart';
import 'package:prudapp/pages/switzstores/product_details.dart';
import 'package:prudapp/pages/switzstores/products.dart';
import 'package:prudapp/pages/switzstores/switz_stores.dart';
import 'package:prudapp/pages/travels/switz_travels.dart';
import 'package:prudapp/pages/travels/tabs/hotels/hotel_details.dart';
import 'package:prudapp/pages/viewsparks/view_spark.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

final GoRouter prudRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return MyHomePage(title: 'Prudapp',);
      },
      redirect: (BuildContext context, GoRouterState state) {
        // if the path is null or empty, go to '/'
        if(state.fullPath?.isEmpty ?? true) return '/';
        // otherwise try to go wherever we were trying to go before
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: "products",
          builder: (BuildContext context, GoRouterState state) {
            return const Products(category: 'wears',);
          },
        )
      ]
    ),
    GoRoute(
      path: '/home',
      name: 'my-home',
      builder: (BuildContext context, GoRouterState state) {
        return MyHomePage(title: 'Prudapp',);
      },
    ),
    GoRoute(
      path: '/sparks',
      name: 'sparks',
      builder: (BuildContext context, GoRouterState state) {
        return const ViewSpark();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'mine',
          name: 'my_sparks',
          builder: (BuildContext context, GoRouterState state) {
            return const ViewSpark(tab: 0,);
          },
        ),
        GoRoute(
          path: 'new_spark',
          name: 'new_sparks',
          builder: (BuildContext context, GoRouterState state) {
            return const ViewSpark(tab: 2,);
          },
        ),
        GoRoute(
          path: 'other_sparks',
          name: 'other_sparks',
          builder: (BuildContext context, GoRouterState state) {
            return const ViewSpark(tab: 1,);
          },
        ),
      ]
    ),
    GoRoute(
      path: '/influencers',
      name: 'influencers',
      builder: (BuildContext context, GoRouterState state) {
        return const Influencers();
      },
    ),
    GoRoute(
      path: '/SwitzStores',
      name: 'SwitzStores',
      builder: (BuildContext context, GoRouterState state) {
        return const SwitzStores();
      },
    ),
    GoRoute(
      path: '/products',
      name: 'products',
      builder: (BuildContext context, GoRouterState state) {
        return const SwitzStores();
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':product_id',
          name: 'product',
          builder: (BuildContext context, GoRouterState state) {
            String proId = state.pathParameters['product_id']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveProductReferral(proId, linkId);
            return ProductDetails(
              productId: proId,
              affLinkId: linkId,
            );
          },
        ),
        GoRoute(
          path: 'category/:category_name',
          name: 'product_category',
          builder: (BuildContext context, GoRouterState state) {
            return Products(category: state.pathParameters['category_name']!);
          },
        ),
      ]
    ),
    GoRoute(
      path: '/ads',
      name: 'ads',
      builder: (BuildContext context, GoRouterState state) {
        return const Ads();
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':ads_id',
          name: 'ads_detail',
          builder: (BuildContext context, GoRouterState state) {
            String adsId = state.pathParameters['ads_id']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveAdsReferral(adsId, linkId);
            return AdsDetails(
              adsId: adsId,
              affLinkId: linkId,
            );
          },
        )
      ]
    ),
    GoRoute(
      path: '/recharge',
      name: 'recharge',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveRechargeReferral(linkId);
        return Recharge(affLinkId: linkId,);
      },
      routes: <RouteBase>[
        GoRoute(
          path: "airtime",
          name: 'airtime',
          builder: (BuildContext context, GoRouterState state) {
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveRechargeReferral(linkId);
            return Recharge(affLinkId: linkId, tab: 0,);
          },
        ),
        GoRoute(
          path: "Data Bundles",
          name: 'data_bundles',
          builder: (BuildContext context, GoRouterState state) {
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveRechargeReferral(linkId);
            return Recharge(affLinkId: linkId, tab: 1,);
          },
        ),
        GoRoute(
          path: "Utilities",
          name: 'utilities',
          builder: (BuildContext context, GoRouterState state) {
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveRechargeReferral(linkId);
            return Recharge(affLinkId: linkId, tab: 2,);
          },
        )
      ]
    ),
    GoRoute(
      path: '/flight',
      name: 'flight',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveFlightReferral(linkId);
        return const SwitzTravels(tab: 0,);
      },
    ),
    GoRoute(
      path: '/buses',
      name: 'buses',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveBusReferral(linkId);
        return const SwitzTravels(tab: 1,);
      },
    ),
    GoRoute(
      path: '/hotels',
      name: 'hotels',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveHotelsReferral(linkId);
        return const SwitzTravels(tab: 2,);
      },
    ),
    GoRoute(
      path: '/hotels/:hotel_id',
      name: 'hotel_details',
      builder: (BuildContext context, GoRouterState state) {
        String hotelId = state.pathParameters['hotel_id']!;
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveHotelReferral(hotelId, linkId);
        return HotelDetails(hotelId: hotelId, affLinkId: linkId,);
      },
    ),
    GoRoute(
      path: '/gift_cards',
      name: 'gift_cards',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveGiftReferral(linkId);
        return GiftCards(affLinkId: linkId,);
      },
    ),
  ],
);