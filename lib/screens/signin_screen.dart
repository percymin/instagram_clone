import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/providers/auth/auth_state.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/providers/auth/auth_provider.dart' as myAuthProvider;
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

import '../exceptions/custom_exception.dart';
import '../utils/logger.dart';
import '../widgets/error_dialog_widget.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isEnabled = true;


  @override
  void dispose() {
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _globalKey,
                  autovalidateMode: _autovalidateMode,
                  child: ListView(
                    shrinkWrap: true,
                    reverse: true,
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_instagram.svg',
                        height: 64,
                        colorFilter: ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      ),
                      SizedBox(height: 20),


                      // 이메일
                      TextFormField(
                        enabled: _isEnabled,
                        controller: _emailEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          filled: true,
                        ),
                        validator: (value) { //검증로직
                          // 1. 아무것도 입력하지않았을때
                          // 2. 공백만 입력했을때
                          // 3. 이메일 형식이 아닐때

                          if (value == null || value
                              .trim()
                              .isEmpty || !isEmail(value.trim())) {
                            return '이메일을 입력하세요.';
                          }
                          return null; //오류 3가지에 아무것도 안걸렸을때 즉 제대로 입력했을때


                        },
                      ),
                      SizedBox(height: 20),


                      // 패스워드
                      TextFormField(
                        enabled: _isEnabled,
                        controller: _passwordEditingController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value
                              .trim()
                              .isEmpty) {
                            return '패스워드를 입력하세요';
                          }
                          if (value.length < 6) {
                            return '패스워드 6글자 이상 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),


                      ElevatedButton(
                        onPressed: _isEnabled ? () async {
                          final form = _globalKey.currentState;

                          if (form == null || !form.validate()) {
                            return;
                          }

                          setState(() {
                            _isEnabled = false;
                            _autovalidateMode = AutovalidateMode.always;
                          });

                          // 로그인 로직
                          try {
                            logger.d(context.read<AuthState>().authStatus);

                            await context.read<myAuthProvider.AuthProvider>().signIn(
                              email: _emailEditingController.text,
                              password: _passwordEditingController.text,

                            );
                            logger.d(context.read<AuthState>().authStatus);


                          } on CustomException catch (e) {
                            setState(() {
                              _isEnabled = true;
                            });
                            errorDialogWidget(context, e);
                          };
                        } : null,
                        child: Text('로그인'),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(fontSize: 20),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                      SizedBox(height: 10),

                      TextButton(
                        onPressed: _isEnabled
                            ? () =>
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (context) => SignupScreen()
                                ))
                            : null,
                        child: Text('회원이 아니신가요? 회원가입하기', style: TextStyle(
                            fontSize: 20),
                        ),
                      )


                    ].reversed.toList(),
                  ),
                ),
              ),
            )
        ),
      ),
    );
  }
}
