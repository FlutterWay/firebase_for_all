library firebase_for_all;

export 'functions.dart';
export 'firebase/firestore/bridge.dart';
export 'firebase/firestore/widgets.dart';
export 'firebase/firestore/models.dart';
export 'firebase/storage/models.dart';
export 'firebase/storage/bridge.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_desktop/firebase_core_desktop.dart'
    as firebase_core_desktop;
import 'package:firebase_auth_desktop/firebase_auth_desktop.dart'
    as firebase_auth_desktop;
import 'package:get/get.dart';
import 'firebase/firestore/bridge.dart';
import 'firebase/firestore/windows.dart';
import 'firebase/storage/models.dart';
import 'firebase/storage/windows.dart';
import 'functions.dart';

class FirebaseCoreForAll {
  static Future<void> initializeApp({
    String? name,
    required FirebaseOptions options,
    required bool firestore,
    required bool auth,
    required bool storage,
    //required bool functions,
  }) async {
    FirebaseControlPanel panel = Get.put(FirebaseControlPanel(
      firestore: firestore,
      storage: storage,
    ));
    panel.setOptions = options;
    panel.setName = name;
    if (isValid() || (!isValid() && (auth /*|| functions*/))) {
      if (isDesktop()) {
        firebase_core_desktop.FirebaseCore.registerWith();
        firebase_auth_desktop.FirebaseAuthDesktop.registerWith();
      }
      await Firebase.initializeApp(
          name: Get.find<FirebaseControlPanel>().name,
          options: Get.find<FirebaseControlPanel>().options);
    }
    if (!isValid() && firestore) {
      await initFirestoreWindows();
    }
    if (!isValid() && storage) {
      await initStorageWindows();
    }
    if (auth) {
      Get.find<FirebaseControlPanel>().instanceAuth();
    }
    //if (functions) {
    //  Get.find<FirebaseControlPanel>().instanceFunctions();
    //}
  }
}

class FirestoreForAll {
  static FirestoreItem get instance {
    return Get.find<FirebaseControlPanel>().firestore!;
  }
}

class FirebaseAuthForAll {
  static FirebaseAuth get instance {
    return Get.find<FirebaseControlPanel>().auth!;
  }
}

class FirebaseStorageForAll {
  static FirebaseStorageItem get instance {
    return Get.find<FirebaseControlPanel>().storage!.instance()!;
  }
}
//class FirebaseFunctionsForAll {
//  static FirebaseFunctions get instance {
//    return Get.find<FirebaseControlPanel>().functions!;
//  }
//}

class FirebaseControlPanel extends GetxController {
  String? _name;
  FirebaseOptions? _options;
  FirestoreItem? _firestore;
  FirebaseStorageItem? _storage;
  FirebaseAuth? _auth;
  //FirebaseFunctions? _functions;
  FirebaseControlPanel({required bool firestore, required bool storage}) {
    if (firestore) {
      _firestore = FirestoreItem();
    }
    if (storage) {
      _storage = FirebaseStorageItem();
    }
  }
  set setOptions(FirebaseOptions options) {
    _options = options;
  }

  set setName(String? name) {
    _name = name;
  }

  void instanceAuth() {
    _auth = FirebaseAuth.instance;
  }

  FirebaseOptions? get options => _options;

  FirestoreItem? get firestore => _firestore;
  FirebaseAuth? get auth => _auth;
  FirebaseStorageItem? get storage => _storage;
  //FirebaseFunctions? get functions => _functions;

  String? get name => _name;
}
