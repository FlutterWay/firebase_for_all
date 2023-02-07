import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_dart/firebase_dart.dart' as firebase_dart;

import '../../functions.dart';
import 'bridge.dart';
import 'original.dart';
import 'windows.dart';

class UploadTaskForAll {
  final _streamController = StreamController<ProcessTask>();
  StreamSubscription<dynamic>? _uploadingStream;
  ProcessTask? _finalTask;
  File? targetFile;

  UploadTaskForAll();
  Future<void> cancel() async {
    if (_uploadingStream != null) {
      await _uploadingStream!.cancel();
      if (_finalTask != null) {
        _finalTask!.state = TaskState.canceled;
        _streamController.add(_finalTask!);
      } else {
        _streamController.add(
            ProcessTask(processed: 0, total: 0, state: TaskState.canceled));
      }
    }
  }

  void pause() {
    if (_uploadingStream != null) {
      _uploadingStream!.pause();
      if (_finalTask != null) {
        _finalTask!.state = TaskState.paused;
        _streamController.add(_finalTask!);
      } else {
        _streamController
            .add(ProcessTask(processed: 0, total: 0, state: TaskState.paused));
      }
    }
  }

  void resume() {
    if (_uploadingStream != null) {
      _uploadingStream!.resume();
      if (_finalTask != null) {
        _finalTask!.state = TaskState.running;
        _streamController.add(_finalTask!);
      } else {
        _streamController
            .add(ProcessTask(processed: 0, total: 0, state: TaskState.running));
      }
    }
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _streamController.addError(error, stackTrace);
    if (_finalTask != null) {
      _finalTask!.state = TaskState.error;
      _streamController.add(_finalTask!);
    } else {
      _streamController
          .add(ProcessTask(processed: 0, total: 0, state: TaskState.error));
    }
  }

  void updateTask(ProcessTask task) {
    _streamController.add(task);
    _finalTask = task;
  }

  set setDownloadingStream(StreamSubscription<dynamic> stream) {
    _uploadingStream = stream;
  }

  Stream<ProcessTask> get snapshotEvents => _streamController.stream;
}

class StorageDirectory {
  String cloudPath;
  String dirName;
  StorageRef reference;
  List<String> relatedDirs = [];
  StorageDirectory(
      {required this.cloudPath,
      required this.dirName,
      required this.reference}) {
    List<String> names = cloudPath.split("/");
    if (names.length > 6) {
      relatedDirs = [];
      for (int i = 6; i < names.length - 1; i++) {
        relatedDirs.add(names[i]);
      }
    }
  }
}

class StorageFile {
  String cloudPath;
  String fileName;
  StorageRef reference;
  late String type, extension;
  List<String> relatedDirs = [];
  int size;
  StorageFile(
      {required this.cloudPath,
      required this.fileName,
      required this.size,
      required this.reference}) {
    List<String> names = cloudPath.split("/");
    if (names.length > 6) {
      relatedDirs = [];
      for (int i = 6; i < names.length - 1; i++) {
        relatedDirs.add(names[i]);
      }
    }
    extension = fileName.split(".").last.toUpperCase();
    if (imgExt.any((element) => element.toUpperCase() == extension)) {
      type = "image";
    } else if (vidExt.any((element) => element.toUpperCase() == extension)) {
      type = "video";
    } else {
      type = "file";
    }
  }
}

class FirebaseStorageItem {
  FirebaseStorageItem? instance() {
    return this;
  }

  StorageRef ref([String? reference]) {
    return StorageRef.withReference(isValid()
        ? instanceStorageOriginal().ref(reference)
        : instanceStorageWindows().ref(reference));
  }
}

class ListResultForAll {
  final List<StorageRef> _items;
  final List<StorageRef> _prefixes;
  ListResultForAll(this._items, this._prefixes);

  List<StorageRef> get items => _items;
  List<StorageRef> get prefixes => _prefixes;
}

class FullMetadataForAll {
  // ignore: non_constant_identifier_names
  firebase_dart.FullMetadata? _metadata_windows;
  // ignore: non_constant_identifier_names
  FullMetadata? _metadata_original;

  FullMetadataForAll.withMetadata(dynamic metadata) {
    if (metadata is firebase_dart.FullMetadata) {
      _metadata_windows = metadata;
    } else {
      _metadata_original = metadata;
    }
  }

  get _metadata {
    if (_metadata_windows != null) {
      return _metadata_windows;
    } else {
      return _metadata_original;
    }
  }

