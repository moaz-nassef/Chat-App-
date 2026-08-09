<div align="center">

# 💬 Chat App

> **A real‑time messenger with an AI brain — chat with friends, or with an AI assistant that remembers your conversation.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter&logoColor=white&color=02569B)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white&color=0175C2)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black&color=FFCA28)](https://firebase.google.com)
[![Firebase AI](https://img.shields.io/badge/Firebase%20AI-Gemini%202.5-violet?style=for-the-badge&logo=google&logoColor=white)]
[![State](https://img.shields.io/badge/State-BLoC%20%2F%20Cubit-purple?style=for-the-badge&color=9C27B0)](https://pub.dev/packages/flutter_bloc)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge&color=43A047)]()

</div>

---

## 🚀 What is Chat App?

A complete **private chat application** — built like **WhatsApp / Messenger** — with a unique twist: **an AI assistant lives right inside your chat list**.

Powered by **Flutter + Firebase**, it delivers:

- 🔐 **Email/password authentication** with a smart auth gate (no manual navigation)
- 💬 **Real‑time 1:1 conversations** over Cloud Firestore streams
- 🟢 **Live presence** — online / offline / last‑seen, synced with the app lifecycle
- 🤖 **A built‑in AI assistant** (Firebase AI / Gemini) that remembers context per chat
- 🔌 **Bring your own AI** — connect OpenAI, Claude, DeepSeek, Grok, OpenRouter or any custom provider
- 🌓 **Light & dark themes** with a beautiful purple→blue identity
- ✨ **Buttery animations** — staggered entrances, pulsing logo, animated bubbles

---

## ✨ Why it feels special

| Area | What was built |
|---|---|
| 🧠 **Per‑chat AI memory** | Each conversation has its own history (24 messages kept), so the assistant truly follows the conversation — in both built‑in and custom mode. |
| 🎛️ **7 AI providers** | Gemini, OpenRouter, OpenAI, Claude, DeepSeek, Grok & Custom — each with its own wire protocol (OpenAI‑compatible / Gemini native / Anthropic native). |
| 🧪 **Live connection test** | Press "Test connection" to ping any provider and **measure latency** before you save — no more guessing. |
| ⚡ **Atomic batches** | Sending a message updates the chat, writes the message, and increments the receiver's unread counter **in a single Firestore batch**. |
| 🔒 **Real security rules** | Only conversation participants can read/write; the AI writes as `ai_agent` through a dedicated rule. |
| 🪶 **RTL + Arabic UX** | Arabic‑first UI, right‑to‑left layout, and error messages mapped from error codes to friendly Arabic. |

---

## 🌟 Features

### 🔐 Authentication
- **Sign up / Sign in / Log out** with Firebase Auth (email + password).
- **Password reset** — forgotten passwords, solved.
- **AuthGate** — the root automatically swaps between *Welcome* and *Chats* based on the auth stream. No manual navigation after login/logout.
- Smart validators: email format, min‑length password, confirm‑password match, display name.

### 💬 Real‑time Private Chat
- **Deterministic chat IDs** — both users always compute the same room (`sorted_uid1_uid2`), so the conversation is unique and stable.
- Live message streams (newest first, `reverse: true` for performance).
- **Read receipts** — ✓ sent / ✓✓ read (blue) right inside the bubble.
- **Unread badges** — `FieldValue.increment(1)` per message, auto‑reset when you open the chat.
- **Delete messages** (long‑press yours) & **delete whole chats** (atomic batch — messages + document).

### 🟢 Presence & Last Seen
- `PresenceService` listens to **both** the auth session **and** the app lifecycle (foreground ⇄ background).
- Fixes the classic cold‑start bug — a restored session comes **online immediately**.
- Live *Online* / *Last seen 14:05* in the chat AppBar via a user stream.

### 🤖 AI Assistant
- **Built‑in Gemini** — zero configuration, works out of the box.
- **Custom providers** — paste an API key, pick a model, hit **Test connection** (with latency), save.
- Per‑chat conversation memory in both modes (with a rolling 24‑message window).
- **AI typing indicator** — animated dots while the model thinks.
- The AI is a **real participant** (`ai_agent`), so it gets its own bubble, unread badge and thread.

### 👥 Users Directory
- Browse every registered user.
- **Instant search** by name or email.
- Start a private conversation with one tap.

### 🔎 Search
- Search inside your chats list (filters titles, last message & users).
- Shared, reusable `SearchTextField` — the filtering lives in the state, not in the build.

### 🌓 Themes
- **Light / Dark / System** modes via `ThemeCubit`, persisted in `SharedPreferences`.
- Full Material 3 palette for both schemes, sharing the same brand identity.
- **Purple → blue gradient** across headers, CTAs, avatars and the AI.

### ✨ Motion & Polish
- `AnimatedEntrance` — staggered fade‑up sequences on auth screens.
- Pulsing, glowing logo with a gradient ShaderMask.
- Press‑scale gradient CTA buttons.
- Animated chat bubbles with rounded asymmetric corners & soft shadows.

---

## 🧱 Tech Stack

| Technology | Why |
|---|---|
| [Flutter](https://flutter.dev) | One codebase for Android / iOS / Web / Desktop |
| [Firebase Auth](https://firebase.google.com/docs/auth) | Email + password authentication |
| [Cloud Firestore](https://firebase.google.com/docs/firestore) | Real‑time chat & presence data |
| [Firebase AI Logic](https://firebase.google.com/docs/ai) | Built‑in Gemini assistant |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Predictable state management (Cubits) |
| [get_it](https://pub.dev/packages/get_it) | Service locator / DI |
| [equatable](https://pub.dev/packages/equatable) | Value‑based model/state equality |
| [http](https://pub.dev/packages/http) | Direct calls to custom AI providers |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | Persisted theme & AI settings |
| [flutter_svg](https://pub.dev/packages/flutter_svg) | SVG icons & illustrations |
| Courgette | Handwritten‑style accent font |

---

## 🧬 Architecture

**Feature‑first Clean Architecture** — every feature is a self‑contained folder you can lift into another project:

```
lib/
├── main.dart                     # Firebase bootstrap + DI wiring
├── app.dart                      # Theme + Router + PresenceService
├── firebase_options.dart         # Firebase platform config
├── core/
│   ├── constants/                # Colors, AI constants, Firestore paths
│   ├── di_container.dart         # GetIt registrations
│   ├── errors/failure.dart       # Sealed Failure → Arabic messages
│   ├── router/app_router.dart    # Typed routes (ChatViewArgs)
│   ├── services/                 # PresenceService (lifecycle)
│   ├── theme/                    # AppTheme + ThemeCubit
│   └── utils/                    # Validators + date formatter
├── features/
│   ├── auth/                     # Cubit + datasource + repo + views
│   ├── ai_chat/                  # AI settings, providers & gateway
│   ├── chats/                    # Chat list (cubit + tiles)
│   ├── chat_detail/              # Messages (cubit, repo, chat view)
│   └── users/                    # Users directory
└── shared/widgets/               # Bubble, avatar, search, empty state, snack
```

**Key design decisions:**

- 🧩 **Repos only → Cubits** — no cubit ever depends on another cubit; views pass the `uid`.
- 📡 **Realtime via streams** — every realtime cubit owns its `StreamSubscription`, cancels the old one before re‑subscribing, and cancels in `close()`.
- 📍 **`FirestorePaths`** — every collection/field name lives in one file.
- ❌ **`Failure` sealed class** — Firebase error codes mapped to friendly Arabic messages.
- 🧰 **`ChatViewArgs` typed** — no more `Map` arguments in routes.
- 🛡 **No Firebase imports in views** — the UI only reads from cubits.

---

## 🔒 Firestore Security

Ship‑ready rules included in the repo:

- Users: readable by any signed‑in user, writable only by the owner.
- Chats & messages: **only participants** can read/write.
- AI: a dedicated rule lets the `ai_agent` sender write into AI chats.
- Composite indexes for unread messages & sorted chat lists included (`firestore.indexes.json`).

---

## ✅ Getting Started

### Prerequisites

- 🦋 Flutter SDK `>= 3.7`
- 🔥 A Firebase project (free tier is fine)

### 1️⃣ Configure Firebase

```bash
# Activate the FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate firebase_options.dart for your project
flutterfire configure
```

Enable **Email/Password** in Firebase Auth, create a **Firestore** database, then deploy the included rules & indexes:

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 2️⃣ Run the app

```bash
flutter pub get
flutter run
```

### 3️⃣ Connect your own AI (optional)

1. Open the **AI chat** → tap the gear icon ⚙️
2. Toggle "Use custom provider"
3. Pick a provider, paste your **API key**, choose a **model**
4. Hit **Test connection** — watch the latency ⏱️
5. Save and start chatting with *your* model 🚀

> Default behaviour needs **zero setup** — the built‑in Gemini assistant just works.

---

## 🧪 Tests

```bash
flutter test
```

- ✅ `Validators` — email / password / confirm‑password / display name
- ✅ `DateFormatter` — HH:mm, today, Yesterday, full date

---

## 🗺️ Roadmap

- [x] Email/password auth + password reset
- [x] Private real‑time chat with presence & last seen
- [x] Read receipts + real unread badges
- [x] Built‑in Gemini AI assistant
- [x] 7 custom AI providers + latency test
- [x] Light / dark / system themes
- [x] Search (chats + users) & delete (message / chat)
- [ ] 🖼️ Image & file sharing
- [ ] 🎙️ Voice messages
- [ ] 🔔 Push notifications (FCM)

---

## 🤝 Contributing

Contributions are always welcome! 🎉

1. 🍴 Fork the repo
2. 🌿 Create your branch (`git checkout -b feature/amazing`)
3. 💾 Commit (`git commit -m 'Add amazing thing'`)
4. 📤 Push (`git push origin feature/amazing`)
5. 🔀 Open a Pull Request

---

## 🧑‍💻 Author

**Moaz Nassef** — [GitHub](https://github.com/moaz-nassef)

---

<div align="center">

Made with 💜 using Flutter, Firebase & AI

⭐ **If you like it, please star the repo!** ⭐

</div>