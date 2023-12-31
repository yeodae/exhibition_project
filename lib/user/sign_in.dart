import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/firestore_connect/public_query.dart';
import 'package:exhibition_project/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dialog/show_message.dart';
import 'sign_up.dart';
import '../model/user_model.dart';
import '../hash/hash_password.dart';
import '../style/button_styles.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInCheck();
  }
}

class SignInCheck extends StatefulWidget {
  const SignInCheck({super.key});

  @override
  State<SignInCheck> createState() => _SignInCheckState();
}

class _SignInCheckState extends State<SignInCheck> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스 가져옴
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool pwdHide = true; //패스워드 감추기

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      body: SingleChildScrollView( // SingleChildScrollView 추가
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/sign/login_back.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 70,),
                      Image.asset('assets/sign/clearLogo.png', width: 180,),
                      SizedBox(height: 20,),
                      _TextField(_emailController, '이메일', 'email'),
                      SizedBox(height: 20),
                      _TextField(_pwdController, '비밀번호', 'pwd'),
                      SizedBox(height: 80),
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _login,
                                  style: fullGreenButtonStyle(),
                                  child: boldGreyButtonContainer('로 그 인'),
                                ),
                                SizedBox(height: 18),
                                ElevatedButton(
                                  onPressed: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpPage(),
                                      ),
                                    );
                                  },
                                  style: fullLightGreenButtonStyle(),
                                  child: boldGreenButtonContainer('회 원 가 입'),
                                ),
                              ]
                          )
                      ),
                    ],
                  ),
                ),
        )
      )
    );
  }

  Widget _TextField(TextEditingController ctr, String txt, String kind) {
    return TextField(
      controller: ctr,
      obscureText: kind == 'pwd' ? pwdHide : false,
      decoration: InputDecoration(
        labelText: txt,
        suffixIcon: kind == 'pwd' || kind == 'pwdCheck'
            ? IconButton(
          icon: Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Icon(pwdHide ? Icons.visibility_off : Icons.visibility, size: 20,),
          ),
          color: Color.fromRGBO(70, 77, 64, 1.0),
          onPressed: () {
            setState(() {
              pwdHide = !pwdHide;
            });
          },
        )
            : null,
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
              width: 1.8,
            )
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
          ),
        ),
        labelStyle: TextStyle(
          color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 텍스트 색상
        ),
      ),
      onSubmitted: (value) {
        if (kind == 'email') {
          FocusScope.of(context).nextFocus(); // 비밀번호 필드로 이동
        } else if (kind == 'pwd') {
          _login(); // 로그인 시도
        }
      },
    );
  }
  void _login() async {
    String email = _emailController.text;
    String password = _pwdController.text;
    if (email!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 주소를 입력해 주세요.'))
      );
      return null;
    }
    if (password!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀 번호를 입력해 주세요.'))
      );
      return null;
    }
    final userEmail = await getEqualData('user', 'email', email); //이메일 비교

    if (userEmail.docs.isNotEmpty) {
      final userDocument = userEmail.docs.first;
      final userHashPassword = userDocument.get('password');
      final userRandomSalt = userDocument.get('randomSalt');
      bool pwdCheck = isPasswordValid(password, userHashPassword, userRandomSalt);
      print(pwdCheck);
      if (pwdCheck) {
        Provider.of<UserModel>(context, listen: false).signIn(userDocument.id, userDocument.get('status')); //세션 값 부여
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그인 되었습니다.'))
        );
        // Home이 두 번 실행되는 것을 방지하기 위해 Home으로 이동하지 않고 현재 로그인 페이지를 없앰
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        showMessageDialog(context, '비밀번호를 확인해 주세요.');
      }
    } else {
      showMessageDialog(context, '일치하는 아이디가 없습니다.');
    }
  }
}