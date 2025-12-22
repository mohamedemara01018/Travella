import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String tripId;
  final int dayNumber;
  final String title;
  final String content;
  final String category; // 'Transport', 'Logistics', 'Food', 'Activities', 'Other'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'dayNumber': dayNumber,
      'title': title,
      'content': content,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory Note.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      dayNumber: data['dayNumber'] ?? 1,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'Other',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Note copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

