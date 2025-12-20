# ICT602 Grade Management System

A Flutter mobile application for multi-level login with carry mark management for ICT602 course.

## Features

### 1. **Multi-Level Authentication**
- **Administrator**: Access to system management portal
- **Lecturer**: Can enter and manage student carry marks
- **Student**: Can view carry marks and calculate target exam scores

### 2. **Administrator Dashboard**
- Direct access link to web-based management system
- System information display
- User management interface

### 3. **Lecturer Dashboard**
- View all student carry marks
- Add new student carry marks
- Edit existing carry marks
- Delete carry mark records

**Carry Mark Breakdown (Total: 50%)**
- Test: 20% (out of 20)
- Assignment: 10% (out of 10)
- Project: 20% (out of 20)

### 4. **Student Dashboard**
- View personal carry marks
- Grade calculator tool
- Calculate required final exam scores for target grades
- Visual representation of grade targets (A+, A, A-, B+, B, B-, C+, C)

**Grade Scale**
- A+: 90-100
- A: 80-89
- A-: 75-79
- B+: 70-74
- B: 65-69
- B-: 60-64
- C+: 55-59
- C: 50-54

**Final Grade Calculation**
```
Final Mark = (Carry Mark × 50%) + (Final Exam Mark × 50%)
```

## Project Structure

```
ict602_app/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/
│   │   ├── user.dart             # User model (Admin, Lecturer, Student)
│   │   ├── carry_mark.dart        # CarryMark model
│   │   ├── score_target.dart      # ScoreTarget model
│   │   └── index.dart             # Models index
│   ├── screens/
│   │   ├── login_screen.dart      # Login/Authentication screen
│   │   ├── admin_dashboard.dart   # Admin interface
│   │   ├── lecturer_dashboard.dart # Lecturer interface
│   │   ├── student_dashboard.dart  # Student interface
│   │   └── index.dart             # Screens index
│   ├── services/
│   │   ├── database_service.dart  # SQLite database operations
│   │   └── index.dart             # Services index
│   └── widgets/                   # Custom widgets (if needed)
├── assets/                        # App assets
├── pubspec.yaml                   # Dependencies
├── android/                       # Android platform configuration
├── ios/                           # iOS platform configuration
└── web/                           # Web platform configuration (optional)
```

## Prerequisites

- Flutter SDK (>=2.19.0)
- Dart (>=2.19.0)
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, etc.)

## Installation & Setup

### 1. Clone or Extract the Project
```bash
cd ict602_app
```

### 2. Get Dependencies
```bash
flutter pub get
```

### 3. Run the Application

**On Android Emulator:**
```bash
flutter run
```

**On Connected Device:**
```bash
flutter run
```

**On Web (if enabled):**
```bash
flutter run -d chrome
```

## Demo Credentials

### Login Credentials for Testing

| Role      | Username    | Password      |
|-----------|-------------|---------------|
| Admin     | admin1       | admin123     |
| Lecturer  | lecturer   | lecturer123   |
| Student 1 | student    | student123    |

## Database

The application uses **SQLite** for local data storage with the following tables:

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  name TEXT NOT NULL,
  student_id TEXT,
  matrix_no TEXT,
  created_at TEXT NOT NULL
)
```

### Carry Marks Table
```sql
CREATE TABLE carry_marks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id TEXT NOT NULL,
  student_name TEXT NOT NULL,
  matrix_no TEXT NOT NULL,
  test_mark REAL NOT NULL,
  assignment_mark REAL NOT NULL,
  project_mark REAL NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT,
  UNIQUE(student_id)
)
```

## Usage Guide

### For Lecturers:
1. Login with lecturer credentials (lecturer1 / lecturer123)
2. Click "Add Mark" to enter student carry marks
3. Enter:
   - Student Name
   - Matrix Number
   - Student ID
   - Test Mark (0-20)
   - Assignment Mark (0-10)
   - Project Mark (0-20)
4. Edit or delete existing marks as needed

### For Students:
1. Login with student credentials
2. View your carry marks
3. Use the Grade Calculator:
   - Select a target grade
   - View the required final exam mark
   - See your projected final grade

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **SQLite**: Local database
- **Material Design 3**: UI framework

## Dependencies

- `sqflite: ^2.3.0` - SQLite database
- `path: ^1.8.3` - File path utilities
- `url_launcher: ^6.1.11` - Launch URLs
- `intl: ^0.19.0` - Internationalization

## Building for Production

### Android APK:
```bash
flutter build apk --release
```

### iOS IPA:
```bash
flutter build ios --release
```

### Web:
```bash
flutter build web
```

## Troubleshooting

### Issue: "Target of URI doesn't exist"
**Solution**: Run `flutter pub get` to fetch dependencies

### Issue: Database not found
**Solution**: The database is created automatically on first run

### Issue: Cannot login
**Solution**: Use the demo credentials provided in the login screen

## Future Enhancements

- [ ] Backend integration with REST API
- [ ] Student performance analytics
- [ ] Email notifications for grade updates
- [ ] Course materials download feature
- [ ] Discussion forum
- [ ] Mobile app auto-updates
- [ ] Biometric authentication
- [ ] Offline mode improvements

## Author

Created for ICT602 Course Assignment

## License

This project is for educational purposes only.

## Support

For issues or questions, please contact your instructor.

---

**Version**: 1.0.0  
**Last Updated**: December 3, 2025

