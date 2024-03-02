import '../../models/feed_model.dart';

enum FeedStatus{
  init,
  submitting,
  fetching,
  success,
  error,
}

class FeedState{
  final FeedStatus feedStatus;
  final List<FeedModel> feedList;

  const FeedState({
    required this.feedStatus,
    required this.feedList,
  });

  factory FeedState.init(){
    return FeedState(
      feedStatus: FeedStatus.init,
      feedList: [],
    );
  }

  FeedState copyWith({
    FeedStatus? feedStatus,
    List<FeedModel>? feedList,
  }) {
    return FeedState(
      feedStatus: feedStatus ?? this.feedStatus,
      feedList: feedList ?? this.feedList,
    );
  }

}

