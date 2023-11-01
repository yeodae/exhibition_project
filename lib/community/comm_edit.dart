import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'comm_main.dart';


class CommEdit extends StatefulWidget {
  final String? documentId;

  // 생성자에 documentId를 추가하고 null을 허용
  CommEdit({Key? key, this.documentId}) : super(key: key);

  @override
  State<CommEdit> createState() => _CommEditState();
}

class _CommEditState extends State<CommEdit> {
  final _titleCtr = TextEditingController();
  final _contentCtr = TextEditingController();
  String? _imageURL; // 선택한 이미지의 URL을 저장

  @override
  void initState() {
    super.initState();
    // documentId가 있는 경우 데이터를 불러옴
    if (widget.documentId != null) {
      _loadPostData(widget.documentId!);
    }
  }

  Future<void> _loadPostData(String documentId) async {
    try {
      final documentSnapshot =
      await FirebaseFirestore.instance.collection('post').doc(documentId).get();
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final title = data['title'] as String;
        final content = data['content'] as String;


        setState(() {
          _titleCtr.text = title;
          _contentCtr.text = content;
        });
      } else {
        print('게시글을 찾을 수 없습니다.');
      }
    } catch (e) {
      print('데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _savePost() async {
    if (_titleCtr.text.isNotEmpty && _contentCtr.text.isNotEmpty) {
      CollectionReference post = FirebaseFirestore.instance.collection("post");


      if (widget.documentId != null) {
        // documentId가 있는 경우 수정
        await post.doc(widget.documentId!).update({
          'title': _titleCtr.text,
          'content': _contentCtr.text,
          'write_date': DateTime.now(),
          'imageURL' : _imageURL
        });
      } else {
        // documentId가 없는 경우 추가
        await post.add({
          'title': _titleCtr.text,
          'content': _contentCtr.text,
          'write_date': DateTime.now(),
          'imageURL' : _imageURL
        });
      }

      _titleCtr.clear();
      _contentCtr.clear();

    } else {
      print("제목과 내용을 입력해주세요");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 이미지 업로드
      final imageURL = await _uploadImage(File(pickedFile.path));
      if (imageURL != null) {
        // 이미지 업로드가 성공한 경우 URL을 상태에 저장
        setState(() {
          _imageURL = imageURL;
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // 이미지 파일의 이름 생성 (예: 현재 시간을 기반으로)
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('post_images/$fileName.jpg');

      // 이미지를 Firebase Storage에 업로드
      await storageRef.putFile(imageFile);

      // 업로드한 이미지의 다운로드 URL 획득
      final downloadURL = await storageRef.getDownloadURL();
      print(downloadURL);
      return downloadURL;

    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return null;
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
        maxLines: 10,
        maxLength: 300,
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

  // Widget _buildSelectedImage() {
  //   if (_imageURL != null) {
  //     return Container(
  //       padding: EdgeInsets.only(left: 10),
  //       child: IconButton(
  //         onPressed: _pickImage,
  //         icon: Icon(Icons.image_rounded, color: Colors.black26),
  //       ),
  //     );
  // }

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
              _savePost();
              Navigator.push(context, MaterialPageRoute(builder: (context) => CommMain()));
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
               // _buildSelectedImage(),
            ],
          ),
        ),
      ),
    );
  }
}
