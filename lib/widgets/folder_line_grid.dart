import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class FolderBar extends StatefulWidget {
  final currentUser;
  const FolderBar({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<FolderBar> createState() => _FolderBarState();
}

class _FolderBarState extends State<FolderBar> {
  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase(
            databaseURL:
                "https://cloud-a8697-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    late Iterable<String> streamList;

    return StreamBuilder(
        stream: database.child('users/${widget.currentUser}').onValue,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              const CircularProgressIndicator();
              break;
            default:
              final snapDataEvent = snapshot.data as Event;
              final dataEventValues = snapDataEvent.snapshot.value;
              if (dataEventValues != null) {
                final data = Map<String, dynamic>.from(dataEventValues);
                streamList = data.keys;
                ScrollController _c = ScrollController();
                return SizedBox(
                  child: GridView.builder(
                      shrinkWrap: true,
                      controller: _c,
                      itemCount: streamList.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 10,
                              childAspectRatio: 15 / 2,
                              mainAxisSpacing: 10),
                      itemBuilder: (context, index) {
                        final folderName = streamList.elementAt(index);
                        return buildGrid(context, folderName, index);
                      }),
                  height: 75,
                );
              } else {
                return Container();
              }
          }
          return Container();
        });
  }

  Widget buildGrid(BuildContext context, String foldername, int index) {
    return GridTile(
        child: Container(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.folder_rounded),
          label: Text(foldername)),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
    ));
  }
}
