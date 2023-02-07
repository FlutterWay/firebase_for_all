import 'package:firebase_dart/firebase_dart.dart' as firebase_dart;
import 'package:get/get.dart';
import '../../../firebase_for_all.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'models.dart' as models;

firebase_dart.PutStringFormat putStringFormatConverterWindows(
    PutStringFormat state) {
  if (state == PutStringFormat.raw) {
    return firebase_dart.PutStringFormat.raw;
  } else if (state == PutStringFormat.base64) {
    return firebase_dart.PutStringFormat.base64;
  } else if (state == PutStringFormat.base64Url) {
    return firebase_dart.PutStringFormat.base64Url;
  } else {
    return firebase_dart.PutStringFormat.dataUrl;
  }
}

firebase_storage.PutStringFormat putStringFormatConverterOriginal(
    PutStringFormat state) {
  if (state == PutStringFormat.raw) {
    return firebase_storage.PutStringFormat.raw;
  } else if (state == PutStringFormat.base64) {
    return firebase_storage.PutStringFormat.base64;
  } else if (state == PutStringFormat.base64Url) {
    return firebase_storage.PutStringFormat.base64Url;
  } else {
    return firebase_storage.PutStringFormat.dataUrl;
  }
}

firebase_dart.SettableMetadata settableMetadataConverterWindows(
    SettableMetadata metadata) {
  return firebase_dart.SettableMetadata(
      cacheControl: metadata.cacheControl,
      contentDisposition: metadata.contentDisposition,
      contentEncoding: metadata.contentEncoding,
      contentLanguage: metadata.contentLanguage,
      contentType: metadata.contentType,
      customMetadata: metadata.customMetadata);
}

firebase_storage.SettableMetadata settableMetadataConverterOriginal(
    SettableMetadata metadata) {
  return firebase_storage.SettableMetadata(
      cacheControl: metadata.cacheControl,
      contentDisposition: metadata.contentDisposition,
      contentEncoding: metadata.contentEncoding,
      contentLanguage: metadata.contentLanguage,
      contentType: metadata.contentType,
      customMetadata: metadata.customMetadata);
}

models.TaskState taskStateConverterWindows(firebase_dart.TaskState state) {
  if (state == firebase_dart.TaskState.paused) {
    return models.TaskState.paused;
  } else if (state == firebase_dart.TaskState.running) {
    return models.TaskState.running;
  } else if (state == firebase_dart.TaskState.success) {
    return models.TaskState.success;
  } else if (state == firebase_dart.TaskState.canceled) {
    return models.TaskState.canceled;
  } else {
    return models.TaskState.error;
  }
}

Future<dynamic> initStorageWindows() async {
  firebase_dart.FirebaseDart.setup(storagePath: 'users/');
  var options = Get.find<FirebaseControlPanel>().options!;
  await firebase_dart.Firebase.initializeApp(
      options: firebase_dart.FirebaseOptions(
          apiKey: options.apiKey,
          authDomain: options.authDomain,
          projectId: options.projectId,
          storageBucket: options.storageBucket,
          messagingSenderId: options.messagingSenderId,
          appId: options.appId));
}

firebase_dart.FirebaseStorage instanceStorageWindows() {
  return firebase_dart.FirebaseStorage.instance;
}

Future<ListResultForAll> listAllWindows(firebase_dart.Reference ref) async {
  firebase_dart.Reference reference = ref;
  firebase_dart.ListResult originalResult = await reference.listAll();
  return ListResultForAll(
      originalResult.items.map((e) => StorageRef.withReference(e)).toList(),
      originalResult.prefixes.map((e) => StorageRef.withReference(e)).toList());
}

Future<void> deleteFilesWindows(firebase_dart.Reference ref) async {
  firebase_dart.Reference reference = ref;
  firebase_dart.ListResult result = await reference.listAll();
  for (var item in result.items) {
    await ref.child(item.name).delete();
  }
  var dirs = result.prefixes;
  for (var dir in dirs) {
    await deleteFilesWindows(reference.child(dir.name));
  }
}
