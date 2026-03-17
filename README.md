# 💬 Uzii Chat

<p align="center">
  <img src="assets/images/splash_logo.png" width="120" alt="Uzii Chat Logo"/>
</p>

<p align="center">
  <strong>A premium real-time chat app built with Flutter & Firebase</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge"/>
</p>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 💬 Real-time Messaging | Instant messages powered by Firestore |
| 📸 Media Sharing | Send photos, videos & documents |
| 🎵 Voice Messages | Record & send voice notes |
| 🔔 Push Notifications | FCM-powered notifications |
| ⭕ Status / Stories | 24-hour disappearing stories |
| ✍️ Typing Indicator | Real-time typing status |
| ↩️ Message Reply | Swipe to reply to any message |
| 📌 Pin Messages | Pin important messages |
| 😂 Reactions | React to messages with emojis |
| 🌙 Dark Mode | Full dark & light theme support |
| 🟢 Online Status | Real-time online/offline indicator |
| 🕐 Last Seen | Last seen time display |
| 🔒 Block / Unblock | Block unwanted users |
| 🗑️ Delete Messages | Delete for me or everyone |
| 🔍 Search | Search conversations |
| 📱 Hero Animation | Smooth profile picture animations |

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.x
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Media Storage:** Cloudinary
- **State Management:** Provider
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Local Auth:** Firebase Authentication
- **Font:** Inter

---

## 📦 Packages Used

```yaml
firebase_core, firebase_auth, cloud_firestore,
firebase_storage, firebase_messaging,
provider, cached_network_image,
image_picker, file_picker,
flutter_sound, just_audio,
cloudinary_public, uuid,
permission_handler, flutter_native_splash,
scroll_to_index, intl
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Firebase project
- Cloudinary account

### Installation

```bash
# Clone the repo
git clone https://github.com/uziii949/uzii-chat.git

# Go to project folder
cd uzii-chat

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android & iOS apps
3. Download `google-services.json` → place in `android/app/`
4. Enable **Authentication** (Email/Password + Google)
5. Enable **Firestore Database**
6. Enable **Firebase Storage**
7. Enable **Firebase Cloud Messaging**

### Cloudinary Setup

1. Create account at [cloudinary.com](https://cloudinary.com)
2. Get your **Cloud Name**
3. Create an **Upload Preset**
4. Update in `lib/providers/status_provider.dart` and `lib/services/storage_service.dart`

---

## 📁 Project Structure

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
│   ├── auth/        # Login, Register, Forgot Password
│   ├── chat/        # Home, Chat Screen
│   ├── profile/     # Profile Screen
│   ├── status/      # Stories/Status
│   ├── call/        # Call Screen
│   └── about/       # About Screen
├── services/        # Firebase & Storage services
├── theme/           # Colors, Text styles, Theme
├── utils/           # Constants, Routes
└── widgets/         # Reusable widgets
```

---

## 🔐 Firebase Security Rules

### Firestore
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    match /statuses/{statusId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null;
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 👨‍💻 Developer

**Uzair Khan**
- GitHub: [@uziii949](https://github.com/uziii949)
- Location: Pakistan 🇵🇰

---

## 📄 License

This project is for portfolio purposes.

---

<p align="center">Made with ❤️ by Uzair Khan</p>
