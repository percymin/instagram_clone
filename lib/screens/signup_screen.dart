import 'dart:typed_data';

import 'package:instagram_clone/exceptions/custom_exception.dart';
import 'package:instagram_clone/providers/auth_provider.dart' as myAuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/widgets/error_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class SignupScreen extends StatefulWidget {

  const SignupScreen({super.key});


  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  TextEditingController _emailEditingController = TextEditingController();
  TextEditingController _nameEditingController = TextEditingController();
  TextEditingController _passwordEditingController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  Uint8List? _image; // 이미지나 동영상 바이너리 데이터 취급할떄 이용(갤러리에서 선택한 이미지를 이 변수에 대입)
  bool _isEnabled = true;

  Future<void> selectImage() async {
    ImagePicker imagePicker = new ImagePicker();
    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (file != null){

      Uint8List uint8list = await file.readAsBytes(); // 이미지변수에 대입해서 readAsBytes를 이용해서 갤러리에서 선택한 이미지를 코드로 작업할 수 있게
      setState(() {
        _image = uint8list;
      });
  }
  }
  @override
  void dispose(){
    _emailEditingController.dispose();
    _nameEditingController.dispose();
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
                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    SizedBox(height: 20),
                    // 프로필 사진
                    Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          _image == null ?
                          CircleAvatar(
                            radius: 64,
                            backgroundImage: AssetImage('assets/images/profile.png'),
                          ) :CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          ),

                          Positioned(
                            left: 80,
                            bottom: -10,
                            child: IconButton(
                              onPressed: _isEnabled ? () async {
                                await selectImage();
                              } : null,
                              icon: Icon(Icons.add_a_photo),

                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

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

                        if (value == null || value.trim().isEmpty || !isEmail(value.trim())){
                          return '이메일을 입력하세요.';
                        }
                        return null; //오류 3가지에 아무것도 안걸렸을때 즉 제대로 입력했을때



                      },
                    ),
                    SizedBox(height: 20),

                    // 이름
                    TextFormField(
                      enabled: _isEnabled,
                      controller: _nameEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.account_circle),
                        filled: true,
                      ),
                      validator: (value){
                        if (value == null || value.trim().isEmpty){
                          return '이름을 입력하세요.';
                        }
                        if(value.length < 3 || value.length > 10 ){
                          return '이름은 최소 3글자, 최대 10글자 까지 입력 가능합니다.';
                        }
                        return null;

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
                      validator: (value){
                        if (value == null || value.trim().isEmpty){
                          return '패스워드를 입력하세요';
                        }
                        if (value.length < 6){
                          return '패스워드 6글자 이상 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // 패스워드 확인
                    TextFormField(
                      enabled: _isEnabled,
                      obscureText: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                      ),
                      validator: (value){
                        if (_passwordEditingController.text != value) {
                          return '패스워드가 일치하지 않습니다';
                        }
                        return null;

                      },
                    ),
                    SizedBox(height: 40),

                    ElevatedButton(
                      onPressed: _isEnabled ? () async {
                        final form = _globalKey.currentState;

                        if (form == null || !form.validate()) {
                          return ;
                        }

                        setState(() {
                          _isEnabled = false;
                          _autovalidateMode = AutovalidateMode.always;
                        });

                        //회원가입 로직
                        try {
                          await context.read<myAuthProvider.AuthProvider>().signUp(
                            email: _emailEditingController.text,
                            name: _nameEditingController.text,
                            password: _nameEditingController.text,
                            profileImage: _image,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('인증 메일을 전송했습니다.'),
                              duration: Duration(seconds: 120),

                            ),
                          );
                        } on CustomException catch (e){
                          setState(() {
                            _isEnabled = true;
                          });
                          errorDialogWidget(context, e);
                        };

                      } : null,
                      child: Text('회원가입'),
                      style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(fontSize: 20),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextButton(
                        onPressed: _isEnabled ?  () {} : null,
                        child: Text('이미 회원이신가요? 로그인 하기', style: TextStyle(fontSize: 20),
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
