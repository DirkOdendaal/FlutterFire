import 'dart:async';

import 'package:cloud/models/firebase_file.dart';
import 'package:cloud/pages/image_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PictureGrid extends StatelessWidget {
  final String currentFolder;
  final String currentUser;
  const PictureGrid(
      {Key? key, required this.currentUser, required this.currentFolder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = FirebaseDatabase(
            databaseURL:
                "https://cloud-a8697-default-rtdb.europe-west1.firebasedatabase.app/")
        .reference();
    late List<FirebaseFile> streamList;

    Stream _dataStream =
        database.child('users/$currentUser/$currentFolder').onValue;

    return StreamBuilder(
      stream: _dataStream,
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasData) {
              final snapDataEvent = snapshot.data as Event;
              final dataEventValues = snapDataEvent.snapshot.value;
              if (dataEventValues != null && dataEventValues != "blankFolder") {
                final data = Map<String, dynamic>.from(dataEventValues);

                streamList = data
                    .map((key, value) {
                      final id = key;
                      final name = value["imageName"] as String;
                      final date = value["dateCreated"] as String;
                      final dateMOd = value["dateModified"] as String;
                      final url = value["url"] as String;
                      final path = value["path"] as String;
                      final extent = value["extention"] as String;
                      final file = FirebaseFile(
                          name: name,
                          dateCreated: date,
                          dateModified: dateMOd,
                          url: url,
                          id: id,
                          extention: extent,
                          path: path);
                      return MapEntry(key, file);
                    })
                    .values
                    .toList();

                return GridView.builder(
                    shrinkWrap: true,
                    itemCount: streamList.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 20,
                            childAspectRatio: 3 / 2,
                            mainAxisSpacing: 20),
                    itemBuilder: (context, index) {
                      final file = streamList[index];
                      return buildGrid(context, file);
                    });
              } else {
                print("DataEventValues Blank");
                return const Center(
                  child: Text("You have no files in This Folder"),
                );
              }
            } else {
              print("Snapshot Blank");
              return const Center(
                child: Text("You have no files in This Folder"),
              );
            }
        }
      },
    );
  }

  Widget buildGrid(BuildContext context, FirebaseFile file) {
    return Draggable(
      child: GridTile(
        child: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: Image.network(file.url),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ImagePage(
                    file: file,
                    currentFolder: currentFolder,
                  ))),
        ),
      ),
      feedback: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Image.asset('assets/images/placeholder.png'),
          ],
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        width: 48,
        height: 48,
      ),
    );
  }
}
