import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/entry_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseEntryAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<String> addEntry(Map<String, dynamic> entry, User user) async {
    DateTime timeToday = DateTime.now();
    timeToday = DateTime(timeToday.year, timeToday.month, timeToday.day);

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('entry')
        .where('entryDate', isEqualTo: timeToday)
        .where('uid', isEqualTo: user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return "You have already added an entry for today";
    }

    try {
      final docRef = await db.collection("entry").add(entry);
      await db
          .collection("entry")
          .doc(docRef.id)
          .update({'entryId': docRef.id});

      return "Successfully added entry!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> updateMonitoring(String uid) async {
    try {
      await db.collection("user").doc(uid).update({'underMonitoring': true});

      return "Successfully updated Monitoring!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<DailyEntry?> getTodayEntry(User user) async {
    DateTime timeToday = DateTime.now();
    timeToday = DateTime(timeToday.year, timeToday.month, timeToday.day);

    try {
      final snapshot = await db
          .collection("entry")
          .where('uid', isEqualTo: user.uid)
          .where('entryDate', isEqualTo: timeToday)
          .get();

      if (snapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot document = snapshot.docs[0];
        Map<String, dynamic> entryData =
            document.data() as Map<String, dynamic>;
        // Use the entryData map as needed
        DailyEntry entry = DailyEntry.fromJson(entryData, 'fetch');
        return entry;
      } else {
        print('No matching documents found.');
        return null;
      }
    } on FirebaseException catch (e) {
      throw e;
    }
  }

  Future<String> editEntryRequest(String entryId, DailyEntry entry) async {
    DateTime timeToday = DateTime.now();
    timeToday = DateTime(timeToday.year, timeToday.month, timeToday.day);

    try {
      // print(entry.symptoms);
      final docRef = await db.collection("entryEditRequests").add({
        'symptoms': entry.symptoms,
        'requestDate': timeToday,
        'closeContact': entry.closeContact,
        'remarks': entry.remarks,
        'entryId': entryId,
        'entryDate': entry.entryDate,
        'status': 'Pending'
      });

      await db
          .collection("entry")
          .doc(entryId)
          .update({'remarks': entry.remarks, 'status': "Pending"});
      // print(entry.symptoms);
      await db
          .collection("entryEditRequests")
          .doc(docRef.id)
          .update({'entryRequestId': docRef.id});

      await db
          .collection("entryEditRequests")
          .doc(docRef.id)
          .update({'uid': docRef.id});

      return "Successfully requested for editing entry!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Stream<QuerySnapshot> fetchAllEntries() {
    try {
      return db
          .collection("entry")
          .orderBy('entryDate', descending: true)
          .snapshots();
    } on FirebaseException catch (e) {
      throw e;
    }
  }

  // gawa ng update monitoring. gawin true yung under monitoring kapag naglagay si user na may entry na may close contact siya

  // Method to validateQRCode by checking if the entryId is valid and if the uid is the same as the uid of the entry
  Future<bool> validateQRCode(String uid, String entryId) {
    DateTime timeToday = DateTime.now();
    timeToday = DateTime(timeToday.year, timeToday.month, timeToday.day);
    try {
      return db
          .collection("entry")
          .where('id', isEqualTo: entryId)
          .where('uid', isEqualTo: uid)
          .where('entryDate', isEqualTo: timeToday)
          .get()
          .then((value) => value.docs.isNotEmpty);
    } on FirebaseException catch (e) {
      rethrow;
    }
  }

  Future<String> editRequest(
      DailyEntry entryRequest, String entryRequestId, String status) async {
    try {
      if (status == "Approved") {
        await db.collection("entry").doc(entryRequest.entryId).update({
          'symptoms': entryRequest.symptoms,
          'closeContact': entryRequest.closeContact,
          'remarks': entryRequest.remarks,
          'status': entryRequest.status,
        });
      } else {
        await db.collection("entry").doc(entryRequest.entryId).update({
          'remarks': entryRequest.remarks,
          'status': entryRequest.status,
        });
      }
      // await db.collection("entryEditRequests").doc(entryRequestId).delete();
      return "Successfully edited entry!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Future<String> deleteRequest(
      DailyEntry entryRequest, String entryRequestId, String status) async {
    try {
      if (status == "Approved") {
        await db.collection("entry").doc(entryRequest.entryId).delete();
      } else {
        await db.collection("entry").doc(entryRequest.entryId).update({
          'remarks': entryRequest.remarks,
          'status': entryRequest.status,
        });
      }

      await db.collection("entryDeleteRequests").doc(entryRequestId).delete();
      return "Successfully deleted entry!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Stream<QuerySnapshot> fetchAllRequestedEntries() {
    try {
      return db
          .collection("entryEditRequests")
          .orderBy('requestDate', descending: true)
          .snapshots();
    } on FirebaseException catch (e) {
      throw e;
    }
  }

  Future<String> entryDeleteRequest(String entryId, DailyEntry entry) async {
    DateTime timeToday = DateTime.now();
    timeToday = DateTime(timeToday.year, timeToday.month, timeToday.day);
    try {
      await db
          .collection("entry")
          .doc(entryId)
          .update({'remarks': entry.remarks, 'status': "Pending"});

      final docRef = await db.collection("entryDeleteRequests").add({
        'symptoms': entry.symptoms,
        'requestDate': timeToday,
        'closeContact': entry.closeContact,
        'remarks': entry.remarks,
        'entryId': entryId,
        'entryDate': entry.entryDate,
        'status': 'Pending'
      });
      // await db.collection("entry").doc(docRef.id).update({'id': docRef.id});
      await db
          .collection("entryDeleteRequests")
          .doc(docRef.id)
          .update({'entryRequestId': docRef.id});

      await db
          .collection("entryDeleteRequests")
          .doc(docRef.id)
          .update({'uid': docRef.id});

      return "Successfully requested for deleting entry!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }

  Stream<QuerySnapshot> fetchAllEntryDeleteRequests() {
    try {
      return db
          .collection("entryDeleteRequests")
          .orderBy('requestDate', descending: true)
          .snapshots();
    } on FirebaseException catch (e) {
      throw e;
    }
  }

  Future<String> updateStatus(String entryRequestId, String status) async {
    try {
      await db.collection("entryEditRequests").doc(entryRequestId).update({
        'status': status,
      });

      return "Successfully edited status entry!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}";
    }
  }
}
