import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/providers/feed/feed_state.dart';
import 'package:instagram_clone/repositories/feed_repository.dart';

import '../../exceptions/custom_exception.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin{
  FeedProvider() : super(FeedState.init());

  Future<void> getFeedList() async {
    try{
      state = state.copyWith(feedStatus: FeedStatus.fetching);

      List<FeedModel> feedList = await read<FeedRepository>().getFeedList();

      state = state.copyWith(
        feedList: feedList,
        feedStatus: FeedStatus.success,
      );
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }
  }

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,
  }) async {
    try{
      state = state.copyWith(feedStatus: FeedStatus.submitting);


      String uid = read<User>().uid;
      FeedModel feedModel = await read<FeedRepository>().uploadFeed(
          files: files,
          desc: desc,
          uid: uid
      );

      state = state.copyWith(feedStatus: FeedStatus.success, feedList: [feedModel ,...state.feedList],);
    } on CustomException catch (_) {
      state = state.copyWith(feedStatus: FeedStatus.error);
      rethrow;
    }

  }
}