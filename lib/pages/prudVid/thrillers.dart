import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:prudapp/components/comments_detail_component.dart';
import 'package:prudapp/components/video_player_widget.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:prudapp/singletons/tab_data.dart';
import '../../../components/translate_text.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class Thrillers extends StatefulWidget {
  final int? tab;
  final String? category;

  const Thrillers({super.key, this.tab, this.category, });

  @override
  ThrillersState createState() => ThrillersState();
}

class ThrillersState extends State<Thrillers> with TickerProviderStateMixin {
  late PageController _pageController;
  late TabController _tabController;
  final List<String> categories = channelCategories;
  List<ChannelVideo> videos = [];
  int currentVideoIndex = 0;
  String selectedCategory = channelCategories[0];
  bool isLoading = false;
  bool hasMore = true;
  final vidPort = ReceivePort(); 
  Isolate? vidIsolate;
  Isolate? _dataIsolate;
  ReceivePort? _receivePort;
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );
  int lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: categories.length, vsync: this);
    selectedCategory = widget.category ?? categories[0];
    _initializeData();
    _setupIsolate();
  }

  void _setupIsolate() async {
    _receivePort = ReceivePort();
    _dataIsolate = await Isolate.spawn(_dataProcessingIsolate, _receivePort!.sendPort);
    
    _receivePort!.listen((data) {
      if (data is List<ChannelVideo> && mounted) {
        setState(() {
          videos.addAll(data);
          isLoading = false;
        });
      }
    });
  }

  void _dataProcessingIsolate(SendPort sendPort) {
    // Background data processing
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    
    receivePort.listen((message) async {
      if (message == 'loadMore') {
        // Simulate loading more videos
        await getVideos(sendPort);
      }
    });
  }

  Future<void> getVideos(SendPort? sendPort) async {
    tryAsync("getVideos", () async {
      if(iCloud.affAuthToken != null && myStorage.user != null){
        VideoSuggestionServiceArg suggestionArgs = VideoSuggestionServiceArg(
          sendPort: vidPort.sendPort,
          cred: cred,
          onlyVideos: true,
          unwantedBroadcasts: prudVidNotifier.notInterestedBroadcasts,
          unwantedChannels: prudVidNotifier.dontRecommend,
          unwantedVideos: prudVidNotifier.notInterestedVideos,
          broadcastSearchText: searchHistory.join(" "),
          promotedType: VideoSearchType.categoryTitleTags,
          videoCateria: VideoSearchServiceArg(
            sendPort: vidPort.sendPort, 
            cred: cred, 
            searchType: VideoSearchType.categoryTitleTags,
            category: selectedCategory,
            limit: 50,
            offset: lastOffset,
            searchText: searchHistory.join(" ")
          ),
        );
        vidIsolate = await Isolate.spawn(
          getVideoAndBroadcastSuggestions, 
          suggestionArgs, onError: vidPort.sendPort, 
          onExit: vidPort.sendPort
        );
        vidPort.listen((resp){
          if(resp != null && resp is List && resp.isNotEmpty){
            List<dynamic> related = [];
            related = resp.map((item) {
              if(item["message"] == null){
                return ChannelVideo.fromJson(item);
              }
            }).toList();
            if(mounted) setState(() => lastOffset += related.length);
            if(sendPort != null){
              sendPort.send(related);
            }else{
              if(mounted) setState(() => videos = related as List<ChannelVideo>);
            }
          }
        });
      }
    });
  }

  Future<void> _initializeData() async {
    if(mounted) setState(() => isLoading = true);
    await getVideos(null);
    if(mounted) setState(() => isLoading = false);
  }

  void _loadMoreVideos() {
    if (!isLoading && hasMore && mounted) {
      setState(() {
        isLoading = true;
      });
      
      // Use isolate for background loading
      _receivePort?.sendPort.send('loadMore');
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
      videos.clear();
      currentVideoIndex = 0;
    });
    _initializeData();
  }

  void like(int index){
    if(index < videos.length && videos[index].thriller != null){
      tryOnly("like", (){
        prudVidNotifier.addToLikeOrDislikeActions(
          ActionType.thriller,
          LikeDislikeAction(
            itemId: videos[index].thriller!.id!, liked: 1
          ),
          context,
        );
      });
    }
  }

  void dislike(int index){
    if(index < videos.length && videos[index].thriller != null){
      tryOnly("like", (){
        prudVidNotifier.addToLikeOrDislikeActions(
          ActionType.thriller,
          LikeDislikeAction(
            itemId: videos[index].thriller!.id!, liked: 0
          ),
          context,
        );
      });
    }
  }

  void _toggleLike(int index) {
    like(index);  
  }

  void _toggleDislike(int index) {
    dislike(index);
  }

  void _showComments(VideoThriller thriller, String? channelId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: prudColorTheme.bgF,
      elevation: 0,
      isDismissible: false,
      barrierColor: prudColorTheme.bgF,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return CommentsDetailComponent(
          membersOnly: false,
          id: thriller.id!,
          channelOrStreamId: channelId,
          commentType: CommentType.thrillerComment,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => iCloud.goBack(context),
                    splashRadius: 20,
                  ),
                  Expanded(
                    child: Translate(
                      text: "Thrillers",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            
            // Category badges
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _onCategoryChanged(category);
                        }
                      },
                      backgroundColor: Colors.grey[800],
                      selectedColor: Colors.white,
                      checkmarkColor: Colors.black,
                    ),
                  );
                },
              ),
            ),
            
            // Video feed
            Expanded(
              child: videos.isEmpty
                  ? Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'No videos available',
                              style: TextStyle(color: Colors.white),
                            ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                          _loadMoreVideos();
                        }
                        return true;
                      },
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        itemCount: videos.length,
                        onPageChanged: (index) {
                          setState(() {
                            currentVideoIndex = index;
                          });
                          
                          // Load more when near the end
                          if (index >= videos.length - 3) {
                            _loadMoreVideos();
                          }
                        },
                        itemBuilder: (context, index) {
                          return VideoPlayerWidget(
                            video: videos[index].thriller!,
                            channelId: videos[index].channelId,
                            title: videos[index].title,
                            tags: videos[index].tags,
                            channel: videos[index].channel,
                            onLike: () => _toggleLike(index),
                            onDislike: () => _toggleDislike(index),
                            onComment: () => _showComments(videos[index].thriller!, videos[index].channelId),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _dataIsolate?.kill();
    vidIsolate?.kill();
    _receivePort?.close();
    vidPort.close();
    super.dispose();
  }
}