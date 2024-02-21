import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/providers/auth_state.dart';
import 'package:mime/mime.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const AuthRepository({
    required this.firebaseAuth,
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try{
      UserCredential userCredential =
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    bool isverified = userCredential.user!.emailVerified;
    if(!isverified){
      await userCredential.user!.sendEmailVerification();
      await firebaseAuth.signOut();
      throw CustomException(code: 'Exception', message: '인증되지 않은 메일',);
    }

    } on FirebaseException catch(e) {
      throw CustomException(code: e.code, message: e.message!,);
    }
    catch(e){
      throw CustomException(code: 'Exception', message: e.toString(),);
    }
    

  }

  Future<void> signUp({
    required String email,
    required String name,
    required String password,
    required Uint8List? profileImage,
  }) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await userCredential.user!.sendEmailVerification();

      String? downloadUrl = null;

      if (profileImage != null) {
        Reference ref = firebaseStorage.ref().child('profile').child(uid);
        TaskSnapshot snapshot = await ref.putData(profileImage);
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      await firebaseFirestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'profileImage': downloadUrl,
        'feedCount': 0,
        'likes': [],
        'followers': [],
        'following': [],
      });
      firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      CustomException(
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
}
