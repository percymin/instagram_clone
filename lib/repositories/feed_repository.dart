import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_clone/models/feed_model.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/utils/logger.dart';
import 'package:uuid/uuid.dart';

import '../exceptions/custom_exception.dart';

class FeedRepository{
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
});

  Future<void> uploadFeed({
    required List<String> files,
    required String desc,
    required String uid,
}) async {
    // a-z alphabet
    // 0-9 num
    // - 4
    List<String> imageUrls = [];
    try {
      WriteBatch batch = firebaseFirestore.batch();
      String feedId = Uuid().v1();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> feedDocRef = firebaseFirestore.collection('feeds').doc(feedId);

      DocumentReference<Map<String, dynamic>> userDocRef = firebaseFirestore.collection('users').doc(uid);

      // storage 참고
      Reference ref = firebaseStorage.ref().child('feeds').child(feedId);

      List<String> imageUrls = await Future.wait(files.map((e) async {
        String imageId = Uuid().v1();
        TaskSnapshot taskSnapshot =await ref.child(imageId).putFile(File(e));
        return await taskSnapshot.ref.getDownloadURL();
      }).toList());

      DocumentSnapshot<Map<String,dynamic>> userSnapshot = await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      FeedModel feedModel = FeedModel.fromMap({
        'uid': uid,
        'feedId': feedId,
        'desc': desc,
        'imageUrls': imageUrls,
        'likes': [],
        'likeCount': 0,
        'commentCount': 0,
        'createAt': Timestamp.now(),
        'writer': userDocRef,
      });


      //await feedDocRef.set(feedModel.toMap(userDocRef: userDocRef));
      batch.set(feedDocRef, feedModel.toMap(userDocRef: userDocRef));

      // here2

       //await userDocRef.update({
       // 'feedCount': FieldValue.increment(1),
       //});

      batch.update(userDocRef, {
        'feedCount': FieldValue.increment(1),
        });

      throw CustomException(code: 'ex', message: 'test');

      batch.commit();

    } on FirebaseException catch (e) {
      _deleteImage(imageUrls);


      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      _deleteImage(imageUrls);
      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }

  }
  void _deleteImage(List<String> imageUrls){
    imageUrls.forEach((element) async {
      await firebaseStorage.refFromURL(element).delete();
    });
  } 
}