import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user_model.dart';

class AvatarWidget extends StatelessWidget {
  final UserModel userModel;
  const AvatarWidget({super.key, required this.userModel,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: userModel.profileImage == null
          ? ExtendedAssetImageProvider('assets/images/profile.png') as ImageProvider
          : ExtendedNetworkImageProvider(userModel.profileImage!),
      radius: 18,
    );
  }
}
