import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/repositories/auth_repository.dart';
import 'package:state_notifier/state_notifier.dart';

import 'auth_state.dart';

class AuthProvider extends StateNotifier<AuthState> with LocatorMixin{
  AuthProvider() : super(AuthState.init());


  @override
  void update(Locator watch) {
    final user = watch<User?>();

    // user => null
    // unauth

     //user => not null

    if(user != null && user.emailVerified) {
      return;
    }

    if (user ==null && state.authStatus == AuthStatus.unauthenticated) {
      return;
    }

    //logic
    if(user != null) {
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
      );
    } else{
    state = state.copyWith(
    authStatus: AuthStatus.unauthenticated,
    );
    }
  }

  Future<void> signOut() async {
    await read<AuthRepository>().signOut();
  }

  Future<void> signUp({
   required String email,
   required String name,
   required String password,
   required Uint8List? profileImage,
}) async {
    try {
      await read<AuthRepository>().signUp(
          email: email,
          name: name,
          password: password,
          profileImage: profileImage
      );
    } on CustomException catch (_) {
      rethrow;
    }
 }

 Future<void> signIn({
    required String email,
   required String password,
})async {
   try {
     await read<AuthRepository>().signIn(email: email, password: password,);


   } on CustomException catch (_) {
     rethrow;
   }
 }
}