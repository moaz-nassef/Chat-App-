<div align="center">

# 💬 Chat App

**A real‑time chat application with Firebase & a built‑in AI assistant.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter&logoColor=white&color=02569B)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white&color=02569B)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Realtime-FFCA28?style=for-the-badge&logo=firebase&logoColor=black&color=FFCA28)](https://firebase.google.com)
[![AI](https://img.shields.io/badge/AI-Gemini%20%7C%20Any%20Provider-violet?style=for-the-badge&logo=google&logoColor=white)]
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ About the Project

**Chat App** is a complete **real‑time messaging application** built with **Flutter + Firebase**. It combines:

- 👥 **One‑to‑one chat** with live presence (who's online right now)
- 🤖 **A built‑in AI assistant** powered by **Gemini (Firebase AI Logic)** — with support for **any custom provider** (OpenAI, OpenRouter, DeepSeek, xAI, Anthropic…)
- 🔐 **Full authentication** with email/password
- 🌓 **Light & dark themes** with an elegant touch

Messages stream live through **Cloud Firestore**, presence syncs across app lifecycle, and the AI assistant remembers conversation context — giving users a premium messenger experience with AI superpowers.

---

## 🚀 Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Sign up / log in with Firebase Auth (email + password) |
| 💬 **Real‑time Chat** | Live messages via Cloud Firestore with typing & unread badges |
| 🟢 **Presence** | Online/offline status synced with login & app lifecycle |
| 🤖 **AI Assistant** | Built‑in chat with Gemini + per‑chat conversation memory |
| ⚙️ **Custom AI Providers** | Connect OpenAI‑style, Gemini‑native or Anthropic endpoints |
| 🧪 **Provider Test** | Test any AI provider and measure latency before using it |
| 👥 **Users Directory** | Browse registered users & start conversations |
| 🔎 **Search** | Find chats & users instantly |
| 🌓 **Theme Toggle** | Switch between beautiful light & dark themes |
| 🎨 **Courgette Font** | Handwritten‑style accent typography |

---

## 🧱 Tech Stack

<div align="center">

| 🛠️ Tool | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross‑platform UI framework |
| [Firebase Auth](https://firebase.google.com/docs/auth) | User authentication |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Realtime data & chat storage |
| [Firebase AI Logic](https://firebase.google.com/docs/ai) | Gemini‑powered AI assistant |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Predictable state management |
| [get_it](https://pub.dev/packages/get_it) | Service locator & DI |
| [equatable](https://pub.dev/packages/equatable) | Value‑based state comparison |
| [flutter_svg](https://pub.dev/packages/flutter_svg) | SVG icons & illustrations |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Local settings persistence |

</div>

---

## 📂 Project Structure

```
lib/
├── main.dart                    # Firebase bootstrap
├── app.dart                     # Root widget: DI + theme + presence
├── firebase_options.dart        # Firebase platform config
├── core/
│   ├── constants/               # AI constants & Firestore paths
│   ├── di_container.dart        # Dependency injection
│   ├── errors/                  # Failure model
│   ├── router/                  # Named routing
│   ├── services/                # Presence service
│   ├── theme/                   # Theme + theme cubit
│   └── utils/                   # Date formatting & validators
├── features/
│   ├── auth/                    # Auth cubit, datasource, repo & views
│   ├── ai_chat/                 # AI settings + provider abstraction
│   ├── chats/                   # Chats list (cubit + view)
│   ├── chat_detail/             # Messages (cubit, repo, chat view)
│   └── users/                   # Users directory
└── shared/
    └── widgets/                 # Chat bubbles, avatars, empty states
```

---

## ✅ Getting Started

### Prerequisites
- 🦋 **Flutter SDK** `>= 3.7`
- 🔥 A **Firebase project** (free tier)

### 1️⃣ Setup Firebase

```bash
# Install the FlutterFire CLI
dart pub global activate flutterfire_cli

# From the project root — generates firebase_options.dart
flutterfire configure
```

Enable **Email/Password** sign‑in in your Firebase console, then create a **Firestore database** and upload the included rules:

```
firestore.rules          → Firebase → Firestore → Rules
firestore.indexes.json   → Firebase → Firestore → Indexes
```

### 2️⃣ Run the app

```bash
# Install dependencies
flutter pub get

# Run
flutter run
```

### ✨ Optional — connect a custom AI provider

1. Open **AI Settings** inside the app
2. Choose your provider (OpenAI / OpenRouter / DeepSeek / xAI / Anthropic / Custom)
3. Paste your **API key** & model name
4. Tap **Test connection** — it measures the latency before you start chatting 🚀

> By default the app ships with the **built‑in Gemini assistant** — no key needed for the fallback demo.

---

## 🧭 Roadmap

- [x] Email/password auth
- [x] Realtime one‑to‑one chat with presence
- [x] Unread badges & search
- [x] Built‑in Gemini AI assistant
- [x] Custom AI provider support + latency test
- [ ] 🖼️ Image & file sharing
- [ ] 🎙️ Voice messages
- [ ] 🔔 Push notifications (FCM)

---

## 🤝 Contributing

Contributions are always welcome! 🎉

1. 🍴 Fork the repository
2. 🌿 Create your feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add some amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔀 Open a Pull Request

---

## 📞 Contact

**Moaz Nassef** — [GitHub](https://github.com/moaz-nassef)

---

<div align="center">

Made with 💜 using Flutter, Firebase & AI

⭐ **Don't forget to star this repo if you like it!** ⭐

</div>