  String? get bucket {
    return _metadata.bucket;
  }

  String? get cacheControl {
    return _metadata.cacheControl;
  }

  String? get contentDisposition {
    return _metadata.contentDisposition;
  }

  String? get contentEncoding {
    return _metadata.contentEncoding;
  }

  String? get contentLanguage {
    return _metadata.contentLanguage;
  }

  String? get contentType {
    return _metadata.contentType;
  }

  Map<String, String>? get customMetadata {
    return _metadata.customMetadata;
  }

  String get fullPath {
    return _metadata.fullPath;
  }

  String? get generation {
    return _metadata.generation;
  }

  String? get metadataGeneration {
    return _metadata.metadataGeneration;
  }

  String? get md5Hash {
    return _metadata.md5Hash;
  }

  String? get metageneration {
    return _metadata.metageneration;
  }

  String get name {
    return _metadata.name;
  }

  int? get size {
    return _metadata.size;
  }

  DateTime? get timeCreated {
    return _metadata.timeCreated;
  }

  DateTime? get updated {
    return _metadata.updated;
  }
}

enum TaskState {
  running,
  paused,
  success,
  canceled,
  error;
}

class ProcessTask {
  int processed, total;
  late double percentage;
  Uint8List? bytes;
  TaskState state;
  ProcessTask(
      {required this.processed,
      required this.total,
      required this.state,
      this.bytes}) {
    percentage = processed / total;
  }
}

class DownloadTaskForAll {
  final _streamController = StreamController<ProcessTask>();
  StreamSubscription<dynamic>? _downloadingStream;
  ProcessTask? _finalTask;
  File? targetFile;

  DownloadTaskForAll({this.targetFile});
  Future<void> cancel() async {
    if (_downloadingStream != null) {
      await _downloadingStream!.cancel();
      if (_finalTask != null) {
        _finalTask!.state = TaskState.canceled;
        _streamController.add(_finalTask!);
      } else {
        _streamController.add(
            ProcessTask(processed: 0, total: 0, state: TaskState.canceled));
      }
    }
  }

  void pause() {
    if (_downloadingStream != null) {
      _downloadingStream!.pause();
      if (_finalTask != null) {
        _finalTask!.state = TaskState.paused;
        _streamController.add(_finalTask!);
      } else {
        _streamController
            .add(ProcessTask(processed: 0, total: 0, state: TaskState.paused));
      }
    }
  }

  void resume() {
    if (_downloadingStream != null) {
      _downloadingStream!.resume();
      if (_finalTask != null) {
        _finalTask!.state = TaskState.running;
        _streamController.add(_finalTask!);
      } else {
        _streamController
            .add(ProcessTask(processed: 0, total: 0, state: TaskState.running));
      }
    }
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _streamController.addError(error, stackTrace);
    if (_finalTask != null) {
      _finalTask!.state = TaskState.error;
      _streamController.add(_finalTask!);
    } else {
      _streamController
          .add(ProcessTask(processed: 0, total: 0, state: TaskState.error));
    }
  }

  void updateTask(ProcessTask task) {
    _streamController.add(task);
    _finalTask = task;
    if (targetFile != null && task.bytes != null) {
      targetFile!.writeAsBytesSync(task.bytes!);
    }
  }

  set setDownloadingStream(StreamSubscription<dynamic> stream) {
    _downloadingStream = stream;
  }

  Stream<ProcessTask> get snapshotEvents => _streamController.stream;
}

enum PutStringFormat {
  /// A raw string. It will be uploaded as a Base64 string.
  raw,

  /// A Base64 encoded string.
  base64,

  /// A Base64 URL encoded string.
  base64Url,

  /// A data url string.
  dataUrl,
}

class SettableMetadata {
  SettableMetadata({
    this.cacheControl,
    this.contentDisposition,
    this.contentEncoding,
    this.contentLanguage,
    this.contentType,
    this.customMetadata,
  });
  final String? cacheControl;
  final String? contentDisposition;
  final String? contentEncoding;
  final String? contentLanguage;
  final String? contentType;
  final Map<String, String>? customMetadata;
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'cacheControl': cacheControl,
      'contentDisposition': contentDisposition,
      'contentEncoding': contentEncoding,
      'contentLanguage': contentLanguage,
      'contentType': contentType,
      'customMetadata': customMetadata,
    };
  }
}
