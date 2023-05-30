import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/entry_model.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/entry_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _remarkController = TextEditingController();

  int currentIndex = 0;

  List<DocumentSnapshot> _documents = [];

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xFF090c12),
        child: ListView(children: [
          Row(
            children: [Expanded(child: header())],
          ),
          Row(
            children: [Expanded(child: todaysEntry())],
          ),
          const Divider(),
          Row(
            children: [Expanded(child: listOfEntries())],
          ),
          Row(
            children: [Expanded(child: isUnderQuarantine())],
          ),
          Row(
            children: [Expanded(child: isUnderMonitoring())],
          ),
        ]));
  }

  Widget header() {
    String currentUserUid = context.read<AuthProvider>().currentUser.uid;

    return FutureBuilder<Map<String, dynamic>?>(
      future: context.read<UserProvider>().viewSpecificStudent(currentUserUid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error encountered! ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        Map<String, dynamic>? student = snapshot.data;

        String firstName = student?['name'];

        return Container(
          margin: const EdgeInsets.all(20.0),
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF526bf2),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ('Welcome ${firstName}'),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Your health deserves to be constantly checked.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget todaysEntry() {
    DateTime timeToday = DateTime.now();
    timeToday = DateTime(timeToday.year, timeToday.month, timeToday.day);
    User user = context.read<AuthProvider>().currentUser;
    context.read<EntryProvider>().getTodayEntry(user);
    DailyEntry? entry = context.read<EntryProvider>().entryToday;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFF222429),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      height: 100,
      child: Column(children: [
        const Text(
          'Today\'s Entry',
          style: TextStyle(fontSize: 16),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_box_rounded,
                  color: Colors.green.shade700,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add-entry');
                  },
                  child: const Text('Add Entry'),
                )
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.blue.shade900,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-entry');
                  },
                  child: const Text('Edit Entry'),
                )
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          title: const Text('Delete Today\'s Entry'),
                          content: Form(
                            key: formKey,
                            child: TextFormField(
                                controller: _remarkController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a remark';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Reason for deleting entry',
                                ),
                                onChanged: (String value) {
                                  entry!.remarks = value;
                                }),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  child: const Text('Submit'),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      final entryProvider =
                                          context.read<EntryProvider>();
                                      entryProvider.entryDeleteRequest(
                                          entry!.entryId!, entry);

                                      // formKey.currentState?.save();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Successfully requested for deleting entry!')));
                                      setState(() {
                                        _remarkController.clear();
                                      });

                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                                TextButton(
                                  child: const Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Delete Entry'),
                )
              ],
            )
          ],
        )
      ]),
    );
  }

  Widget listOfEntries() {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/user-entries');
        },
        child: Container(
            margin:
                const EdgeInsets.only(right: 40, left: 40, top: 10, bottom: 10),
            padding: const EdgeInsets.only(left: 40, right: 40),
            height: 70,
            decoration: const BoxDecoration(
                color: Color(0xFF222429),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.list_alt_rounded,
                  size: 40,
                  color: Colors.white,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'List of Health Status Entries',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      'Number of Entries: ${numOfEntries()}',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    )
                  ],
                )
              ],
            )));
  }

  Widget isUnderQuarantine() {
    return Container(
        margin: const EdgeInsets.only(right: 40, left: 40, top: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 50, right: 40),
        height: 70,
        decoration: const BoxDecoration(
            color: Color(0xFF222429),
            borderRadius: BorderRadius.all(Radius.circular(50))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              Icons.sick,
              size: 40,
              color: Colors.white,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Is under quarantine?',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  'No',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )
              ],
            )
          ],
        ));
  }

  Widget isUnderMonitoring() {
    return Container(
        margin: const EdgeInsets.only(right: 40, left: 40, top: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 50, right: 40),
        height: 70,
        decoration: const BoxDecoration(
            color: Color(0xFF222429),
            borderRadius: BorderRadius.all(Radius.circular(50))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(
              Icons.monitor,
              size: 40,
              color: Colors.white,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Is under monitoring?',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  'No',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                )
              ],
            )
          ],
        ));
  }

  int numOfEntries() {
    int counter = 0;
    for (int index = 0; index < _documents.length; index++) {
      DailyEntry entry =
          DailyEntry.fromJson(_documents[index].data() as Map<String, dynamic>);

      if (entry.uid == context.read<AuthProvider>().currentUser.uid) {
        counter++;
      }
    }
    return counter;
  }
}