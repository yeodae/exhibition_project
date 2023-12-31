import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../model/user_model.dart';

class App extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 9,
        child: JTBI(),
      );
  }
}

class JTBI extends StatefulWidget {

  @override
  _JTBIState createState() => _JTBIState();
}

class _JTBIState extends State<JTBI> with SingleTickerProviderStateMixin {
  String sessionId = "";
  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isSignIn) {
      // 사용자가 로그인한 경우
      sessionId = um.userNo!;
      print(sessionId);
    } else {
      // 사용자가 로그인하지 않은 경우
      sessionId = "없음";
      print("로그인 안됨");
      // 여기서 _tabController 초기화
      _tabController = TabController(length: 9, vsync: this);
      group1Score = 0.0;
      group1OppositeScore = 0.0;
      group2Score = 0.0;
      group2OppositeScore = 0.0;
      group3Score = 0.0;
      group3OppositeScore = 0.0;
      group4Score = 0.0;
      group4OppositeScore = 0.0;
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 여기서 _tabController 초기화
    _tabController = TabController(length: 9, vsync: this);
    group1Score = 0.0;
    group1OppositeScore = 0.0;
    group2Score = 0.0;
    group2OppositeScore = 0.0;
    group3Score = 0.0;
    group3OppositeScore = 0.0;
    group4Score = 0.0;
    group4OppositeScore = 0.0;
  }

  late TabController _tabController;
  List<int> selectedAnswerIndices = List.generate(12, (index) => -1);

  double totalWeight = 15;

  double group1Score = 0.0;
  double group1OppositeScore = 0.0;
  double group2Score = 0.0;
  double group2OppositeScore = 0.0;
  double group3Score = 0.0;
  double group3OppositeScore = 0.0;
  double group4Score = 0.0;
  double group4OppositeScore = 0.0;

  List<int> group1Counts = [];
  List<int> group2Counts = [];
  List<int> group3Counts = [];
  List<int> group4Counts = [];

  List<double> weights1 = [5, 4, 2.5, 1, 0];
  List<double> weights2 = [0, 1, 2.5, 4, 5];


  List<int> countSelectedAnswers(List<int> groupIndices) {
    List<int> counts = [0, 0, 0, 0, 0];
    for (int i = 0; i < groupIndices.length; i++) {
      counts[groupIndices[i]]++;
    }
    return counts;
  }

  // double calculateGroupScore(List<int> counts, List<double> weights) {
  //   return counts[0] * weights[0] +
  //       counts[1] * weights[1] +
  //       counts[2] * weights[2] +
  //       counts[3] * weights[3] +
  //       counts[4] * weights[4];
  // }

  final List<String> questions = [
    '여러 각도에서 관찰할 수 있는 전시가 더 끌리는 편이다.',
    '액자로 된 전시회는 지루하다.',
    '눈을 확 사로잡는 입체적인 전시가 더 좋다.',
    '이것저것 체험하고 경험하는 것에 흥미를 느낀다.',
    '멈춰있는 작품보단 살아 숨쉬듯 움직이는 작품이 더 좋다.',
    '영상 매체에 관심이 많은 편이다.',
    '‘구관이 명관이다.’라는 말에 동의한다.',
    '뭉크, 고흐, 모네, 다빈치 등의 고전 작가에게 흥미가 많은 편이다.',
    '옛 사람들의 시대상을 알 수 있는 고전 작품이 좋다.',
    '단지 감상만 하기보다, 배움이 있는 전시회가 좋다.',
    '이것저것 체험하고 만지고 경험해 볼 수 있는 활동을 좋아한다.',
    '무엇이든지 신기하면 손으로 만져봐야 직성이 풀리는 편이다.'
  ];

  void onAnswerSelected(int questionIndex, int answerIndex) {
    if (_tabController == null) {
      // _tabController가 초기화되지 않은 경우 초기화
      _tabController = TabController(length: 9, vsync: this);
      group1Score = 0.0;
      group1OppositeScore = 0.0;
      group2Score = 0.0;
      group2OppositeScore = 0.0;
      group3Score = 0.0;
      group3OppositeScore = 0.0;
      group4Score = 0.0;
      group4OppositeScore = 0.0;
    }

    setState(() {
      selectedAnswerIndices[questionIndex] = answerIndex;
      if (_tabController.index < _tabController.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
      }
    });
  }


  double calculateGroupScore(List<int> groupIndices) {
    double score = 0;
    for (int i = 0; i < groupIndices.length; i++) {
      score += weights1[groupIndices[i]];

    }
    return score;
  }

  double calculateOppositeGroupScore(List<int> groupIndices) {
    double score = 0;
    for (int i = 0; i < groupIndices.length; i++) {
      score += weights2[groupIndices[i]];
    }
    return score;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "전시유형검사",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: List.generate(questions.length, (index) {
                  return Opacity(
                    opacity: selectedAnswerIndices[index] >= 0 ? 0.3 : 1.0,
                    child: QuestionSection(
                      questionIndex: index,
                      question: questions[index],
                      options: ['', '', '', '', ''],
                      selectedAnswerIndex: selectedAnswerIndices[index],
                      onAnswerSelected: onAnswerSelected,
                    ),
                  );
                }),
              ),
              // Save Result Button
              if (calculateProgress() * 100 == 100)
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff464D40), // 배경색
                      onPrimary: Colors.white, // 글자색
                      minimumSize: Size(MediaQuery.of(context).size.width-30, 50), // 최소 크기
                      padding: EdgeInsets.symmetric(horizontal: 16), // 가로 패딩
                    ),
                    onPressed: () async {
                      for (int i = 0; i < 4; i++) {
                        int start = i * 3;
                        int end = start + 3;
                        double rate1 = calculateGroupScore(selectedAnswerIndices.sublist(start, end));
                        double rate2 = calculateOppositeGroupScore(selectedAnswerIndices.sublist(start, end));

                        double score = (rate1 / (rate1 + rate2)) * 100;
                        double oppositeScore = (rate2 / (rate1 + rate2)) * 100;

                        switch (i) {
                          case 0:
                            group1Score = score;
                            group1OppositeScore = oppositeScore;
                            break;
                          case 1:
                            group2Score = score;
                            group2OppositeScore = oppositeScore;
                            break;
                          case 2:
                            group3Score = score;
                            group3OppositeScore = oppositeScore;
                            break;
                          case 3:
                            group4Score = score;
                            group4OppositeScore = oppositeScore;
                            break;
                        }
                      }
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(sessionId)
                          .collection('jbti')
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        if (querySnapshot.size > 0) {
                          querySnapshot.docs.forEach((doc) {
                            doc.reference.delete();
                          });
                        }
                      });

                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(sessionId)
                          .collection('jbti')
                          .add({
                        'dimensionValue': group1Score.round(),
                        'flatValue': group1OppositeScore.round(),
                        'dynamicValue': group2Score.round(),
                        'astaticValue': group2OppositeScore.round(),
                        'classicValue': group3Score.round(),
                        'newValue': group3OppositeScore.round(),
                        'appreciationValue': group4Score.round(),
                        'exploratoryValue': group4OppositeScore.round(),
                      });
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: Text(
                                '알림',
                                style: TextStyle(fontSize: 17),
                              ),
                            ),
                            content: Container(
                              height: 60, // Container의 높이를 조절
                              alignment: Alignment.center,
                              child: Text(
                                '전시 취향 분석이 완료되었습니다.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  // 확인 버튼을 눌렀을 때 초기화면으로 이동
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xff464D40), // 배경색 설정
                                  onPrimary: Colors.white, // 텍스트 색상 설정
                                  elevation: 0, // 그림자 제거
                                  minimumSize: Size(double.infinity, 48), // 가로 길이 꽉 채우기
                                ),
                                child: Text(
                                  '닫기',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('결과 저장하기', style: TextStyle(fontSize: 16),),
                  ),
                ),
              SizedBox(height: 20)
              // Progress Indicator
            ],
          ),
        ),
      ),
        bottomNavigationBar: BottomAppBar(
            height: 60,
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  if (calculateProgress() * 100 == 100) Text('완료!'),
                  if (calculateProgress() * 100 != 100) Text('${(calculateProgress() * 100).toInt()}%', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xff464D40)),),
                  SizedBox(height: 5,),
                  LinearProgressIndicator(
                    value: calculateProgress(),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xff464D40)),
                  ),
                ],
              ),
            ),

),


    );
  }

  double calculateProgress() {
    int answeredCount = selectedAnswerIndices.where((index) => index >= 0).length;
    return answeredCount / 12.0;
  }
}

