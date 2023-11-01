import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// 이미지 선택
class ImageSelector {
  final picker = ImagePicker();

  Future<XFile?> selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile;
  }
}

// 이미지 업로드
class ImageUploader {
  final String folderName;

  ImageUploader(this.folderName);

  Future<String> uploadImage(XFile imageFile) async {
    Uint8List? imageBytes = await imageFile.readAsBytes();

    FirebaseStorage storage = FirebaseStorage.instance;
    String folder = '$folderName/';
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = storage.ref().child('$folder/$fileName.jpg');
    UploadTask uploadTask = storageReference.putData(imageBytes);

    await uploadTask.whenComplete(() async {
      // String downloadURL = await storageReference.getDownloadURL(); // 로그인 후 url 받아오기 가능
      return '$fileName.jpg';
    });
    return '';
  }
}
