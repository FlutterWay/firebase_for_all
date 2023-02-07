import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import 'firebase_for_all.dart';

bool isMacos() {
  return Platform.isMacOS;
}

bool isWindows() {
  return Platform.isWindows;
}

bool isLinux() {
  return Platform.isLinux;
}

bool isMobile() {
  return Platform.isIOS || Platform.isAndroid || Platform.isFuchsia;
}

bool isIOS() {
  return Platform.isIOS;
}

bool isAndroid() {
  return Platform.isAndroid;
}

bool isFuchsia() {
  return Platform.isFuchsia;
}

bool isValid() {
  return isMobile() || isMacos() || kIsWeb;
}

bool isDesktop() {
  return isWindows() || isMacos() || isLinux();
}

List<String> imgExt = [
  "apng",
  "avif",
  "gif",
  "jpg",
  "jpeg",
  "jfif",
  "pjpeg",
  "pjp",
  "png",
  "svg",
  "webp"
];
List<String> vidExt = [
  "webm",
  "mpg",
  "mp2",
  "mpeg",
  "mpe",
  "mpv",
  "ogg",
  "mp4",
  "m4p",
  "m4v",
  "avi",
  "wmv",
  "mov",
  "qt",
  "flv",
  "swf",
  "avchd"
];
List<String> audExt = [
  "m4a",
  "flac",
  "mp3",
  "wav",
  "wma",
  "aac",
];

Future<DownloadTaskForAll> downloadFile(String url, {File? file}) async {
  var task = DownloadTaskForAll(targetFile: file);

  var httpClient = Client();
  var request = Request('GET', Uri.parse(url));
  var response = await httpClient.send(request);
  List<List<int>> chunks = [];
  int downloaded = 0;
  int sayac = 0;
  task.setDownloadingStream = response.stream.listen((List<int> chunk) {
    if (sayac % 500 == 0) {
      task.updateTask(ProcessTask(
          processed: downloaded,
          total: response.contentLength!,
          state: TaskState.running));
    }
    chunks.add(chunk);
    downloaded += chunk.length;
    sayac++;
  }, onDone: () {
    double percentage = (downloaded / response.contentLength!);
    Uint8List? bytes;
    if (percentage == 1) {
      bytes = Uint8List(response.contentLength!);
      int offset = 0;
      for (List<int> chunk in chunks) {
        bytes.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      task.updateTask(ProcessTask(
          processed: downloaded,
          total: response.contentLength!,
          state: TaskState.success,
          bytes: bytes));
    }
  }, onError: (e, stackTrace) {
    task.addError(e, stackTrace);
  });
  return task;
}
