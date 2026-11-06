# Task 2 - Offline To-Do List App 

An offline-first, production-grade **Flutter To-Do List Application** built as part of the **Auspify Technologies Practical Training Program**. Engineered with **Clean Architecture**, **Cubit (BLoC)** state management, and local **Hive NoSQL** storage for instantaneous, zero-latency task management.

---

##  Key Features

- **Full CRUD Operations:** Seamlessly Create, Read, Update, and Delete tasks.
- **Advanced Task Properties:**
  - Dynamic Priority classification (**Low**, **Medium**, **High**) with distinct visual badges.
  - Due Date & Due Time scheduling with native Material date and time pickers.
  - Interactive squircle check states with completion animations.
- **Productivity & Velocity Dashboard:**
  - Real-time task completion rate (`% velocity`).
  - Progress tracker showing completed vs. pending tasks.
  - Multi-criteria filter tabs (**All Tasks**, **Pending**, **Completed**).
- **Persistent Theme Management:**
  - Seamless toggle between **Light Mode** and **Dark Mode**.
  - Local persistence via Hive `settings_box` ensuring preferences remain across app restarts.
- **Bottom Navigation Bar:**
  - Switch between **Today**, **Agenda**, **Lists**, and **Insights**.
  - **Insights View:** Detailed task analytics, completion velocity breakdown, and priority distributions.
- **100% Offline-First:**
  - Pure local persistence via Hive NoSQL.
  - Zero cloud dependencies or Firebase requirements.

---

##  Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Dart 3)
- **Architecture:** Clean Architecture (Domain, Data, Presentation layers)
- **State Management:** [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Cubit)
- **Local Persistence:** [hive](https://pub.dev/packages/hive) & [hive_flutter](https://pub.dev/packages/hive_flutter) (TypeAdapter generated via `build_runner`)
- **Utilities:**
  - [intl](https://pub.dev/packages/intl) (Date and time formatting)
  - [uuid](https://pub.dev/packages/uuid) (Unique ID generation)
  - [equatable](https://pub.dev/packages/equatable) (Value equality)

---

##  Project Structure

```
lib/
├── core/
│   ├── constants/       # AppColors, AppConstants (Hive box keys)
│   ├── errors/          # Failures & Exceptions
│   ├── theme/           # Light & Dark ThemeData (Stitch design system)
│   └── utils/           # DateFormatter, Result<T> functional container
├── features/
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── datasources/   # TaskLocalDataSource (Hive CRUD operations)
│   │   │   ├── models/        # TaskModel & TaskModelAdapter (Hive TypeId 0)
│   │   │   └── repositories/  # TaskRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/      # TaskEntity, TaskPriority enum
│   │   │   ├── repositories/  # TaskRepository (Contract)
│   │   │   └── usecases/      # Discrete CRUD Use Cases
│   │   └── presentation/
│   │       ├── cubit/         # TaskCubit & TaskState (velocity & filters)
│   │       ├── pages/         # TasksPage
│   │       └── widgets/       # DashboardHeader, TaskCard, TaskBottomSheet
│   └── theme/
│       └── presentation/
│           └── cubit/         # ThemeCubit & ThemeState
├── injection_container.dart   # Service Locator / Dependency Injection
└── main.dart                  # App Entry Point & Hive Initialization
```

---

##  Screenshots


 <img width="370" height="814" alt="image" src="https://github.com/user-attachments/assets/0d2e619f-04c6-46ca-b74c-e995bb81781a" />
<img width="370" height="814" alt="image" src="https://github.com/user-attachments/assets/f2432670-c005-4254-bfb6-9fe5566db455" />


 <img width="370" height="814" alt="image" src="https://github.com/user-attachments/assets/3a1b9a33-514a-46f8-89dc-226879cc0943" />
 <img width="370" height="814" alt="image" src="https://github.com/user-attachments/assets/e80cb5b9-d85a-449d-8492-207a7e2fb357" />


---

##  How to Run Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.13+ or higher)
- Android Studio / VS Code with Flutter extension
- Connected Device or Emulator

### Steps

1. **Clone the repository:**
   ```bash
   git clone <YOUR_REPOSITORY_URL>
   cd to_do_list_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **(Optional) Re-generate Hive TypeAdapters:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run Automated Tests:**
   ```bash
   flutter test
   ```

5. **Run the App:**
   ```bash
   flutter run
   ```

---

##  Verification & Quality Assurance

- **Unit & Bloc Tests:** 10/10 automated tests passing across models, usecases, cubits, and widgets.
- **Static Analysis:** `flutter analyze` completed with 0 errors and 0 warnings.
- **Formatting:** Formatted with official Dart code style (`dart format`).

---

## 📄 License & Attribution

Built for the **Auspify Technologies Practical Training Program** by **Eslam Hany**.
UI/UX Design generated and adapted from **Google Stitch**.
