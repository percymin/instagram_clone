enum AuthStatus {
  authenticated,
  unauthenticated,
}

class AuthState { //객체생성을 해야 사용가능
  final AuthStatus authStatus;

  const AuthState({
    required this.authStatus,
  });

  factory AuthState.init(){
    return AuthState(
      authStatus: AuthStatus.unauthenticated,
    );
  }

  AuthState copyWith({
    AuthStatus? authStatus,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
    );
  }
}