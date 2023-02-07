import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_for_all/firebase_for_all.dart';
import 'package:firedart/firedart.dart' as firedart;
import 'original.dart';
import 'windows.dart';

Future<QuerySnapshotForAll<T>> getCollections<T extends Object?>(ColRef<T> ref,
    {required QueryProperties queryProperties}) async {
  if (isWindows()) {
    return (await getCollectionsWindows<T>(ref.reference,
        queryProperties: queryProperties, colRef: ref));
  } else {
    return (await getCollectionsOriginal<T>(ref.reference!,
        queryProperties: queryProperties, colRef: ref));
  }
}

Future<DocumentSnapshotForAll<T>> getDoc<T extends Object?>(
    DocRef<T> ref) async {
  if (isWindows()) {
    return (await getDocumentWindows<T>(ref.reference, docRef: ref));
  } else {
    return (await getDocumentOriginal<T>(ref.reference, docRef: ref));
  }
}

class FirestoreItem {
  ColRef<Map<String, Object?>> collection(String collection) {
    return ColRef<Map<String, Object?>>.withReference(isValid()
        ? instanceFirestoreOriginal().collection(collection)
        : instanceFirestoreWindows().collection(collection));
  }
}

class FirestoreConverter<T extends Object?> {
  T Function(DocumentSnapshotForAll<T>, dynamic) fromFirestore;
  Map<String, Object?> Function(T, dynamic) toFirestore;

  FirestoreConverter({required this.toFirestore, required this.fromFirestore});
}

class ColRef<T extends Object?> {
  // ignore: non_constant_identifier_names
  firedart.CollectionReference? _ref_windows;
  // ignore: non_constant_identifier_names
  CollectionReference<Map<String, dynamic>>? _ref_original;
  QueryProperties _queryProperties = QueryProperties();
  get reference => _ref_windows ?? _ref_original;
  FirestoreConverter<T>? _converter;
  FirestoreConverter<T>? get converter => _converter;
  ColRef.withReference(dynamic reference, {FirestoreConverter<T>? converter}) {
    if (reference is CollectionReference<Map<String, dynamic>>) {
      _ref_original = reference;
    } else {
      _ref_windows = reference;
    }
    _converter = converter;
  }
  ColRef._withQuery(
    dynamic reference, {
    required QueryProperties queryProperties,
    required FirestoreConverter<T>? converter,
  }) {
    if (reference is CollectionReference<Map<String, dynamic>>) {
      _ref_original = reference;
    } else {
      _ref_windows = reference;
    }
    _queryProperties = queryProperties;
    _converter = converter;
  }

  ColRef<R> withConverter<R extends Object?>(
      {required R Function(DocumentSnapshotForAll<R>, dynamic) fromFirestore,
      required Map<String, Object?> Function(R, dynamic) toFirestore}) {
    FirestoreConverter<R> converter = FirestoreConverter<R>(
        toFirestore: toFirestore, fromFirestore: fromFirestore);
    return ColRef<R>._withQuery(reference,
        queryProperties: _queryProperties, converter: converter);
  }

  ColRef<T> limit(int limit) {
    _queryProperties.limit = limit;
    return _copyWithQuery;
  }

  ColRef<T> limitToLast(int limitToLast) {
    _queryProperties.limitToLast = limitToLast;
    return _copyWithQuery;
  }

  ColRef<T> startAt(List<Object?> values) {
    _queryProperties.startAt = values;
    return _copyWithQuery;
  }

  ColRef<T> endAt(List<Object?> values) {
    _queryProperties.endAt = values;
    return _copyWithQuery;
  }

  ColRef<T> startAfter(List<Object?> values) {
    _queryProperties.startAfter = values;
    return _copyWithQuery;
  }

  ColRef<T> endBefore(List<Object?> values) {
    _queryProperties.endBefore = values;
    return _copyWithQuery;
  }

  ColRef<T> startAfterDocument(DocumentSnapshotForAll<T> documentSnapshot) {
    _queryProperties.startAfterDocument = documentSnapshot;
    return _copyWithQuery;
  }

  ColRef<T> startAtDocument(DocumentSnapshotForAll<T> documentSnapshot) {
    _queryProperties.startAtDocument = documentSnapshot;
    return _copyWithQuery;
  }

  ColRef<T> endAtDocument(DocumentSnapshotForAll<T> documentSnapshot) {
    _queryProperties.endAtDocument = documentSnapshot;
    return _copyWithQuery;
  }

  ColRef<T> endBeforeDocument(DocumentSnapshotForAll<T> documentSnapshot) {
    _queryProperties.endBeforeDocument = documentSnapshot;
    return _copyWithQuery;
  }

