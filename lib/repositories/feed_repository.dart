import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<List<FeedModel>> getFeedList() async {

    try{
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore.collection('feeds').orderBy('createAt', descending: true).get();
      return await Future.wait(snapshot.docs.map((e) async {

        // firebaseFirestore에서 불러온 feed 중 writer 를 UserModel 로 변환
        Map<String, dynamic> data = e.data();
        DocumentReference<Map<String, dynamic>> writerDocRef = data['writer'];
        DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();
        UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
        data['writer'] = userModel;

        return FeedModel.fromMap(data);
      }).toList());
    } on FirebaseException catch (e) {

      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {

      throw CustomException(
        code: 'Exception',
        message: e.toString(),
      );
    }

  }

  Future<FeedModel> uploadFeed({
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

      DocumentSnapshot<Map<String,dynamic>> userSnapshot =
        await userDocRef.get();
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
        'writer': userModel,
      });


      // firebaseFirestore에 게시글 저장
      // feedModel.toMap(userDocRef: userDocRef) : writer(user)를 firebaseFirestore에 맞는 형태로 변경
      batch.set(feedDocRef, feedModel.toMap(userDocRef: userDocRef));

      // writer(user)의 게시글 갯수 +1
      batch.update(userDocRef, {'feedCount': FieldValue.increment(1),});

      // firebaseFirestore에 실제로 저장
      batch.commit();

      return feedModel;

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