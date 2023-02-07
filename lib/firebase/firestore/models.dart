import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_for_all/firebase_for_all.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CollectionSnapshots<T extends Object?> {
  late ColRef<T> _reference;
  CollectionSnapshots(ColRef<T> reference) {
    _reference = reference;
  }
  StreamSubscription<dynamic>? _stream;
  listen(
    void Function(QuerySnapshotForAll<T> snapshot)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) async {
    if (isValid()) {
      _stream = _reference.reference.snapshots().listen(
        (event) {
          if (onData != null) {
            List<DocumentSnapshotForAll<T>> docs = [];
            if (event.size > 0) {
              docs = List<DocumentSnapshotForAll<T>>.from(event.docs
                  .map((e) => DocumentSnapshotForAll<T>(
                      e.data() != null
                          ? e.data() as Map<String, dynamic>
                          : null,
                      e.id,
                      "${_reference.path}\\${e.id}",
                      _reference.doc(e.id)))
                  .toList());
            }
            onData(QuerySnapshotForAll<T>(docs, docChanges: event.docChanges));
          }
        },
        onError: (e, stacktrace) {
          if (kDebugMode) {
            print("type:${e.runtimeType}");
          }
        },
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    } else {
      _stream = _reference.reference.stream.listen(
        (event) {
          if (onData != null) {
            List<DocumentSnapshotForAll<T>> docs = [];
            if (event.isNotEmpty) {
              docs = List<DocumentSnapshotForAll<T>>.from(event.map((e) =>
                  DocumentSnapshotForAll<T>(e.map, e.id,
                      "${_reference.path}\\${e.id}", _reference.doc(e.id))));
            }
            onData(QuerySnapshotForAll<T>(docs, docChanges: []));
          }
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    }
  }

  Future<void> cancel() async {
    if (_stream != null) {
      await _stream!.cancel();
    }
  }

  void pause() async {
    if (_stream != null) {
      _stream!.pause();
    }
  }

  void resume() async {
    if (_stream != null) {
      _stream!.resume();
    }
  }

  bool get isPaused => _stream!.isPaused;
}

class DocumentSnapshots<T extends Object?> {
  late DocRef<T> _reference;
  DocumentSnapshots(DocRef<T> reference) {
    _reference = reference;
  }
  StreamSubscription<dynamic>? _stream;
  listen(
    void Function(DocumentSnapshotForAll<T>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (isValid()) {
      _stream = _reference.reference.snapshots().listen(
        (event) {
          if (onData != null) {
            onData(DocumentSnapshotForAll<T>(
                event.data() != null
                    ? event.data() as Map<String, dynamic>
                    : null,
                event.id,
                _reference.path,
                _reference));
          }
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    } else {
      _stream = _reference.reference.stream.listen(
        (event) {
          if (onData != null && event != null) {
            onData(DocumentSnapshotForAll<T>(
                event.map, event.id, _reference.path, _reference));
          }
        },
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
    }
  }

  Future<void> cancel() async {
    if (_stream != null) {
      await _stream!.cancel();
    }
  }

  void pause() async {
    if (_stream != null) {
      _stream!.pause();
    }
  }

  void resume() async {
    if (_stream != null) {
      _stream!.resume();
    }
  }

  bool get isPaused => _stream!.isPaused;
}

class QuerySnapshotForAll<T extends Object?> {
  QuerySnapshotForAll(this._docs, {required List<DocumentChange> docChanges}) {
    _docChanges = docChanges;
  }

  final List<DocumentSnapshotForAll<T>> _docs;

  List<DocumentChange> _docChanges = [];

  List<DocumentSnapshotForAll<T>> get docs => _docs;

  List<DocumentChange> get docChanges => _docChanges;

  int get size => _docs.length;

  bool get exists => _docs.isNotEmpty;
}

class DocumentSnapshotForAll<T extends Object?> {
  String id;
  DocumentSnapshotForAll(this._data, this.id, this.path, this.ref);
  final Map<String, dynamic>? _data;
  String path;
  DocRef<T> ref;

  dynamic operator [](String key) {
    if (_data == null || !_data!.containsKey(key)) return null;
    return _data![key];
  }

  bool get exists => _data != null;
  Map<String, dynamic>? get map => _data;
  T? data() {
    if (ref.converter != null) {
      return ref.converter!.fromFirestore(this, null);
    } else {
      return _data as T;
    }
  }
}

class SnapshotState<T> {
  final ConnectionState connectionState;

  const SnapshotState._(
      this.connectionState, this.data, this.error, this.stackTrace)
      : assert(!(data != null && error != null)),
        assert(stackTrace == null || error != null);

  const SnapshotState.nothing()
      : this._(ConnectionState.none, null, null, null);

  const SnapshotState.waiting()
      : this._(ConnectionState.waiting, null, null, null);

  const SnapshotState.done() : this._(ConnectionState.done, null, null, null);

  const SnapshotState.withData(ConnectionState state, T data)
      : this._(state, data, null, null);

  const SnapshotState.withError(
    ConnectionState state,
    Object error, [
    StackTrace stackTrace = StackTrace.empty,
  ]) : this._(state, null, error, stackTrace);

  final T? data;

  T get requireData {
    if (hasData) return data!;
    if (hasError) Error.throwWithStackTrace(error!, stackTrace!);
    throw StateError('Snapshot has neither data nor error');
  }

  bool get hasData => data != null;
  bool get isWaiting => connectionState == ConnectionState.waiting;
  bool get hasError => error != null;
  final Object? error;
  final StackTrace? stackTrace;
}

class WhereQuery {
  String document;
  dynamic isEqualTo,
      isLessThan,
      isLessThanOrEqualTo,
      isGreaterThan,
      isGreaterThanOrEqualTo,
      arrayContains,
      isNotEqualTo;
  List<dynamic>? arrayContainsAny;
  List<dynamic>? whereIn;
  List<dynamic>? whereNotIn;
  bool? isNull;
  WhereQuery({
    required this.document,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });
}

class OrderByQuery {
  String fieldPath;
  bool descending;

  OrderByQuery(this.fieldPath, {this.descending = false});
}

class QueryProperties {
  List<WhereQuery> whereQuerys = [];
  List<OrderByQuery> orderByQuerys = [];
  int? limit, limitToLast;
  List<Object?> startAt = [];
  List<Object?> endAt = [];
  List<Object?> startAfter = [];
  List<Object?> endBefore = [];
  DocumentSnapshotForAll? startAfterDocument;
  DocumentSnapshotForAll? startAtDocument;
  DocumentSnapshotForAll? endAtDocument;
  DocumentSnapshotForAll? endBeforeDocument;
}
