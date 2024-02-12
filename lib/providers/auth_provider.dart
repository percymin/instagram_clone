import 'dart:typed_data';

import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/providers/auth_state.dart';
import 'package:instagram_clone/repositories/auth_repository.dart';

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
}