import 'package:flutter/material.dart';
import '../../model/user_model.dart';
import '../../provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentQuarantine extends StatefulWidget {
  const StudentQuarantine({Key? key}) : super(key: key);

  @override
  State<StudentQuarantine> createState() => _StudentQuarantineState();
}

class _StudentQuarantineState extends State<StudentQuarantine> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> quarantinedStudents =
        context.watch<UserProvider>().allQuarantinedStudents;

    return StreamBuilder(
      stream: quarantinedStudents,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Error encountered! ${snapshot.error}"),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No students found."),
          );
        }

        return Padding(
          padding: EdgeInsets.all(16.0), // Adjust the padding value as needed
          child: ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: ((context, index) {
              UserDetails students = UserDetails.fromJson(
                  snapshot.data?.docs[index].data() as Map<String, dynamic>, 0);
              return Card(
                child: ListTile(
                  title: Text(students.name),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}