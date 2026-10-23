# SmartProductive

A productivity-focused Android application designed to help users manage tasks, build better focus habits, track progress, and stay motivated through gamification and AI-assisted suggestions.

> **Project type:** Academic project  
> **Platform:** Android  
> **Framework:** Flutter  
> **Language:** Dart

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Application Modules](#application-modules)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Setup and Installation](#setup-and-installation)
- [Configuration](#configuration)
- [Build an APK](#build-an-apk)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Limitations](#limitations)
- [Future Enhancements](#future-enhancements)
- [Disclaimer](#disclaimer)

## Overview

SmartProductive combines task management, focus-time tracking, rewards, productivity reports, hobby development, and AI-assisted recommendations in one mobile application. Its goal is to make productive routines easier to follow by pairing practical planning tools with motivational features.

The application was developed for academic demonstration and evaluation. It is not currently presented as a production-ready public service.

## Features

- **User authentication:** Sign-up and login using Firebase Authentication.
- **Task management:** Create and manage personal tasks.
- **Focus timer:** Run timed focus sessions for study or other activities.
- **Coin rewards:** Earn coins for focus sessions and use them to unlock eligible items in the in-app store.
- **Productivity reports:** Review focus history and visual summaries of productivity.
- **AI-assisted suggestions:** Get activity or task suggestions through the configured AI integration.
- **Prod Buddy:** A chat-style assistant interface for productivity-related guidance.
- **Articles:** Browse productivity-related articles and resources.
- **Focus music store:** View and unlock available focus music using the app's reward system.
- **Notifications:** Configure local focus reminders, subject to device notification permissions and Android settings.
- **Settings and information:** Access About Us, Help & Support, and Social Media information.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application framework and UI |
| Dart | Application programming language |
| Firebase Authentication | User registration and sign-in |
| Cloud Firestore | Cloud database for supported app data |
| LLaMA 3 through Groq API | AI-powered suggestions, if configured in the current build |
| `flutter_local_notifications` | Local notifications |
| `timezone` | Time-zone-aware notification scheduling |
| Google Fonts | Typography and UI styling |
| Cloudinary | Media storage/delivery, if configured in the current build |
| Android Studio | Development and Android testing |

> Keep this list aligned with the packages and services actually enabled in your version of the project. For example, only list Cloudinary or an AI provider if the app is configured to use it.

## Application Modules

### 1. Authentication
Allows users to register and log in. Firebase Authentication handles supported authentication operations.

### 2. Task Management
Provides a place to create and organize tasks so users can keep track of activities they want to complete.

### 3. Focus Timer
Helps users dedicate a set period to a selected task or activity.

### 4. Rewards and Store
Awards coins according to the application's implemented reward logic. Users can spend eligible coins to unlock available store items, such as focus music.

### 5. Reports
Displays available focus-session history and productivity summaries to help users review their activity.

### 6. AI Suggestions and Prod Buddy
Provides AI-assisted activity recommendations and a chat-style interface when the required API configuration and network connection are available.

### 7. Articles
Presents productivity-related reading material from the content source configured in the application.

### 8. Notifications
Allows users to opt in to focus reminders. Notifications depend on permission being granted and the device's notification and battery settings.

### 9. Settings and Support
Contains app information, About Us, Help & Support, and Social Media sections.

## Architecture

The app's code is organized around Flutter screens and reusable widgets, with Firebase and external services providing backend capabilities. If the current codebase follows MVVM, the main responsibilities can be described as:

- **View:** Flutter screens and widgets.
- **ViewModel / state management:** UI state and application logic.
- **Model:** Data structures for tasks, users, sessions, and related records.
- **Services / repositories:** Firebase and external API interactions.

Adjust this section if your implemented architecture or state-management package differs.

## Prerequisites

Install the following before running the project:

- Flutter SDK compatible with the project
- Dart SDK included with Flutter
- Android Studio or another supported Flutter IDE
- Android SDK and an emulator or Android device
- A Firebase project configured for the Android application
- API credentials for any optional external AI or media service used by the current build

Check your Flutter installation:

```bash
flutter doctor
```

## Setup and Installation

1. **Clone the repository**

   ```bash
   git clone <YOUR_REPOSITORY_URL>
   cd <YOUR_PROJECT_DIRECTORY>
   ```

   Replace the placeholders with your repository URL and project directory.

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   Set up a Firebase project and register the Android app using the correct Android application ID. Generate or configure the Firebase options file required by the project (commonly `lib/firebase_options.dart`) using the FlutterFire setup appropriate to your environment.

4. **Configure external services**

   Add any required AI or media-service configuration using a secure approach. Do not commit private API keys or service credentials to a public repository.

5. **Run the app**

   ```bash
   flutter run
   ```

## Configuration

### Firebase

- Enable the Firebase Authentication providers used by the app.
- Create and configure Cloud Firestore if the application uses it.
- Set Firestore Security Rules so each authenticated user can only access data they are authorized to access.
- Keep Firebase configuration aligned with the Android application ID.

### AI and media APIs

If the application uses Groq/LLaMA or Cloudinary, provide the required configuration through an appropriate local or server-side configuration method. Avoid hard-coding secret API keys in the Flutter client, because client-side values can be extracted from the application package.

### Local notifications

For Android versions that require runtime notification permission, request permission before scheduling notifications. Verify that the required permissions and plugin configuration are present in the Android project. Test notification behavior on the Android versions and devices you intend to support.

## Build an APK

To build a release APK for academic demonstration:

```bash
flutter build apk --release
```

The APK is normally generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Install it on a compatible Android device and verify that Firebase configuration, authentication, network-dependent features, and notification permissions work as expected.

## Testing

The application can be checked using the following testing levels and approaches:

- **Unit testing:** Test individual functions and business logic, such as reward calculations.
- **Widget testing:** Test individual Flutter widgets and screen behavior.
- **Integration testing:** Verify interactions between the UI, Firebase, notifications, and configured APIs.
- **System testing:** Test the complete application workflow across its modules.
- **Regression testing:** Re-test existing functionality after code or UI changes.
- **Manual testing:** Check navigation, validation, error messages, and behavior on an Android device.

Only describe tests as completed when they have actually been run.

## Project Structure

The exact structure depends on the current codebase. A typical Flutter layout may look like this:

```text
lib/
├── main.dart
├── Article_page/
├── drawer_page/
├── home_page/
├── notifications_page/
├── prod_buddy/
├── settings_page/
├── task_page/
├── user_details/
└── ...
```

Use the actual directory names from your repository when updating this section.

## Limitations

- Some features require an active internet connection, including Firebase synchronization and external API requests.
- AI suggestions depend on the configured provider, network availability, and API limits.
- Local notifications may be affected by permission settings, battery optimization, and Android-version behavior.
- The app is an academic prototype and may need additional security review, accessibility checks, automated tests, and production hardening before public release.

## Future Enhancements

- More personalized recommendations using focus history and user preferences.
- Advanced report filters and productivity trend analysis.
- Offline task access and improved synchronization.
- Additional rewards, themes, and store items.
- Optional integrations with calendars and other productivity tools.
- Expanded accessibility, automated testing, and production deployment readiness.

## Disclaimer

SmartProductive was developed for academic learning and demonstration. Product names and third-party services are referenced only to describe the technologies that may be used by the project. External services are subject to their own terms, availability, and usage limits.

## Author

**Project:** SmartProductive  
**Developer:** <YOUR_NAME>  
**Institution:** <YOUR_COLLEGE_OR_INSTITUTION>

Replace the placeholders above with your details before publishing the README.
