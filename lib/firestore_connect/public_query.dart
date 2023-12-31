import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exhibition_project/dialog/show_message.dart';
import 'package:flutter/material.dart';

// Map 형식으로 반환
Map<String, dynamic> getMapData(DocumentSnapshot document) {
  return document.data() as Map<String, dynamic>;
}

Stream<QuerySnapshot> getStreamData(String collectionName, String condition, bool orderBool) {
  return FirebaseFirestore.instance
      .collection(collectionName)
      .orderBy(condition, descending: orderBool)
      .snapshots();
}

Stream<QuerySnapshot> getChildStreamData(String documentId, String parentCollection, String childCollection, String condition, bool orderBool) {
  return FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .orderBy(condition, descending: orderBool)
      .snapshots();
}

// 하위 컬렉션의 전체 리스트 출력
Stream<List<QuerySnapshot>> getSubCollectionStreamData(String parentCollection, String childCollection, String condition, bool orderBool) async* {
  QuerySnapshot parentDocs = await FirebaseFirestore.instance.collection(parentCollection).get();
  List<QuerySnapshot> subCollectionSnapshots = [];
  for (var doc in parentDocs.docs) {
    QuerySnapshot subCollectionSnapshot = await FirebaseFirestore.instance
        .collection(parentCollection)
        .doc(doc.id)
        .collection(childCollection)
        .orderBy(condition, descending: orderBool)
        .get();
    subCollectionSnapshots.add(subCollectionSnapshot);
  }
  // 정렬 (로딩 및 정렬 시간이 너무 많이 걸려 생략)
  /*
  subCollectionSnapshots.sort((a, b) {
    var aTitle = a.docs.first.get(condition).toString();
    var bTitle = b.docs.first.get(condition).toString();
    return orderBool ? bTitle.compareTo(aTitle) : aTitle.compareTo(bTitle);
  });
  */
  yield subCollectionSnapshots;
}

// 상위 컬렉션에 대한 하위 컬렉션 값 출력
Future<List<Map<String, dynamic>>> listMapData(DocumentSnapshot document, String parentCollection, String childCollection, String condition, bool orderBool) async {
  QuerySnapshot? snapshot = await getChildStreamData(document.id, parentCollection, childCollection, condition, orderBool).first;

  if (snapshot != null && snapshot.docs.isNotEmpty) {
    List<Map<String, dynamic>> dataList = [];

    for (DocumentSnapshot doc in snapshot.docs) {
      if (doc.id != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String documentId = doc.id;
        data['documentId'] = documentId;
        dataList.add(data);
      }
    }
    return dataList;
  } else {
    return []; // 데이터가 없을 때 빈 리스트 반환
  }
}

// 조건에 맞는 값을 추출
Future<QuerySnapshot> getEqualData(String collectionName, String conditionName, String conditionData) async {
  return FirebaseFirestore.instance
      .collection(collectionName)
      .where(conditionName, isEqualTo: conditionData)
      .get();
}

// 선택된 리스트들을 Firestore에서 삭제하는 메서드
void removeCheckList(BuildContext context, Map<String, bool> checkedList, String collectionStr) async {
  FirebaseFirestore fs = FirebaseFirestore.instance;
  CollectionReference collectionName = fs.collection(collectionStr);

  if (checkedList.containsValue(true)) { // 선택된 항목이 하나라도 있을 때
    bool? confirmation = await chooseMessageDialog(context, '정말 삭제하시겠습니까?', '삭제');

    if (confirmation == true) { // '삭제'를 선택한 경우
      // checkedList의 'document.id'를 가져와 삭제
      checkedList.entries.where((entry) => entry.value).forEach((entry) async {
        String documentId = entry.key; // document ID를 키 값으로 사용
        DocumentSnapshot snapshot = await collectionName.doc(documentId).get();

        if (snapshot.exists) {
          // 하위 컬렉션 삭제
          if(collectionStr == 'artist'){
            final List<String> subCollections = ['artist_history', 'artist_education', 'artist_awards', 'artist_artwork']; // 하위 컬렉션들의 이름
            await deleteAllSubCollection(collectionStr, documentId, subCollections);
          } else if(collectionStr == 'exhibition'){
            final List<String> subCollections = ['exhibition_fee'];
            await deleteAllSubCollection(collectionStr, documentId, subCollections);
          }
          await snapshot.reference.delete();
        }
      });
      // 삭제 작업을 수행한 후, 확인을 표시할 수 있습니다.
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('선택한 항목이 삭제되었습니다.'))
      );
    }
  } else {
    showMessageDialog(context, '삭제할 항목을 선택해 주세요.');
  }
}