  ColRef<T> where(
    String fieldPath, {
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool isNull = false,
  }) {
    _queryProperties.whereQuerys.add(WhereQuery(
        document: fieldPath,
        isEqualTo: isEqualTo,
        isNotEqualTo: isNotEqualTo,
        isLessThan: isLessThan,
        isLessThanOrEqualTo: isLessThanOrEqualTo,
        isGreaterThan: isGreaterThan,
        isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
        arrayContains: arrayContains,
        arrayContainsAny: arrayContainsAny,
        whereIn: whereIn,
        whereNotIn: whereNotIn,
        isNull: isNull));
    return _copyWithQuery;
  }

  ColRef<T> orderBy(String fieldPath, {bool descending = false}) {
    _queryProperties.orderByQuerys
        .add(OrderByQuery(fieldPath, descending: descending));
    return _copyWithQuery;
  }

  ColRef<T> get _copyWithQuery {
    return ColRef._withQuery(_ref_windows ?? _ref_original,
        queryProperties: _queryProperties, converter: _converter);
  }

  CollectionSnapshots<T> snapshots() {
    if (_ref_windows != null) {
      return CollectionSnapshots<T>(this);
    } else {
      return CollectionSnapshots<T>(this);
    }
  }

  DocRef<T> doc(String id) {
    return DocRef<T>.withReference(
        _ref_windows != null
            ? _ref_windows!.document(id)
            : _ref_original!.doc(id),
        converter: _converter);
  }

  Future<QuerySnapshotForAll<T>> get() async {
    return (await getCollections<T>(this, queryProperties: _queryProperties));
  }

  Future<DocRef<T>> add(T value) async {
    if (_ref_windows != null) {
      var document = await _ref_windows!.add(value is Map<String, dynamic>
          ? value
          : _converter!.toFirestore(value, null));
      return doc(document.id);
    } else {
      var document = await _ref_original!.add(value is Map<String, dynamic>
          ? value
          : _converter!.toFirestore(value, null));
      return doc(document.id);
    }
  }

  String get path {
    return _ref_windows != null ? _ref_windows!.path : _ref_original!.path;
  }
}

class DocRef<T extends Object?> {
  // ignore: non_constant_identifier_names
  firedart.DocumentReference? _ref_windows;
  // ignore: non_constant_identifier_names
  DocumentReference<Map<String, dynamic>>? _ref_original;

  FirestoreConverter<T>? _converter;
  FirestoreConverter<T>? get converter => _converter;
  get reference => _ref_windows ?? _ref_original;

  DocRef.withReference(dynamic reference, {FirestoreConverter<T>? converter}) {
    if (reference is firedart.DocumentReference) {
      _ref_windows = reference;
    } else {
      _ref_original = reference;
    }
    _converter = converter;
  }

  DocRef<R> withConverter<R extends Object?>(
      {required R Function(DocumentSnapshotForAll, dynamic) fromFirestore,
      required Map<String, Object?> Function(R, dynamic) toFirestore}) {
    FirestoreConverter<R> converter = FirestoreConverter<R>(
        toFirestore: toFirestore, fromFirestore: fromFirestore);
    return DocRef<R>.withReference(reference, converter: converter);
  }

  Future<DocumentSnapshotForAll<T>> get() async {
    return (await getDoc<T>(this));
  }

  DocumentSnapshots<T> snapshots() {
    if (_ref_windows != null) {
      return DocumentSnapshots<T>(this);
    } else {
      return DocumentSnapshots<T>(this);
    }
  }

  String get path {
    return _ref_windows != null ? _ref_windows!.path : _ref_original!.path;
  }

  ColRef<T> collection(String collection) {
    return _ref_windows != null
        ? ColRef<T>.withReference(_ref_windows!.collection(collection),
            converter: _converter)
        : ColRef<T>.withReference(_ref_original!.collection(collection),
            converter: _converter);
  }

  Future<void> set(T value) async {
    if (_ref_windows != null) {
      await _ref_windows!.set(value is Map<String, dynamic>
          ? value
          : _converter!.toFirestore(value, null));
    } else {
      await _ref_original!.set(value is Map<String, dynamic>
          ? value
          : _converter!.toFirestore(value, null));
    }
  }

  Future<void> update(Map<String, dynamic> map) async {
    if (_ref_windows != null) {
      await _ref_windows!.update(map);
    } else {
      await _ref_original!.update(map);
    }
  }

  Future<void> delete() async {
    if (_ref_windows != null) {
      await _ref_windows!.delete();
    } else {
      await _ref_original!.delete();
    }
  }
}
