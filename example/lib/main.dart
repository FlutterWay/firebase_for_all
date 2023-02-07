import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_for_all/firebase_for_all.dart';
import 'firebase_options.dart';
import 'functions.dart';

void main() async {
  await FirebaseCoreForAll.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      firestore: true,
      auth: true,
      storage: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: "title"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CollectionBuilder(
        stream: FirestoreForAll.instance.collection("users").snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshotForAll> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
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
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: getCollection,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
