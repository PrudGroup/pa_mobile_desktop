import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/pages/ads/ads.dart';
import 'package:prudapp/pages/ads/ads_details.dart';
import 'package:prudapp/pages/home/home.dart';
import 'package:prudapp/pages/influencers/influencers.dart';
import 'package:prudapp/pages/prudStreams/prud_streams.dart';
import 'package:prudapp/pages/prudStreams/views/vid_stream_detail.dart';
import 'package:prudapp/pages/prudVid/prud_comedy.dart';
import 'package:prudapp/pages/prudVid/prud_cuisine.dart';
import 'package:prudapp/pages/prudVid/prud_learn.dart';
import 'package:prudapp/pages/prudVid/prud_movies.dart';
import 'package:prudapp/pages/prudVid/prud_music.dart';
import 'package:prudapp/pages/prudVid/prud_news.dart';
import 'package:prudapp/pages/prudVid/prud_vid.dart';
import 'package:prudapp/pages/prudVid/prud_vid_studio.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/channel_view.dart';
import 'package:prudapp/pages/prudVid/tabs/views/channel_detail.dart';
import 'package:prudapp/pages/prudVid/tabs/views/video_detail.dart';
import 'package:prudapp/pages/prudVid/thriller_views/thriller_detail.dart';
import 'package:prudapp/pages/prudVid/thrillers.dart';
import 'package:prudapp/singletons/settings_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';

final GoRouter prudRouter = GoRouter(
  initialLocation: localSettings.returnToLastPage(),
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return MyHomePage(title: 'Prudapp',) /*const JourneyOperations()*/;
      },
      redirect: (BuildContext context, GoRouterState state) {
        // if the path is null or empty, go to '/'
        if(state.fullPath?.isEmpty ?? true) return '/';
        // otherwise try to go wherever we were trying to go before
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          path: "videos",
          builder: (BuildContext context, GoRouterState state) {
            return const Thrillers();
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
      path: '/influencers',
      name: 'influencers',
      builder: (BuildContext context, GoRouterState state) {
        return const Influencers();
      },
    ),
    GoRoute(
      path: '/movies',
      name: 'Movies',
      builder: (BuildContext context, GoRouterState state) {
        return const PrudMovies();
      },
    ),
    GoRoute(
      path: '/thrillers',
      name: 'thrillers',
      builder: (BuildContext context, GoRouterState state) {
        return const Thrillers();
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':thriller_id',
          name: 'thriller',
          builder: (BuildContext context, GoRouterState state) {
            String tid = state.pathParameters['thriller_id']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveThrillerReferral(tid, linkId);
            return ThrillerDetail(
              thrillerId: tid,
              referralLinkId: linkId,
            );
          },
        ),
        GoRoute(
          path: 'category/:category_name',
          name: 'thriller_category',
          builder: (BuildContext context, GoRouterState state) {
            return Thrillers(category: state.pathParameters['category_name']!);
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
      path: '/watch',
      name: 'watch_videos',
      builder: (BuildContext context, GoRouterState state) {
        return const PrudVid(tab: 0,);
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':vid',
          name: 'watch_video',
          builder: (BuildContext context, GoRouterState state) {
            String vid = state.pathParameters['vid']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveVideoReferral(vid, linkId);
            return VideoDetail(
              videoId: vid,
              affLinkId: linkId,
            );
          },
        ),
        GoRoute(
          path: 'category/:category_name',
          name: 'watch_video_category',
          builder: (BuildContext context, GoRouterState state) {
            String category = state.pathParameters['category_name']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveGeneralReferral(linkId);
            switch(category.toLowerCase()){
              case "movies": return PrudMovies(affLinkId: linkId,);
              case "music": return PrudMusic(affLinkId: linkId);
              case "cuisines": return PrudCuisine(affLinkId: linkId);
              case "news": return PrudNews(affLinkId: linkId);
              case "comedy": return PrudComedy(affLinkId: linkId);
              default: return PrudLearn(affLinkId: linkId,);
            }
          },
        )
      ]
    ),
    GoRoute(
      path: '/streams',
      name: 'streams',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveGeneralReferral(linkId);
        return const PrudStreams(tab: 0,);
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':sid',
          name: 'streaming',
          builder: (BuildContext context, GoRouterState state) {
            String sid = state.pathParameters['sid']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveStreamReferral(sid, linkId);
            return VidStreamDetail(
              sid: sid,
              referralLinkId: linkId,
            );
          },
        ),
        GoRoute(
          path: 'country/:country_code',
          name: 'streaming_via_country',
          builder: (BuildContext context, GoRouterState state) {
            String country = state.pathParameters['country_code']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveGeneralReferral(linkId);
            return PrudStreams(searchByCountry: true, countryCode: country,);
          },
        )
      ]
    ),
    GoRoute(
      path: '/channels',
      name: 'channels',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveGeneralReferral(linkId);
        return PrudVid(tab: 0, viewByChannels: true, affLinkId: linkId,);
      },
      routes: <RouteBase>[
        GoRoute(
          path: ':cid',
          name: 'channel',
          builder: (BuildContext context, GoRouterState state) {
            String cid = state.pathParameters['cid']!;
            String? linkId = state.uri.queryParameters['link_id'];
            if(linkId != null) myStorage.saveChannelReferral(cid, linkId);
            if(localSettings.lastRouteData != null && localSettings.lastRouteData!["channel"] != null){
              return ChannelView(
                channel: VidChannel.fromJson(localSettings.lastRouteData!["channel"]),
                isOwner: localSettings.lastRouteData!["isOwner"],
              );
            }
            return ChannelDetail(cid: cid);
          },
        )
      ]
    ),
    GoRoute(
      path: '/prudVid',
      name: 'prudVid',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        if(linkId != null) myStorage.saveGeneralReferral(linkId);
        return PrudVid(affLinkId: linkId,);
      },
    ),
    GoRoute(
      path: '/prud_studio',
      name: 'prud_studio',
      builder: (BuildContext context, GoRouterState state) {
        String? linkId = state.uri.queryParameters['link_id'];
        String? tab = state.uri.queryParameters["tab"];
        localSettings.updateLastRoute(state.uri.toString());
        if(tab != null) {
          return PrudVidStudio(affLinkId: linkId, tab: int.parse(tab),);
        }else{
          return PrudVidStudio(affLinkId: linkId);
        }
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/add_new_video',
          name: 'add_new_video',
          builder: (BuildContext context, GoRouterState state) {
            dynamic data = state.extra;
            if(data != null){
              localSettings.updateLastRoute(state.uri.toString());
              localSettings.updateLastRouteData(data);
            }else{
              data = {
                "channel": localSettings.lastRouteData?["channel"],
                "creatorId": localSettings.lastRouteData?["creatorId"],
              };
            }
            return AddVideo(
              channel: VidChannel.fromJson(data["channel"]),
              creatorId: data["creatorId"], 
            );
          },
        )
      ]
    ),
  ],
);