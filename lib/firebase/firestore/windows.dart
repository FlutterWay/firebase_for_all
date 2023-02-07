import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../firebase_for_all.dart';

Future<void> initFirestoreWindows() async {
  if (Get.find<FirebaseControlPanel>().options != null) {
    Firestore.initialize(Get.find<FirebaseControlPanel>().options!.projectId);
  } else {
    if (kDebugMode) {
      print("FirebaseOptions cant be null!!");
    }
  }
}

Firestore instanceFirestoreWindows() {
  return Firestore.instance;
}

Future<QuerySnapshotForAll<T>> getCollectionsWindows<T extends Object?>(
    CollectionReference ref,
    {required QueryProperties queryProperties,
    required ColRef<T> colRef}) async {
  dynamic init = ref;
  for (var query in queryProperties.whereQuerys) {
    init = init.where(
      query.document,
      isEqualTo: query.isEqualTo,
      isLessThan: query.isLessThan,
      isLessThanOrEqualTo: query.isLessThanOrEqualTo,
      isGreaterThan: query.isGreaterThan,
      isGreaterThanOrEqualTo: query.isGreaterThanOrEqualTo,
      arrayContains: query.arrayContains,
      arrayContainsAny: query.arrayContainsAny,
      whereIn: query.whereIn,
      isNull: query.isNull,
    );
  }
  for (var query in queryProperties.orderByQuerys) {
    init = init.orderBy(
      query.fieldPath,
      descending: query.descending,
    );
  }
  if (queryProperties.limit != null) {
    init = init.limit(queryProperties.limit);
  }
  late QuerySnapshotForAll<T> snapshots;
  await init.get().then((value) {
    if (value.isNotEmpty) {
      snapshots = QuerySnapshotForAll<T>(
          List<DocumentSnapshotForAll<T>>.from(value
              .map((element) => DocumentSnapshotForAll<T>(
                  element.map,
                  element.id,
                  init.path + "\\" + element.id,
                  colRef.doc(element.id)))
              .toList()),
          docChanges: []);
    } else {
      snapshots = QuerySnapshotForAll<T>([], docChanges: []);
    }
  });
  return snapshots;
}

Future<DocumentSnapshotForAll<T>> getDocumentWindows<T extends Object?>(
    DocumentReference ref,
    {required DocRef<T> docRef}) async {
  late DocumentSnapshotForAll<T> doc;
  await ref.get().then((value) {
    doc = DocumentSnapshotForAll<T>(value.map, value.id, value.id, docRef);
  });
  return doc;
}
