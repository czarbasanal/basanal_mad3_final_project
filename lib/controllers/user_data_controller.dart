import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/journal_entry.dart';
import '../models/user.dart';

class UserDataController with ChangeNotifier {
  ValueNotifier<UserModel?> userModelNotifier = ValueNotifier(null);
  ValueNotifier<List<JournalEntry>> journalEntriesNotifier = ValueNotifier([]);
  StreamSubscription<DocumentSnapshot>? userStream;
  StreamSubscription<QuerySnapshot>? entriesStream;

  static UserDataController get instance =>
      GetIt.instance<UserDataController>();

  static void initialize() {
    GetIt.instance.registerSingleton<UserDataController>(UserDataController());
  }

  String? get currentUserId => userModelNotifier.value?.id;

  void setUserModel(UserModel? user) {
    userModelNotifier.value = user;
    notifyListeners();
    if (user != null) {
      listenToUserChanges(user.id);
      listenToJournalEntries(user.id);
    } else {
      userStream?.cancel();
      entriesStream?.cancel();
      userStream = null;
      entriesStream = null;
      journalEntriesNotifier.value = [];
    }
  }

  void listenToUserChanges(String uid) {
    userStream ??= FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots()
        .listen(onUserDataChange);
  }

  void onUserDataChange(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final userModel = UserModel.fromMap(data, snapshot.id);
        userModelNotifier.value = userModel;
        notifyListeners();
      }
    }
  }

  void listenToJournalEntries(String userId) {
    entriesStream?.cancel();
    entriesStream = FirebaseFirestore.instance
        .collection("journal_entries")
        .where("userId", isEqualTo: userId)
        .snapshots()
        .listen(onJournalEntriesChange);
  }

  void onJournalEntriesChange(QuerySnapshot<Map<String, dynamic>> snapshot) {
    List<JournalEntry> entries = snapshot.docs
        .map((doc) => JournalEntry.fromMap(doc.data(), doc.id))
        .toList();
    journalEntriesNotifier.value = entries;
    notifyListeners();
  }

  @override
  void dispose() {
    userStream?.cancel();
    entriesStream?.cancel();
    super.dispose();
  }
}
