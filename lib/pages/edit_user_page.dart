import 'package:flutter/material.dart';

import '../models/user.dart';

class EditUser extends StatelessWidget {
  final User currenUser;
  const EditUser({Key? key, required this.currenUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
      ),
      body: Row(
        children: [
          Column(
            children: [
              Card(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(currenUser.userImage),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit Profile"))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: const [
                                    Text('Username : '),
                                    Text('Email : ')
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currenUser.username),
                                    Text(currenUser.email)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
