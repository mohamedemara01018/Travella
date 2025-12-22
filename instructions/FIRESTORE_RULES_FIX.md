# Fix: Apply Firestore Security Rules

The "Failed to add activity/expense/notes" error and "notes not saving" issue are caused by **Firestore security rules** not allowing writes.

## Quick Fix (Development)

Go to [Firebase Console](https://console.firebase.google.com/) and:

1. Select your project → **Firestore Database**
2. Click the **"Rules"** tab
3. Replace the entire content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // All authenticated users can read/write their own data
    match /trips/{tripId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.userId == request.auth.uid);
    }
    
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null;
    }
    
    match /activities/{activityId} {
      allow read, write: if request.auth != null;
    }
    
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.userId == request.auth.uid);
    }
  }
}
```

4. Click **"Publish"**

## The Rules Allow:

✅ Authenticated users can create/update activities  
✅ Authenticated users can create/update expenses  
✅ Authenticated users can create/update/delete notes (if owned by them)  
✅ Trips can only be accessed by their owner (userId)
✅ Favorites can be toggled for own trips
✅ Notes persist in database when userId is saved

## After Applying Rules:

1. Hot reload your Flutter app (`r` in terminal)
2. Try adding a note again - it should stay in the database
3. Try toggling favorites - it should save now
4. Try adding activities/expenses - they should work

## Why This Fixes The Problem:

1. **Trips require userId match** - Only the owner can modify trips and favorites
2. **Notes, activities, expenses require authentication** - Any authenticated user can create them
3. **userId is saved with notes** - Ensures proper data organization and future security rules

For production, add more validation rules for data types and required fields.