// 하위 컬렉션명을 받아 모두 삭제
Future<void> deleteAllSubCollection(String parentCollection, String documentId, List<String> childCollections) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (String childCollection in childCollections) {
    await firestore.collection(parentCollection).doc(documentId).collection(childCollection).get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}

// 상위 컬렉션의 id를 이용하여 하위 컬렉션의 모든 필드를 삭제
Future<void> deleteSubCollection(String parentCollection, String documentId, String childCollection) async {
  // 상위 컬렉션의 문서 id를 이용하여 레퍼런스 가져오기
  final DocumentReference documentReference = FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId);

  // 해당 서브컬렉션의 모든 문서 가져오기
  final QuerySnapshot querySnapshot = await documentReference.collection(childCollection).get();

  // 모든 문서 삭제
  final List<Future<void>> futures = [];
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    futures.add(doc.reference.delete());
  }

  // 모든 문서 삭제 후 컬렉션 자체를 삭제
  await Future.wait(futures);
}

// 하위 컬렉션의 첫 번째 문서 id 값을 반환
Future<String?> getFirstDocumentID(DocumentSnapshot<Object?>? document, String childCollection) async {
  if (document != null) {
    QuerySnapshot snapshot = await document.reference.collection(childCollection).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs[0].id; // 첫 번째 문서의 ID 반환
    }
  }
  return null; // 문서가 없을 경우 null 반환
}

// 하위 컬렉션의 첫 번째 필드 값 반환
Future<String?> getFirstFieldValue(DocumentSnapshot<Object?>? document, String childCollection, String fieldName) async {
  if (document != null) {
    QuerySnapshot snapshot = await document.reference.collection(childCollection).get();
    if (snapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot<Object?> firstDocument = snapshot.docs[0]; // 첫 번째 값 반환
      Map<String, dynamic> data = firstDocument.data() as Map<String, dynamic>;
      if (data.containsKey(fieldName)) {
        return data[fieldName];
      }
    }
  }
  return null; // 문서가 없거나 필드가 존재하지 않을 경우 null 반환
}

// 상위 컬렉션의 id를 이용하여 하위 컬렉션 가져오기
Future<QuerySnapshot> settingQuery(String parentCollection, String? documentId, String childCollection) async {
  return await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(documentId)
      .collection(childCollection)
      .get();
}

// 컬렉션의 갯수를 리턴
Future<int> getTotalCount(String collectionStr) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collectionStr).get();
  int totalDataCount = snapshot.docs.length;
  return totalDataCount;
}

// 이미지 필드 추가 및 수정
Future<void> updateImageURL(String parentCollection, String parentDocumentId, String imageURL, String folderName, String fieldName) async {
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(parentDocumentId)
      .update({
        fieldName : imageURL,
        'folderName' : folderName,
      });
}

Future<void> updateChildImageURL(String parentCollection, String parentDocumentId, String childCollection, String childDocumentId, String imageURL, String folderName) async {
  await FirebaseFirestore.instance
      .collection(parentCollection)
      .doc(parentDocumentId)
      .collection(childCollection)
      .doc(childDocumentId)
      .update({
        'imageURL' : imageURL,
        'folderName' : folderName,
     });
}