import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/providers/feed/feed_provider.dart';
import 'package:instagram_clone/providers/feed/feed_state.dart';
import 'package:instagram_clone/widgets/avatar_widget.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:instagram_clone/widgets/feed_card_widget.dart';
import 'package:provider/provider.dart';

import '../models/feed_model.dart';
import '../utils/logger.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with AutomaticKeepAliveClientMixin<FeedScreen> {
  late final FeedProvider feedProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    feedProvider = context.read<FeedProvider>();
    _getFeedList();

  }

  void _getFeedList(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await feedProvider.getFeedList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    FeedState feedState = context.watch<FeedState>();
    List<FeedModel> feedList = context.watch<FeedState>().feedList;

    if(feedState.feedStatus == FeedStatus.fetching){
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (feedState.feedStatus == FeedStatus.success && feedList.length == 0) {
      return Center(
        child: Text('Feed가 존재하지않습니다.'),
      );
    }


    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          _getFeedList();
        },
        child: ListView.builder(
          itemCount: feedList.length,
          itemBuilder: (context, index){
            return FeedCardWidget(feedModel: feedList[index]);
          },

        ),
      ),
    );
    
  }


}