class QuestionSection extends StatelessWidget {
  final int questionIndex;
  final String question;
  final List<String> options;
  final int selectedAnswerIndex;
  final Function(int, int) onAnswerSelected;

  const QuestionSection({
    required this.questionIndex,
    required this.question,
    required this.options,
    required this.selectedAnswerIndex,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(bottom: 20,right: 20,left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          SizedBox(
            height: 20,
          ),
          Container(
            width: MediaQuery.of(context).size.width - 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    '${questionIndex + 1}   ',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$question',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          Container(
            width: MediaQuery.of(context).size.width - 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '동의',
                  style: TextStyle(color: Colors.black,  fontSize: 13),
                ),
                SizedBox(width: 10),
                ...options.asMap().entries.map((entry) {
                  final int answerIndex = entry.key;
                  final String text = entry.value;
                  return AnswerOption(
                    questionIndex: questionIndex,
                    answerIndex: answerIndex,
                    text: text,
                    isSelected: selectedAnswerIndex == answerIndex,
                    onSelected: onAnswerSelected,
                  );
                }).toList(),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '비동의',
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnswerOption extends StatelessWidget {
  final int questionIndex;
  final int answerIndex;
  final String text;
  final bool isSelected;
  final Function(int, int) onSelected;

  const AnswerOption({
    required this.questionIndex,
    required this.answerIndex,
    required this.text,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<double> sizes = [40.0, 35.0, 30.0, 35.0, 40.0];
    double size = sizes[answerIndex];
    Color borderColor = _getBorderColor(answerIndex);

    return GestureDetector(
      onTap: () {
        onSelected(questionIndex, answerIndex);
      },
      child: Container(
        width: size,
        height: size,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isSelected ? _getAnswerColor(answerIndex) : Colors.transparent,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: Text(
            isSelected
                ? (answerIndex == 0
                ? ''
                : (answerIndex == 1
                ? ''
                : (answerIndex == 2
                ? ''
                : (answerIndex == 3
                ? ''
                : (answerIndex == 4 ? '' : '')))))
                : text,
            style: TextStyle(color: isSelected ? Colors.white : borderColor),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(int index) {
    List<Color> borderColors = [
      Color(0xFF404F32),
      Color(0xFF556944),
      Color(0xFF729851),
      Color(0xFF9FBF83),
      Color(0xFFD4D8C8),
    ];

    return borderColors[index];
  }

  Color _getAnswerColor(int index) {
    List<Color> answerColors = [
      Color(0xFF404F32),
      Color(0xFF556944),
      Color(0xFF729851),
      Color(0xFF9FBF83),
      Color(0xFFD4D8C8),
    ];

    return answerColors[index];
  }
}
