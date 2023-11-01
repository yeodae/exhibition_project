import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/review/review_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReviewEdit extends StatefulWidget {
  final String? documentId;

  // 생성자에 documentId를 추가하고 null을 허용합니다.
  ReviewEdit({Key? key, this.documentId}) : super(key: key);

  @override
  State<ReviewEdit> createState() => _ReviewEditState();
}

class _ReviewEditState extends State<ReviewEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // documentId가 있는 경우 데이터를 불러옵니다.
    if (widget.documentId != null) {
      _loadReviewData(widget.documentId!);
      print(_titleCtr);
      print(_contentCtr);
    }
  }

  Future<void> _loadReviewData(String documentId) async {
    try {
      final documentSnapshot =
      await FirebaseFirestore.instance.collection('review').doc(documentId).get();
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final title = data['title'] as String;
        final content = data['content'] as String;
        final imagePath = data['imagePath'] as String?;

        File? imageFile = imagePath != null ? File(imagePath) : null;

        setState(() {
          _titleCtr.text = title;
          _contentCtr.text = content;
          _imageFile = imageFile;
        });
      } else {
        print('리뷰를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _saveReview() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference review = FirebaseFirestore.instance.collection("review");

      String imagePath = '';

      if (_imageFile != null) {
        imagePath = await _saveImage(_imageFile!);
      }

      if (widget.documentId != null) {
        // documentId가 있는 경우 수정합니다.
        await review.doc(widget.documentId!).update({
          'title': _titleCtr.text,
          'content': _contentCtr.text,
          'write_date': DateTime.now(),
          'imagePath': imagePath,
        });
      } else {
        // documentId가 없는 경우 추가합니다.
        await review.add({
          'title': _titleCtr.text,
          'content': _contentCtr.text,
          'write_date': DateTime.now(),
          'imagePath': imagePath,
        });
      }

      _titleCtr.clear();
      _contentCtr.clear();
      setState(() {
        _imageFile = null;
      });
    } else {
      print("제목과 내용을 입력해주세요");
    }
  }

  Future<String> _saveImage(File imageFile) async {
    Directory dir = await getApplicationDocumentsDirectory();
    Directory buskingDir = Directory('${dir.path}/busking');

    if (!await buskingDir.exists()) {
      await buskingDir.create(recursive: true);
    }

    final name = DateTime.now().millisecondsSinceEpoch.toString();
    File targetFile = File('${buskingDir.path}/$name.png');
    await imageFile.copy(targetFile.path);

    return targetFile.path;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Widget buildCommForm() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleInput(),
            _buildDivider(),
            SizedBox(height: 10),
            _buildImgButton(),
            _buildContentInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleInput() {
    return Container(
      child: TextField(
        controller: _titleCtr,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, right: 10, left: 20, bottom: 10),
          hintText: '제목을 입력해주세요.',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
        margin: EdgeInsets.only(right: 20, left: 20),
    height: 2.0,
    width: MediaQuery.of(context).size.width,
    color: Colors.black12,
    );
  }

  Widget _buildImgButton() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      child: IconButton(
        onPressed: _pickImage,
        icon: Icon(Icons.image_rounded, color: Colors.black26),
      ),
    );
  }

  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 10),
      child: TextField(
        maxLines: 20,
        maxLength: 1000,
        controller: _contentCtr,
        decoration: InputDecoration(
          hintText: '본문에 #을 이용해 태그를 입력해보세요! (최대 30개)',
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: 15,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    if (_imageFile != null) {
      return Container(
        child: Image.file(_imageFile!, width: 100, height: 100, fit: BoxFit.cover,),
        alignment: Alignment.topLeft,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.documentId != null ? '글 수정' : '글 작성',
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _saveReview();
              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewList()));
            },
            child: Text(
              widget.documentId != null ? '수정' : '등록',
              style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildCommForm(),
              ),
              _buildSelectedImage(),
            ],
          ),
        ),
      ),
    );
  }
}