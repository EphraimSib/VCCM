rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }

    // Cards collection
    match /cards/{cardId} {
      allow read, write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
