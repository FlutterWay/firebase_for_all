import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'bridge.dart';
import 'models.dart' as models;
import 'models.dart';

FirebaseStorage instanceStorageOriginal() {
  return FirebaseStorage.instance;
}

models.TaskState taskStateConverterOriginal(firebase_storage.TaskState state) {
  if (state == firebase_storage.TaskState.paused) {
    return models.TaskState.paused;
  } else if (state == firebase_storage.TaskState.running) {
    return models.TaskState.running;
  } else if (state == firebase_storage.TaskState.success) {
    return models.TaskState.success;
  } else if (state == firebase_storage.TaskState.canceled) {
    return models.TaskState.canceled;
  } else {
    return models.TaskState.error;
  }
}

Future<DownloadTaskForAll> writeToFile(File file, Reference ref) async {
  DownloadTaskForAll task = DownloadTaskForAll(targetFile: file);
  DownloadTask originalTask = ref.writeToFile(file);
  task.setDownloadingStream =
      originalTask.snapshotEvents.listen((taskSnapshot) {
    int total = taskSnapshot.metadata?.size ?? 0;
    switch (taskSnapshot.state) {
      case firebase_storage.TaskState.running:
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: total,
            state: models.TaskState.running));
        break;
      case firebase_storage.TaskState.paused:
        break;
      case firebase_storage.TaskState.success:
        task.updateTask(ProcessTask(
            processed: taskSnapshot.bytesTransferred,
            total: total,
            state: models.TaskState.success));
        break;
      case firebase_storage.TaskState.canceled:
        break;
      case firebase_storage.TaskState.error:
        break;
    }
  }, onError: (e, stackTrace) {
    task.addError(e, stackTrace);
  });
  return task;
}

Future<ListResultForAll> listAllOriginal(Reference ref) async {
  Reference reference = ref;
  ListResult originalResult = await reference.listAll();
  return ListResultForAll(
      originalResult.items.map((e) => StorageRef.withReference(e)).toList(),
      originalResult.prefixes.map((e) => StorageRef.withReference(e)).toList());
}

Future<void> deleteFilesOriginal(Reference ref) async {
  Reference reference = ref;
  ListResult result = await reference.listAll();
  for (var item in result.items) {
    await ref.child(item.name).delete();
  }
  var dirs = result.prefixes;
  for (var dir in dirs) {
    await deleteFilesOriginal(reference.child(dir.name));
  }
}
