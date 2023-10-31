import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/user.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/tab_wigets.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:country_calling_code_picker/picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArtistEditDetailsPage extends StatelessWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동하는 함수
  final Map<String, String> formData; // 입력한 값을 담는 맵
  const ArtistEditDetailsPage({Key? key, required this.moveToNextTab, required this.formData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ArtistEditDetails(moveToNextTab: moveToNextTab, formData: formData)
    );
  }
}

class ArtistEditDetails extends StatefulWidget {
  final Function moveToNextTab; // 다음 인덱스로 이동하는 함수
  final Map<String, String> formData; // 입력한 값을 담는 맵
  const ArtistEditDetails({Key? key, required this.moveToNextTab, required this.formData});

  @override
  State<ArtistEditDetails> createState() => _ArtistEditDetailsState();
}

class _ArtistEditDetailsState extends State<ArtistEditDetails> {
  final _key = GlobalKey<FormState>(); // Form 위젯과 연결. 동적인 행동 처리
  Country? _country;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _englishNameController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _introduceController = TextEditingController();
  bool allFieldsFilled = false; // 모든 값을 입력하지 않으면 비활성화

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async{ //동기 맞추기
    final country = await getDefaultCountry(context);
    setState(() {
      _country = country;
      _nameController.addListener(updateButtonState);
      _englishNameController.addListener(updateButtonState);
      _nationalityController.addListener(updateButtonState);
      _expertiseController.addListener(updateButtonState);
      _introduceController.addListener(updateButtonState);
    });
  }

  void updateButtonState() async {
    // 텍스트 필드 값이 변경될 때마다 allFieldsFilled를 다시 계산하여 버튼의 활성화 상태를 업데이트합니다.
    setState(() {
      allFieldsFilled = _nameController.text.isNotEmpty &&
          _englishNameController.text.isNotEmpty &&
          _nationalityController.text.isNotEmpty &&
          _expertiseController.text.isNotEmpty &&
          _introduceController.text.isNotEmpty;
    });
  }

  void _countrySelect() async {
    final selectedCountry = await showCountryPickerSheet(
      context,
      cancelWidget: Center(
        child: Container(),
      ),
    );

    if (selectedCountry != null) {
      setState(() {
        _country = selectedCountry;
        _nationalityController.text = _country!.name; // 예시로 국가의 이름을 표시합니다.
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Color.fromRGBO(70, 77, 64, 1.0), Colors.white, 0.9),
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(15),
        child: Center(
          child: Form(
            key: _key,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textFieldLabel('작가명'),
                          textFieldInput(_nameController, "작가명" , 'name'),
                          SizedBox(height: 30),
                          textFieldLabel('영어명'),
                          textFieldInput(_englishNameController,"영어명", 'englishName'),
                          SizedBox(height: 30),
                          textFieldLabel('국적'),
                          textFieldInput(_nationalityController, "국적", 'nationality'),
                          ElevatedButton(
                              onPressed: () => _countrySelect(),
                              child: Text("국가선택")
                          ),
                          SizedBox(height: 30),
                          textFieldLabel('전문 분야'),
                          textFieldInput(_expertiseController, "전문 분야", 'expertise'),
                          SizedBox(height: 30),
                          textFieldLabel('소개'),
                          textFieldInput(_introduceController, "소개", 'introduce'),
                          SizedBox(height: 30)
                        ],
                      )
                  ),

                  // 추가
                  Container(
                      margin: EdgeInsets.all(20),
                      child: submitButton()
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  TextFormField textFieldInput(final ctr, String hintTxt, String kind) {
    return TextFormField(
        enabled: kind != 'nationality',
        controller: ctr,
        autofocus: true,
        inputFormatters: [
          kind != 'introduce' ? LengthLimitingTextInputFormatter(30) : LengthLimitingTextInputFormatter(1000), // 최대 길이 설정
        ],
        decoration: InputDecoration(
          hintText: hintTxt, //입력란에 나타나는 텍스트
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
                width: 1.8,
              )
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(70, 77, 64, 1.0), // 입력 필드 비활성화 상태
            ),
          ),
        )
    );
  }

  Widget submitButton() {
    // 모든 값을 입력하지 않으면 비활성화
    return ElevatedButton(
      onPressed: allFieldsFilled ? () async {
        try {
          widget.moveToNextTab(); // 여기서 입력한 값을 보내고 싶어
        } on FirebaseAuthException catch (e) {
          firebaseException(e);
        } catch (e) {
          print(e.toString());
        }
      } : null, // 버튼이 비활성 상태인 경우 onPressed를 null로 설정
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(allFieldsFilled ? Colors.green : Colors.grey), // 모든 값을 입력했다면 그린 색상으로 활성화
      ),
      child: boldGreyButtonContainer('다음'),
    );
  }
}