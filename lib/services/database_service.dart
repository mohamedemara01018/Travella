import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../models/activity.dart';
import '../models/note.dart';
import '../models/user_profile.dart'; // IMPORTED USER PROFILE MODEL

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // ====================================================
  //               USER PROFILE (NEW)
  // ====================================================

  // STREAM: Get User Profile Data
  // Listens to the 'users' collection for real-time updates
  Stream<UserProfile?> getUserProfile() {
    if (userId == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return UserProfile.fromMap(snapshot.data()!, snapshot.id);
          }
          // If no profile document exists (new user), return null
          return null; 
        });
  }

  // UPDATE: Save specific fields (Name, Bio, Phone, etc.)
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (userId == null) return;
    
    try {
      // SetOptions(merge: true) ensures we update fields without deleting others
      await _firestore.collection('users').doc(userId).set(
        data,
        SetOptions(merge: true), 
      );
      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // ====================================================
  //                     TRIPS
  // ====================================================
  
  // Get all trips for current user
  Stream<List<Trip>> getTrips() {
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromFirestore(doc))
            .toList());
  }

  // Get trips by status
  Stream<List<Trip>> getTripsByStatus(String status) {
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromFirestore(doc))
            .toList());
  }

  // Get favorite trips
  Stream<List<Trip>> getFavoriteTrips() {
    if (userId == null) return Stream.value([]);
    
    return _firestore
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Trip.fromFirestore(doc))
            .toList());
  }

  // Get single trip (as Stream for real-time updates)
  Stream<Trip?> getTrip(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return Trip.fromFirestore(doc);
      }
      return null;
    });
  }

  // Create trip
  Future<String?> createTrip(Trip trip) async {
    if (userId == null) return null;
    
    try {
      final tripData = trip.toFirestore();
      tripData['userId'] = userId;
      
      final docRef = await _firestore.collection('trips').add(tripData);
      return docRef.id;
    } catch (e) {
      print('Error creating trip: $e');
      return null;
    }
  }

  // Update trip
  Future<bool> updateTrip(Trip trip) async {
    try {
      final tripData = trip.toFirestore();
      tripData['updatedAt'] = Timestamp.now();
      
      await _firestore.collection('trips').doc(trip.id).update(tripData);
      return true;
    } catch (e) {
      print('Error updating trip: $e');
      return false;
    }
  }

  // Delete trip
  Future<bool> deleteTrip(String tripId) async {
    try {
      // Delete related expenses, activities, and notes
      await deleteExpensesByTrip(tripId);
      await deleteActivitiesByTrip(tripId);
      await deleteNotesByTrip(tripId);
      
      // Delete trip
      await _firestore.collection('trips').doc(tripId).delete();
      return true;
    } catch (e) {
      print('Error deleting trip: $e');
      return false;
    }
  }

  // Toggle favorite
  Future<bool> toggleFavorite(String tripId, bool isFavorite) async {
    try {
      print('Toggling favorite for trip $tripId to $isFavorite');
      await _firestore.collection('trips').doc(tripId).update({
        'isFavorite': isFavorite,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Favorite toggled successfully');
      return true;
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      rethrow;
    }
  }

  // ====================================================
  //                    EXPENSES
  // ====================================================

  // Get expenses for a trip
  Stream<List<Expense>> getExpenses(String tripId) {
    return _firestore
        .collection('expenses')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromFirestore(doc))
            .toList());
  }

  // Create expense
  Future<String?> createExpense(Expense expense) async {
    try {
      print('Creating expense with tripId: ${expense.tripId}');
      final expenseData = expense.toFirestore();
      expenseData['userId'] = userId;
      final docRef = await _firestore.collection('expenses').add(expenseData);
      print('✅ Expense created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating expense: $e');
      rethrow;
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    try {
      await _firestore.collection('expenses').doc(expense.id).update(expense.toFirestore());
      return true;
    } catch (e) {
      print('Error updating expense: $e');
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
      return true;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  // Delete all expenses for a trip
  Future<void> deleteExpensesByTrip(String tripId) async {
    final expenses = await _firestore
        .collection('expenses')
        .where('tripId', isEqualTo: tripId)
        .get();
    
    for (var doc in expenses.docs) {
      await doc.reference.delete();
    }
  }

  // Get total expenses for a trip
  Future<double> getTotalExpenses(String tripId) async {
    try {
      final expenses = await _firestore
          .collection('expenses')
          .where('tripId', isEqualTo: tripId)
          .get();
      
      double total = 0;
      for (var doc in expenses.docs) {
        final expense = Expense.fromFirestore(doc);
        total += expense.amount;
      }
      return total;
    } catch (e) {
      print('Error getting total expenses: $e');
      return 0.0;
    }
  }

  // ====================================================
  //                   ACTIVITIES
  // ====================================================

  // Get activities for a trip
  Stream<List<Activity>> getActivities(String tripId) {
    return _firestore
        .collection('activities')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Activity.fromFirestore(doc))
            .toList());
  }

  // Get activities for a specific day
  Stream<List<Activity>> getActivitiesByDay(String tripId, int dayNumber) {
    return _firestore
        .collection('activities')
        .where('tripId', isEqualTo: tripId)
        .where('dayNumber', isEqualTo: dayNumber)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Activity.fromFirestore(doc))
            .toList());
  }

  // Create activity
  Future<String?> createActivity(Activity activity) async {
    try {
      print('Creating activity with tripId: ${activity.tripId}');
      final activityData = activity.toFirestore();
      activityData['userId'] = userId;
      final docRef = await _firestore.collection('activities').add(activityData);
      print('✅ Activity created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating activity: $e');
      rethrow;
    }
  }

  // Update activity
  Future<bool> updateActivity(Activity activity) async {
    try {
      await _firestore.collection('activities').doc(activity.id).update(activity.toFirestore());
      return true;
    } catch (e) {
      print('Error updating activity: $e');
      return false;
    }
  }

  // Delete activity
  Future<bool> deleteActivity(String activityId) async {
    try {
      await _firestore.collection('activities').doc(activityId).delete();
      return true;
    } catch (e) {
      print('Error deleting activity: $e');
      return false;
    }
  }

  // Delete all activities for a trip
  Future<void> deleteActivitiesByTrip(String tripId) async {
    final activities = await _firestore
        .collection('activities')
        .where('tripId', isEqualTo: tripId)
        .get();
    
    for (var doc in activities.docs) {
      await doc.reference.delete();
    }
  }

  // ====================================================
  //                      NOTES
  // ====================================================

  // Get notes for a trip
  Stream<List<Note>> getNotes(String tripId) {
    return _firestore
        .collection('notes')
        .where('tripId', isEqualTo: tripId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromFirestore(doc))
            .toList());
  }

  // Get notes for a specific day
  Stream<List<Note>> getNotesByDay(String tripId, int dayNumber) {
    return _firestore
        .collection('notes')
        .where('tripId', isEqualTo: tripId)
        .where('dayNumber', isEqualTo: dayNumber)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromFirestore(doc))
            .toList());
  }

  // Create note
  Future<String?> createNote(Note note) async {
    try {
      print('Creating note with tripId: ${note.tripId}');
      final noteData = note.toFirestore();
      noteData['userId'] = userId;
      final docRef = await _firestore.collection('notes').add(noteData);
      print('✅ Note created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating note: $e');
      rethrow;
    }
  }

  // Update note
  Future<bool> updateNote(Note note) async {
    try {
      print('Updating note ${note.id}');
      final noteData = note.toFirestore();
      noteData['userId'] = userId;
      noteData['updatedAt'] = Timestamp.now();
      
      await _firestore.collection('notes').doc(note.id).update(noteData);
      print('✅ Note updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating note: $e');
      rethrow;
    }
  }

  // Delete note
  Future<bool> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();
      return true;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  // Delete all notes for a trip
  Future<void> deleteNotesByTrip(String tripId) async {
    final notes = await _firestore
        .collection('notes')
        .where('tripId', isEqualTo: tripId)
        .get();
    
    for (var doc in notes.docs) {
      await doc.reference.delete();
    }
  }
}