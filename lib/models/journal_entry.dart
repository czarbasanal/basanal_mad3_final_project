import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  String id;
  String userId;
  String title;
  String content;
  DateTime date;
  String imageUrl;
  GeoPoint location;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'date': date,
      'imageUrl': imageUrl,
      'location': location,
    };
  }

  static JournalEntry fromMap(Map<String, dynamic> map, String documentId) {
    return JournalEntry(
      id: documentId,
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      date: (map['date'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      location: map['location'],
    );
  }
}
