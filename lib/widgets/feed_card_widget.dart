import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:instagram_clone/models/feed_model.dart';

import '../models/user_model.dart';
import 'avatar_widget.dart';

class FeedCardWidget extends StatefulWidget {
  final FeedModel feedModel;
  const FeedCardWidget({super.key, required this.feedModel});

  @override
  State<FeedCardWidget> createState() => _FeedCardWidgetState();
}

class _FeedCardWidgetState extends State<FeedCardWidget> {
  final CarouselController carouselController = CarouselController();
  int _indicatorindex = 0;

  Widget _imageZoomInOutWidget(String imageUrl){
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
            context: context,
            pageBuilder: (context,_, __) {
              return InteractiveViewer(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: ExtendedImage.network(imageUrl),),);
        },);
      },
        child: ExtendedImage.network(imageUrl, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),);
  }

  Widget _imageSliderWidget(List<String> imageUrls){
    return Stack(
      children: [
        CarouselSlider(
          carouselController: carouselController,
          items: imageUrls.map((url) => _imageZoomInOutWidget(url)).toList(),
          options: CarouselOptions(
            viewportFraction: 1.0,
            height: MediaQuery.of(context).size.height * 0.35,
            onPageChanged: (index, reason){
              setState(() {
                _indicatorindex = index;
              });

            },

          ),
        ),
        Positioned.fill(

          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageUrls.asMap().keys.map((e) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(_indicatorindex == e ? 0.9 : 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    FeedModel feedModel = widget.feedModel;
    UserModel userModel = feedModel.writer;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              children: [
                AvatarWidget(userModel: userModel),
                SizedBox(width: 8,),
                Expanded(
                    child: Text(
                      userModel.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
          _imageSliderWidget(feedModel.imageUrls),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                ),

                SizedBox(width: 5),
                Text(
                  feedModel.likeCount.toString(),
                  style: TextStyle(fontSize: 16),
                ),

                SizedBox(width: 10),

                Icon(
                  Icons.comment_outlined,
                  color: Colors.white,
                ),

                SizedBox(width: 5),
                Text(
                  feedModel.commentCount.toString(),
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),

                Text(feedModel.createAt.toDate().toString().split(' ')[0], style: TextStyle(fontSize: 16,),),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              feedModel.desc,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
