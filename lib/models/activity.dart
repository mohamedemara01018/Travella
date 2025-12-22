import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String tripId;
  final int dayNumber;
  final String title;
  final String location;
  final DateTime time;
  final String period; // 'Morning', 'Afternoon', 'Evening', 'Night'
  final String? description;
  final String icon; // Icon name or code
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.tripId,
    required this.dayNumber,
    required this.title,
    required this.location,
    required this.time,
    required this.period,
    this.description,
    this.icon = 'event',
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'dayNumber': dayNumber,
      'title': title,
      'location': location,
      'time': Timestamp.fromDate(time),
      'period': period,
      'description': description,
      'icon': icon,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      dayNumber: data['dayNumber'] ?? 1,
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      period: data['period'] ?? 'Morning',
      description: data['description'],
      icon: data['icon'] ?? 'event',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Activity copyWith({
    String? id,
    String? tripId,
    int? dayNumber,
    String? title,
    String? location,
    DateTime? time,
    String? period,
    String? description,
    String? icon,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      dayNumber: dayNumber ?? this.dayNumber,
      title: title ?? this.title,
      location: location ?? this.location,
      time: time ?? this.time,
      period: period ?? this.period,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

