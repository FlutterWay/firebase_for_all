

This package is the way to use firebase features on all platforms without code changes. Its developed by using these packages(For desktop part):

* [firebase_dart](https://pub.dev/packages/firebase_dart)
* [firedart](https://pub.dev/packages/firedart)
* [firebase_auth_desktop](https://pub.dev/packages/firebase_auth_desktop)
* [firebase_core_desktop](https://pub.dev/packages/firebase_core_desktop)

firebase_dart & firedart are great packages but on non-windows patforms it is desirable to use original package. This package allows these packages to be channelized according to the running platform. Which means firedart will be working on windows platform, cloud_firestore on other platforms. New classes and functions have been designed carefully so that you 
dont have to modify your old codes

Like everyone else, I'm looking forward to the end of the flutterFire desktop process. I hope this library can help a little bit until then
## Features

Currently supports the following firebase services:

* Authentication
* Cloud firestore
* Cloud storage

## Examples
All examples in example/lib/functions.dart

## Usage

The documentation link will be added in future
 
You must add the library as a dependency to your project.
```yaml
dependencies:
 firebase_for_all: ^latest
```
Then run `flutter packages get`

## Getting started

Initiliaze firebase and choose the features you want. There are two ways to configure firebase for your project.

* Old school way: configure everything by hand
* New flutterfire way by using firebase CLI

Old school way:
```dart
  await FirebaseCoreForAll.initializeApp(
      options: FirebaseOptions(
        apiKey: 'XXXXXXXXXXXXXXXXXXXXXX',
        appId: 'XXXXXXXXXXXXXXXXXXXXXX',
        messagingSenderId: 'XXXXXXXXXXX',
        projectId: 'XXXXXXXXXXXXXX',
        authDomain: 'XXXXXXXXXXXXX.firebaseapp.com',
        storageBucket: 'XXXXXXXXXXXXX.appspot.com',
      ),
      firestore: true,
      auth: true,
      storage: true);
```

New flutterfire way:
```dart
  await FirebaseCoreForAll.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      firestore: true,
      auth: true,
      storage: true,
      functions: true);
```

## Cloud Storage

get FirebaseAuth.instance with "FirebaseAuthForAll.instance"

```dart
    await FirebaseAuthForAll.instance.createUserWithEmailAndPassword(email: "test@hotmail.com", password: "password123");
```
## Cloud Firestore

### Document & Query Snapshots

#### QuerySnapshot

```dart
FirestoreForAll.instance
.collection('users')
.get()
.then((QuerySnapshotForAll querySnapshot) {
    querySnapshot.docs.forEach((doc) {
        print(doc["first_name"]);
    });
});
```
#### DocumentSnapshot

```dart
FirestoreForAll.instance
    .collection('users')
    .doc(userId)
    .get()
    .then((DocumentSnapshotForAll documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()}');
      } else {
        print('Document does not exist on the database');
      }
    });
```

### Querying

#### Filtering

**Warning:** "isNotEqualTo" and "whereNotIn" dont work on desktop(except MACOS). You should use it with this in mind

```dart
FirestoreForAll.instance
    .collection('users')
    .where('age', isGreaterThan: 10)
    .get()
    .then(...);
```

#### Ordering


```dart
FirestoreForAll.instance
    .collection('users')
    .orderBy('age', descending: true)
    .get()
    .then(...);
```

#### Limiting

**Warning:** "limitToLast" doesnt work on desktop(except MACOS). You should use it with this in mind

```dart
FirestoreForAll.instance
    .collection('users')
    .limit(2)
    .get()
    .then(...);
```

#### Start & End Cursors

**Warning:** Unfortunately this feature doesnt work on desktop(except MACOS)

```dart
FirestoreForAll.instance
    .collection('users')
    .orderBy('age')
    .orderBy('company')
    .startAt([4, 'Alphabet Inc.'])
    .endAt([21, 'Google LLC'])
    .get()
    .then(...);
```

### Adding&Updating&Deleting Documents

```dart
ColRef users = FirestoreForAll.instance.collection('users');
users
    .add({
      'full_name': fullName, // John Doe
      'company': company, // Stokes and Sons
      'age': age // 42
    })
    .then((value) => print("User Added"))
    .catchError((error) => print("Failed to add user: $error"));

users
    .doc("12345")
    .set({
      'full_name': fullName, // John Doe
      'company': company, // Stokes and Sons
      'age': age // 42
    })
    .then((value) => print("User Added"))
    .catchError((error) => print("Failed to add user: $error"));

users
    .doc('ABC123')
    .update({'company': 'Stokes and Sons'})
    .then((value) => print("User Updated"))
    .catchError((error) => print("Failed to update user: $error"));

users
    .doc('ABC123')
    .delete()
    .then((value) => print("User Deleted"))
    .catchError((error) => print("Failed to delete user: $error"));
```

### Realtime changes

#### Listening collection


```dart
CollectionSnapshots  collectionSnapshots  = FirestoreForAll.instance.collection('users').snapshots();
collectionSnapshots.listen(
  (snapshot) {},
  onDone: () {},
  onError: (e, stackTrace) {},
);
```
**Warning:** StreamBuilder doesnt work for this one. Use this instead:

```dart
CollectionBuilder(
        stream: FirestoreForAll.instance.collection("users").snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshotForAll> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshotForAll document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                subtitle: Text(data['surname']),
              );
            }).toList(),
          );
        },
      )
```

#### Listening document


```dart
DocumentSnapshots documentSnapshots=FirestoreForAll.instance.collection('users').doc('ABC123').snapshots();
documentSnapshots.listen(
  (snapshot) {},
  onDone: () {},
  onError: (e, stackTrace) {},
);
```
**Warning:** StreamBuilder doesnt work for this one. Use this instead:

```dart
DocumentBuilder(
        stream: FirestoreForAll.instance
            .collection("users")
            .doc('ABC123')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshotForAll> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListTile(
            title: Text(snapshot.data!['name']),
            subtitle: Text(snapshot.data!['surname']),
          );
        },
      )
```

### Typing CollectionReference and DocumentReference

The only thing that has changed here is "User.fromJson(snapshot.map!)" instead of "User.fromJson(snapshot.data()!)"

```dart
final moviesRef = FirestoreForAll.instance.collection('movies').withConverter<User>(
      fromFirestore: (snapshot, _) => User.fromJson(snapshot.map!),
      toFirestore: (movie, _) => movie.toJson(),
    );
```

```dart
// Obtain 31 aged users
  List<DocumentSnapshotForAll<User>> users = await userRef
      .where('age', isEqualTo: 31)
      .get()
      .then((snapshot) => snapshot.docs);

  // Add a user
  await userRef.add(
    User(
      name: 'Chris',
      surname: 'Doe',
      age: 20
    ),
  );

  // Get a user with the id 42
  User user = await userRef.doc('42').get().then((snapshot) => snapshot.data()!);
```

## Cloud Storage

### Upload Files

#### Upload from a file

```dart
  final storageRef = FirebaseStorageForAll.instance.ref();
  final mountainsRef = storageRef.child("mountains.jpg");
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String filePath = '${appDocDir.absolute}/file-to-upload.png';
  File file = File(filePath);

  UploadTaskForAll task= mountainsRef.putFile(file);
```
#### Upload from a String

```dart
  String dataUrl = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==';
  UploadTaskForAll task= mountainsRef.putString(dataUrl, format: PutStringFormat.dataUrl);
```
#### Uploading raw data

```dart
  UploadTaskForAll  task= mountainsRef.putData(file.readAsBytesSync());
```
#### Get Download Url

```dart
  await mountainsRef.getDownloadURL();
```
### Manage Uploads

```dart
    File file = File(filePath);
  mountainsRef.putFile(file).snapshotEvents.listen((taskSnapshot) {
  switch (taskSnapshot.state) {
    case TaskState.running:
      // ...
      break;
    case TaskState.paused:
      // ...
      break;
    case TaskState.success:
      // ...
      break;
    case TaskState.canceled:
      // ...
      break;
    case TaskState.error:
      // ...
      break;
  }
});
```
### Download Files

### Download in memory

```dart
  final storageRef = FirebaseStorageForAll.instance.ref();
  final islandRef = storageRef.child("images/island.jpg");
  const oneMegabyte = 1024 * 1024;
  final Uint8List? data = await islandRef.getData(oneMegabyte);
```
### Download to a local file

```dart
  final islandRef = storageRef.child("images/island.jpg");

  final appDocDir = await getApplicationDocumentsDirectory();
  final filePath = "${appDocDir.absolute}/images/island.jpg";
  final file = File(filePath);

  DownloadTaskForAll downloadTask = await islandRef.writeToFile(file);
```
### Manage Downloads

```dart
  downloadTask.snapshotEvents.listen((taskSnapshot) {
    switch (taskSnapshot.state) {
      case TaskState.running:
        // TODO: Handle this case.
        break;
      case TaskState.paused:
        // TODO: Handle this case.
        break;
      case TaskState.success:
        // TODO: Handle this case.
        break;
      case TaskState.canceled:
        // TODO: Handle this case.
        break;
      case TaskState.error:
        // TODO: Handle this case.
        break;
    }
  });
```
### Delete File

```dart
  final desertRef = storageRef.child("images/desert.jpg");
  await desertRef.delete();
```
### List all files
```dart
final storageRef = FirebaseStorage.instance.ref().child("files/uid");
final listResult = await storageRef.listAll();
for (var prefix in listResult.prefixes) {
  // The prefixes under storageRef.
  // You can call listAll() recursively on them.
}
for (var item in listResult.items) {
  // The items under storageRef.
}
```
## New Features

### StorageFile

```dart
class StorageFile{
  String cloudPath;
  String fileName;
  StorageRef reference;
  String type,extension;
  List<String> relatedDirs;
  int size;
}
```

### StorageDirectory

```dart
class StorageDirectory{
  String cloudPath;
  String dirName;
  StorageRef reference;
  List<String> relatedDirs;
}
```

### New Function - getFiles()

This function is to get information of every files inside reference path

```dart
List<StorageFile> files = await storageRef.getFiles();
```

### New Function - getSize()

This function is to get the file size

```dart
  final desertRef = FirebaseStorageForAll.instance.ref().child("images/desert.jpg");

  int size = await desertRef.getSize();
```
### New Function - getDirectories()

This function is to get information of every directories inside reference path

```dart
  List<StorageDirectory> files = await storageRef.getDirectories();
```

### New Function - getDirSize()

This function is to get the file size

```dart
  final storageRef = FirebaseStorageForAll.instance.ref().child("files/uid");

  int size = await storageRef.getDirSize();
```

