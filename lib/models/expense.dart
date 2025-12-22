import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String category; // 'Transport', 'Accommodation', 'Food', 'Activities', 'Shopping', 'Other'
  final DateTime date;
  final String? description;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'tripId': tripId,
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      tripId: data['tripId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'Other',
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

