import 'package:flutter/material.dart';
import 'models.dart';

class CollectionBuilder<T extends Object?> extends StatefulWidget {
  final CollectionSnapshots<T> stream;
  final Widget Function(BuildContext, AsyncSnapshot<QuerySnapshotForAll<T>>)
      builder;
  const CollectionBuilder(
      {Key? key, required this.stream, required this.builder})
      : super(key: key);

  @override
  State<CollectionBuilder> createState() => _CollectionBuilderState<T>();
}

class _CollectionBuilderState<T extends Object?>
    extends State<CollectionBuilder<T>> {
  SnapshotState<QuerySnapshotForAll<T>>? state;
  _CollectionBuilderState() {
    state = const SnapshotState.waiting();
  }

  @override
  void initState() {
    widget.stream.listen((event) {
      state = SnapshotState<QuerySnapshotForAll<T>>.withData(
          ConnectionState.active, event);
      setState(() {});
    }, onError: (error, stackTrace) {
      state = SnapshotState<QuerySnapshotForAll<T>>.withError(
          ConnectionState.active, error, stackTrace);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (state!.hasData) {
      return widget.builder(context,
          AsyncSnapshot.withData(state!.connectionState, state!.data!));
    } else if (state!.hasError) {
      return widget.builder(
          context,
          AsyncSnapshot.withError(state!.connectionState, state!.error!,
              state!.stackTrace ?? StackTrace.empty));
    } else if (state!.isWaiting) {
      return widget.builder(context, const AsyncSnapshot.waiting());
    } else {
      return widget.builder(context, const AsyncSnapshot.nothing());
    }
  }
}

class DocumentBuilder<T extends Object?> extends StatefulWidget {
  final DocumentSnapshots<T> stream;
  final Widget Function(BuildContext, AsyncSnapshot<DocumentSnapshotForAll<T>>)
      builder;
  const DocumentBuilder({Key? key, required this.stream, required this.builder})
      : super(key: key);

  @override
  State<DocumentBuilder> createState() => _DocumentBuilderState<T>();
}

class _DocumentBuilderState<T extends Object?>
    extends State<DocumentBuilder<T>> {
  SnapshotState<DocumentSnapshotForAll<T>>? state;
  _DocumentBuilderState() {
    state = const SnapshotState.waiting();
  }

  @override
  void initState() {
    widget.stream.listen((event) {
      state = SnapshotState<DocumentSnapshotForAll<T>>.withData(
          ConnectionState.active, event);
      setState(() {});
    }, onError: (error, stackTrace) {
      state = SnapshotState<DocumentSnapshotForAll<T>>.withError(
          ConnectionState.active, error, stackTrace);
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (state!.hasData) {
      return widget.builder(context,
          AsyncSnapshot.withData(state!.connectionState, state!.data!));
    } else if (state!.hasError) {
      return widget.builder(
          context,
          AsyncSnapshot.withError(state!.connectionState, state!.error!,
              state!.stackTrace ?? StackTrace.empty));
    } else if (state!.isWaiting) {
      return widget.builder(context, const AsyncSnapshot.waiting());
    } else {
      return widget.builder(context, const AsyncSnapshot.nothing());
    }
  }
}
