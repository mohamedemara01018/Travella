# Firebase Database Setup Guide

This guide will help you set up Firebase Firestore database for your Wanderlust app.

## Prerequisites

- A Google account
- Flutter SDK installed
- Android Studio / VS Code with Flutter extensions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `wanderlust-app` (or your preferred name)
4. Disable Google Analytics (optional, you can enable later)
5. Click **"Create project"**
6. Wait for project creation to complete
7. Click **"Continue"**

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** (or **Add app** → **Android**)
2. Enter Android package name: `com.example.wanderly`
   - You can find this in `android/app/build.gradle.kts` under `applicationId`
3. Enter App nickname (optional): `Wanderlust Android`
4. Enter Debug signing certificate SHA-1 (optional for now)
5. Click **"Register app"**
6. Download `google-services.json` file
7. Place it in: `wanderly/android/app/google-services.json`

## Step 3: Add iOS App to Firebase (if developing for iOS)

1. In Firebase Console, click **"Add app"** → **iOS**
2. Enter iOS bundle ID: `com.example.wanderly`
   - You can find this in `ios/Runner/Info.plist` under `CFBundleIdentifier`
3. Enter App nickname (optional): `Wanderlust iOS`
4. Click **"Register app"**
5. Download `GoogleService-Info.plist` file
6. Place it in: `wanderly/ios/Runner/GoogleService-Info.plist`
7. Open `ios/Runner.xcworkspace` in Xcode
8. Right-click `Runner` folder → **Add Files to Runner**
9. Select `GoogleService-Info.plist`
10. Make sure "Copy items if needed" is checked

## Step 4: Configure Android Build Files

### Update `android/build.gradle.kts` (Project level)

Add this to the `plugins` block:
```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

### Update `android/app/build.gradle.kts`

Add at the top:
```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

Add in `dependencies`:
```kotlin
dependencies {
    // ... existing dependencies
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}
```

## Step 5: Configure iOS Build Files

### Update `ios/Podfile`

Make sure you have:
```ruby
platform :ios, '12.0'
```

Then run:
```bash
cd ios
pod install
cd ..
```

## Step 6: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **Email/Password**:
   - Click on **Email/Password**
   - Toggle **Enable**
   - Click **"Save"**

## Step 7: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
   - ⚠️ **Important**: Change security rules later for production!
4. Select a location (choose closest to your users)
5. Click **"Enable"**

## Step 8: Set Up Firestore Security Rules

1. In Firestore Database, go to **"Rules"** tab
2. Replace the rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /trips/{tripId} {
      allow read, write: if request.auth != null && 
        (resource == null || resource.data.userId == request.auth.uid);
      
      // Expenses, activities, and notes belong to trips
      match /expenses/{expenseId} {
        allow read, write: if request.auth != null;
      }
    }
    
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null && 
        resource.data.tripId != null;
    }
    
    match /activities/{activityId} {
      allow read, write: if request.auth != null && 
        resource.data.tripId != null;
    }
    
    match /notes/{noteId} {
      allow read, write: if request.auth != null && 
        resource.data.tripId != null;
    }
  }
}
```

3. Click **"Publish"**

## Step 9: Create Firestore Indexes (Optional but Recommended)

For better query performance, create these indexes:

1. Go to Firestore → **Indexes** tab
2. Click **"Create Index"**

**Index 1:**
- Collection: `trips`
- Fields:
  - `userId` (Ascending)
  - `isFavorite` (Ascending)
  - `createdAt` (Descending)

**Index 2:**
- Collection: `trips`
- Fields:
  - `userId` (Ascending)
  - `status` (Ascending)
  - `createdAt` (Descending)

**Index 3:**
- Collection: `activities`
- Fields:
  - `tripId` (Ascending)
  - `dayNumber` (Ascending)
  - `time` (Ascending)

**Index 4:**
- Collection: `notes`
- Fields:
  - `tripId` (Ascending)
  - `dayNumber` (Ascending)
  - `createdAt` (Descending)

## Step 10: Install Dependencies

Run in your terminal:
```bash
cd wanderly
flutter pub get
```

## Step 11: Verify Setup

1. Run the app: `flutter run`
2. Try to register a new account
3. Check Firebase Console → Authentication → Users (should see new user)
4. Create a trip in the app
5. Check Firestore Database → Data (should see `trips` collection)

## Troubleshooting

### Android Issues

**Error: "google-services.json not found"**
- Make sure `google-services.json` is in `android/app/` directory
- Clean and rebuild: `flutter clean && flutter pub get && flutter run`

**Error: "Default FirebaseApp is not initialized"**
- Make sure Firebase is initialized in `main.dart`
- Check that `google-services.json` is correctly placed

### iOS Issues

**Error: "GoogleService-Info.plist not found"**
- Make sure file is added to Xcode project
- Check file is in `ios/Runner/` directory

**Pod install errors**
- Run: `cd ios && pod deintegrate && pod install && cd ..`
- Make sure CocoaPods is updated: `sudo gem install cocoapods`

### General Issues

**Firebase not connecting**
- Check internet connection
- Verify Firebase project is active
- Check Firebase initialization in `main.dart`

**Authentication not working**
- Verify Email/Password is enabled in Firebase Console
- Check security rules allow authentication

## Database Structure

Your Firestore database will have these collections:

### `trips`
- Document ID: auto-generated
- Fields:
  - `userId` (string)
  - `title` (string)
  - `destination` (string)
  - `startDate` (timestamp)
  - `endDate` (timestamp)
  - `budget` (number)
  - `status` (string: 'draft', 'planned', 'active', 'completed')
  - `description` (string, optional)
  - `coverImageUrl` (string, optional)
  - `travelers` (array of strings)
  - `isFavorite` (boolean)
  - `createdAt` (timestamp)
  - `updatedAt` (timestamp, optional)

### `expenses`
- Document ID: auto-generated
- Fields:
  - `tripId` (string)
  - `title` (string)
  - `amount` (number)
  - `category` (string)
  - `date` (timestamp)
  - `description` (string, optional)
  - `createdAt` (timestamp)

### `activities`
- Document ID: auto-generated
- Fields:
  - `tripId` (string)
  - `dayNumber` (number)
  - `title` (string)
  - `location` (string)
  - `time` (timestamp)
  - `period` (string)
  - `description` (string, optional)
  - `icon` (string)
  - `createdAt` (timestamp)

### `notes`
- Document ID: auto-generated
- Fields:
  - `tripId` (string)
  - `dayNumber` (number)
  - `title` (string)
  - `content` (string)
  - `category` (string)
  - `createdAt` (timestamp)
  - `updatedAt` (timestamp, optional)

## Next Steps

1. Test all CRUD operations (Create, Read, Update, Delete)
2. Test authentication flow
3. Test data synchronization across devices
4. Set up proper security rules for production
5. Consider adding cloud functions for advanced features

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules (remove test mode)
- [ ] Enable App Check for additional security
- [ ] Set up proper error handling
- [ ] Add data validation
- [ ] Set up backup strategy
- [ ] Monitor usage and costs
- [ ] Add analytics events
- [ ] Test on real devices

## Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Check Flutter console for runtime errors
3. Review Firebase documentation: https://firebase.google.com/docs
4. Check FlutterFire documentation: https://firebase.flutter.dev/

