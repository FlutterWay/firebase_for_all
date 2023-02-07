import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_dart/firebase_dart.dart' as firebase_dart;
import 'package:flutter/foundation.dart';
import '../../functions.dart' as functions;
import 'models.dart';
import 'original.dart';
import 'original.dart' as original;
import 'windows.dart';

class StorageRef {
  // ignore: non_constant_identifier_names
  firebase_dart.Reference? _ref_windows;
  // ignore: non_constant_identifier_names
  storage.Reference? _ref_original;

  StorageRef.withReference(dynamic reference) {
    if (reference is firebase_dart.Reference) {
      _ref_windows = reference;
    } else {
      _ref_original = reference;
    }
  }

  Future<FullMetadataForAll> getMetadata() async {
    if (_ref_original != null) {
      var metadata = await _ref_original!.getMetadata();
      return FullMetadataForAll.withMetadata(metadata);
    } else {
      var metadata = await _ref_windows!.getMetadata();
      return FullMetadataForAll.withMetadata(metadata);
    }
  }

  UploadTaskForAll putString(
    String data, {
    PutStringFormat format = PutStringFormat.raw,
    storage.SettableMetadata? metadata,
  }) {
    if (_ref_original != null) {
      UploadTaskForAll task = UploadTaskForAll();
      task.setDownloadingStream = _ref_original!
          .putString(data,
              format: putStringFormatConverterOriginal(format),
              metadata: metadata)
          .snapshotEvents
          .listen((taskSnapshot) {
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: taskSnapshot.totalBytes,
            state: taskStateConverterOriginal(taskSnapshot.state)));
      }, onError: (e, stackTrace) {
        task.addError(e, stackTrace);
      });
      return task;
    } else {
      UploadTaskForAll task = UploadTaskForAll();
      firebase_dart.SettableMetadata? metadataTmp;
      if (metadata != null) {
        metadataTmp = firebase_dart.SettableMetadata(
            cacheControl: metadata.cacheControl,
            contentDisposition: metadata.cacheControl,
            contentEncoding: metadata.contentEncoding,
            contentLanguage: metadata.contentLanguage,
            contentType: metadata.contentType,
            customMetadata: metadata.customMetadata);
      }
      task.setDownloadingStream = _ref_windows!
          .putString(data,
              format: putStringFormatConverterWindows(format),
              metadata: metadataTmp)
          .snapshotEvents
          .listen((taskSnapshot) {
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: taskSnapshot.totalBytes,
            state: taskStateConverterWindows(taskSnapshot.state)));
      }, onError: (e, stackTrace) {
        task.addError(e, stackTrace);
      });
      return task;
    }
  }

  UploadTaskForAll putData(Uint8List data, [SettableMetadata? metadata]) {
    if (_ref_original != null) {
      UploadTaskForAll task = UploadTaskForAll();
      task.setDownloadingStream = _ref_original!
          .putData(
              data,
              metadata != null
                  ? settableMetadataConverterOriginal(metadata)
                  : null)
          .snapshotEvents
          .listen((taskSnapshot) {
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: taskSnapshot.totalBytes,
            state: taskStateConverterOriginal(taskSnapshot.state)));
      }, onError: (e, stackTrace) {
        task.addError(e, stackTrace);
      });
      return task;
    } else {
      UploadTaskForAll task = UploadTaskForAll();
      task.setDownloadingStream = _ref_windows!
          .putData(
              data,
              metadata != null
                  ? settableMetadataConverterWindows(metadata)
                  : null)
          .snapshotEvents
          .listen((taskSnapshot) {
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: taskSnapshot.totalBytes,
            state: taskStateConverterWindows(taskSnapshot.state)));
      }, onError: (e, stackTrace) {
        task.addError(e, stackTrace);
      });
      return task;
    }
  }

  UploadTaskForAll putFile(File file, [SettableMetadata? metadata]) {
    if (_ref_original != null) {
      UploadTaskForAll task = UploadTaskForAll();
      task.setDownloadingStream = _ref_original!
          .putFile(
              file,
              metadata != null
                  ? settableMetadataConverterOriginal(metadata)
                  : null)
          .snapshotEvents
          .listen((taskSnapshot) {
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: taskSnapshot.totalBytes,
            state: taskStateConverterOriginal(taskSnapshot.state)));
      }, onError: (e, stackTrace) {
        task.addError(e, stackTrace);
      });
      return task;
    } else {
      UploadTaskForAll task = UploadTaskForAll();
      task.setDownloadingStream = _ref_windows!
          .putData(
              file.readAsBytesSync(),
              metadata != null
                  ? settableMetadataConverterWindows(metadata)
                  : null)
          .snapshotEvents
          .listen((taskSnapshot) {
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: taskSnapshot.totalBytes,
            state: taskStateConverterWindows(taskSnapshot.state)));
      }, onError: (e, stackTrace) {
        task.addError(e, stackTrace);
      });
      return task;
    }
  }

  Future<void> delete() async {
    if (_ref_original != null) {
      await _ref_original!.delete();
    } else {
      await _ref_windows!.delete();
    }
  }

  //StorageRef get root=>
  Future<void> deleteFiles() async {
    if (_ref_original != null) {
      await deleteFilesOriginal(_ref_original!);
    } else {
      await deleteFilesWindows(_ref_windows!);
    }
  }

  Future<int> getSize() async {
    int size = 0;
    try {
      await getMetadata().then((value) => size = value.size!);
    } catch (e) {
      size = 0;
    }
    return size;
  }

  Future<int> getDirSize() async {
    int size = 0;
    try {
      ListResultForAll result = await listAll();
      // ignore: unused_local_variable
      for (var item in result.items) {
        size += await getSize();
      }
      var dirs = result.prefixes;
      // ignore: unused_local_variable
      for (var dir in dirs) {
        size += await getDirSize();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
    return size;
  }

  Future<String> getDownloadURL() async {
    if (_ref_original != null) {
      return await _ref_original!.getDownloadURL();
    } else {
      return await _ref_windows!.getDownloadURL();
    }
  }

  Future<Uint8List?> getData([int maxSize = 10485760]) async {
    if (_ref_original != null) {
      return await _ref_original!.getData(maxSize);
    } else {
      return await _ref_windows!.getData(maxSize);
    }
  }

  Future<DownloadTaskForAll> writeToFile(File file) async {
    if (_ref_original != null) {
      return original.writeToFile(file, _ref_original!);
    } else {
      String url = await getDownloadURL();
      return (await functions.downloadFile(url, file: file));
    }
  }

  Future<DownloadTaskForAll> downloadFile() async {
    String url = await getDownloadURL();
    return (await functions.downloadFile(url));
  }

  Future<ListResultForAll> listAll() async {
    if (_ref_original != null) {
      return await listAllOriginal(_ref_original!);
    } else {
      return await listAllWindows(_ref_windows!);
    }
  }

  Future<List<StorageFile>> scan() async {
    List<StorageFile> files = [];

    ListResultForAll result = await listAll();
    for (var item in result.items) {
      await child(item.name).getMetadata().then((value) => files.add(
          StorageFile(
              cloudPath: "$fullPath/${item.name}",
              fileName: item.name,
              reference: item,
              size: value.size!)));
    }
    var dirs = result.prefixes;
    for (var dir in dirs) {
      files.addAll((await child(dir.name).scan()));
    }
    return files;
  }

  Future<List<StorageFile>> getFiles() async {
    List<StorageFile> files = [];
    ListResultForAll result = await listAll();
    for (var item in result.items) {
      await child(item.name).getMetadata().then((value) => files.add(
          StorageFile(
              cloudPath: "$fullPath/${item.name}",
              fileName: item.name,
              reference: item,
              size: value.size!)));
    }
    return files;
  }

  Future<List<StorageDirectory>> getDirectories() async {
    List<StorageDirectory> directories = [];
    ListResultForAll result = await listAll();
    var dirs = result.prefixes;
    for (var dir in dirs) {
      directories.add(StorageDirectory(
          cloudPath: "$fullPath/${dir.name}",
          dirName: dir.name,
          reference: dir));
    }
    return directories;
  }

  StorageRef child(String ref) {
    return StorageRef.withReference(_ref_windows != null
        ? _ref_windows!.child(ref)
        : _ref_original!.child(ref));
  }

  String get name {
    if (_ref_original != null) {
      return _ref_original!.name;
    } else {
      return _ref_windows!.name;
    }
  }

  String get bucket {
    if (_ref_original != null) {
      return _ref_original!.bucket;
    } else {
      return _ref_windows!.bucket;
    }
  }

  String get fullPath {
    if (_ref_original != null) {
      return _ref_original!.fullPath;
    } else {
      return _ref_windows!.fullPath;
    }
  }

  @override
  String toString() {
    if (_ref_original != null) {
      return _ref_original!.toString();
    } else {
      return _ref_windows!.toString();
    }
  }

  StorageRef get parent {
    return StorageRef.withReference(
        _ref_windows != null ? _ref_windows!.parent : _ref_original!.parent);
  }

  StorageRef get root {
    return StorageRef.withReference(
        _ref_windows != null ? _ref_windows!.root : _ref_original!.root);
  }
}
