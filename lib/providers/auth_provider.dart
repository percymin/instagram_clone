import 'dart:typed_data';

import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/repositories/auth_repository.dart';

import 'auth_state.dart';

class AuthProvider extends StateNotifier<AuthState> with LocatorMixin{
  AuthProvider() : super(AuthState.init());

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

     state = state.copyWith(
       authStatus: AuthStatus.authenticated,
     );
   } on CustomException catch (_) {
     rethrow;
   }
 }
}