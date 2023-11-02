import 'package:exhibition_project/admin/artist/artist_list.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:exhibition_project/firestore_connect/artist.dart';
import 'package:exhibition_project/style/button_styles.dart';
import 'package:exhibition_project/widget/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ArtistEditAdditionPage extends StatelessWidget {
  String? documentId;
  ArtistEditAdditionPage({Key? key, required this.documentId});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ArtistEditAddition(documentId: documentId),
    );
  }
}

class ArtistEditAddition extends StatefulWidget {
  String? documentId;
  ArtistEditAddition({Key? key, required this.documentId});
  @override
  _ArtistEditAdditionState createState() => _ArtistEditAdditionState();
}

class _ArtistEditAdditionState extends State<ArtistEditAddition> {
  List<List<TextEditingController>> educationControllers = [
    [TextEditingController(), TextEditingController()]
  ];
  List<List<TextEditingController>> historyControllers = [
    [TextEditingController(), TextEditingController()]
  ];
  List<List<TextEditingController>> awardsControllers = [
    [TextEditingController(), TextEditingController()]
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(15),
        child: Container(
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('id : ${widget.documentId}'),
                  // 항목, 컨트롤러, 생성, 삭제
                  textControllerBtn('학력', educationControllers, () {
                      setState(() {
                        educationControllers.add([TextEditingController(), TextEditingController()]);
                      });
                    }, (int i) {
                      setState(() {
                        educationControllers.removeAt(i);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  textControllerBtn('활동', historyControllers, () {
                      setState(() {
                        historyControllers.add([TextEditingController(), TextEditingController()]);
                      });
                    }, (int i) {
                      setState(() {
                        historyControllers.removeAt(i);
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  textControllerBtn('이력', awardsControllers, () {
                      setState(() {
                        awardsControllers.add([TextEditingController(), TextEditingController()]);
                      });
                    }, (int i) {
                      setState(() {
                        awardsControllers.removeAt(i);
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () async {
        // 입력된 세부 정보 추가
        String year;
        String content;
        for (var i = 0; i < educationControllers.length; i++) {
          year = educationControllers[i][0].text;
          content = educationControllers[i][1].text;
          if (year.isNotEmpty && content.isNotEmpty) // 값이 비어있지 않을 경우
            await addArtistDetails('artist', 'artist_education', widget.documentId!, year, content);
        }
        for (var i = 0; i < historyControllers.length; i++) {
          year = historyControllers[i][0].text;
          content = historyControllers[i][1].text;
          if (year.isNotEmpty && content.isNotEmpty)
            await addArtistDetails('artist', 'artist_history', widget.documentId!, year, content);
        }
        for (var i = 0; i < awardsControllers.length; i++) {
          year = awardsControllers[i][0].text;
          content = awardsControllers[i][1].text;
          if (year.isNotEmpty && content.isNotEmpty)
            await addArtistDetails('artist', 'artist_awards', widget.documentId!, year, content);
        }
        await showMoveDialog(context, '작가가 성공적으로 추가되었습니다.', () => ArtistList());
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.green)
      ),
      child: boldGreyButtonContainer('저장하기'),
    );
  }
}
