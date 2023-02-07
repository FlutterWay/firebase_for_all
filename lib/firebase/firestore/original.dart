import 'package:cloud_firestore/cloud_firestore.dart';
import 'bridge.dart';
import 'models.dart';

FirebaseFirestore instanceFirestoreOriginal() {
  return FirebaseFirestore.instance;
}

Future<QuerySnapshotForAll<T>> getCollectionsOriginal<T extends Object?>(
    CollectionReference ref,
    {required QueryProperties queryProperties,
    required ColRef<T> colRef}) async {
  dynamic init = ref;
  for (var query in queryProperties.whereQuerys) {
    init = init.where(
      query.document,
      isEqualTo: query.isEqualTo,
      isNotEqualTo: query.isNotEqualTo,
      isLessThan: query.isLessThan,
      isLessThanOrEqualTo: query.isLessThanOrEqualTo,
      isGreaterThan: query.isGreaterThan,
      isGreaterThanOrEqualTo: query.isGreaterThanOrEqualTo,
      arrayContains: query.arrayContains,
      arrayContainsAny: query.arrayContainsAny,
      whereIn: query.whereIn,
      whereNotIn: query.whereNotIn,
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
  if (queryProperties.limitToLast != null) {
    init = init.limitToLast(queryProperties.limitToLast);
  }
  if (queryProperties.startAt.isNotEmpty) {
    init = init.startAt(queryProperties.startAt);
  }
  if (queryProperties.endAt.isNotEmpty) {
    init = init.endAt(queryProperties.endAt);
  }
  if (queryProperties.startAfter.isNotEmpty) {
    init = init.startAfter(queryProperties.startAfter);
  }
  if (queryProperties.endBefore.isNotEmpty) {
    init = init.endBefore(queryProperties.endBefore);
  }
  if (queryProperties.startAfterDocument != null) {
    init = init.startAfterDocument(queryProperties.startAfterDocument);
  }
  if (queryProperties.startAtDocument != null) {
    init = init.startAtDocument(queryProperties.startAtDocument);
  }
  if (queryProperties.endAtDocument != null) {
    init = init.endAtDocument(queryProperties.endAtDocument);
  }
  if (queryProperties.endBeforeDocument != null) {
    init = init.endBeforeDocument(queryProperties.endBeforeDocument);
  }
  late QuerySnapshotForAll<T> snapshots;
  await init.get().then((value) {
    if (value.docs.isNotEmpty) {
      snapshots = QuerySnapshotForAll<T>(
          List<DocumentSnapshotForAll<T>>.from(value.docs
              .map((e) => DocumentSnapshotForAll<T>(
                  e.data() as Map<String, dynamic>,
                  e.id,
                  "${ref.path}\\${e.id}",
                  colRef.doc(e.id)))
              .toList()),
          docChanges: value.docChanges);
    } else {
      snapshots = QuerySnapshotForAll<T>([], docChanges: []);
    }
  });
  return snapshots;
}

Future<DocumentSnapshotForAll<T>> getDocumentOriginal<T extends Object?>(
    DocumentReference<Map<String, dynamic>> ref,
    {required DocRef<T> docRef}) async {
  late DocumentSnapshotForAll<T> doc;
  await ref.get().then((value) {
    doc = DocumentSnapshotForAll<T>(value.data(), value.id, ref.path, docRef);
  });
  return doc;
}
