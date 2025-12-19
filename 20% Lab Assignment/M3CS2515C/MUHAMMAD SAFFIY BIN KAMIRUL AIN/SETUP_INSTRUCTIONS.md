# ICT602 Grade Management System - Setup Instructions

## Quick Start Guide

### Step 1: Verify Flutter Installation
Open PowerShell and run:
```powershell
flutter --version
```

If Flutter is not installed, download from: https://flutter.dev/docs/get-started/install

### Step 2: Navigate to Project Directory
```powershell
cd "d:\UITM\Degree\SEM 5\ICT602\LAB 2\my_app-ICT602-\Assignment 1\ict602_app"
```

### Step 3: Get Dependencies
```powershell
flutter pub get
```

This will download and install all required packages:
- flutter
- cupertino_icons
- sqflite
- path
- url_launcher
- intl

### Step 4: Run the Application

#### Option A: Android Emulator
1. Open Android Studio
2. Create or start an emulator
3. In PowerShell, run:
```powershell
flutter run
```

#### Option B: Physical Android Device
1. Connect your device via USB
2. Enable Developer Mode (Settings > About > tap Build Number 7 times)
3. Enable USB Debugging
4. In PowerShell, run:
```powershell
flutter run
```

#### Option C: Windows Desktop
```powershell
flutter run -d windows
```

### Step 5: Test the Application

Once the app is running, test with the following credentials:

**Admin Account:**
- Username: `admin`
- Password: `admin123`
- Expected: Admin dashboard with Web Management link

**Lecturer Account:**
- Username: `lecturer1`
- Password: `lecturer123`
- Expected: Lecturer dashboard with student marks list

**Student Account 1:**
- Username: `student1`
- Password: `student123`
- Expected: Student dashboard with carry marks and calculator

**Student Account 2:**
- Username: `student2`
- Password: `student123`
- Expected: Student dashboard with carry marks and calculator

## Testing Workflows

### Testing Admin Features:
1. Login with admin credentials
2. View system information
3. Click "Web-Based Management" to see URL dialog
4. Click Logout to return to login screen

### Testing Lecturer Features:
1. Login with lecturer1 credentials
2. View existing student carry marks
3. Click "Add Mark" to add a new student:
   - Student Name: Test Student
   - Matrix Number: 2023003
   - Student ID: STU003
   - Test Mark: 19
   - Assignment Mark: 9
   - Project Mark: 20
4. Click "Update" to save
5. Edit a mark by clicking the edit icon
6. Delete a mark by clicking the delete icon
7. Logout

### Testing Student Features:
1. Login with student1 credentials
2. View carry marks (should show: Test: 18, Assignment: 9.5, Project: 19)
3. Total carry mark should be 46.5/50
4. Click on grade buttons (A+, A, A-, etc.)
5. Observe the required exam mark calculation:
   - If achievable (≤ 100): Shows green indicator with required score
   - If not achievable (> 100): Shows red warning
   - If already achieved (< 0): Shows green success message
6. Test different grades to see variations
7. Logout

## Project Structure Explanation

```
ict602_app/
├── lib/
│   ├── main.dart
│   │   └── Application entry point and route definitions
│   │
│   ├── models/
│   │   ├── user.dart          (User data model)
│   │   ├── carry_mark.dart    (Grade data model)
│   │   └── score_target.dart  (Grade target model)
│   │
│   ├── screens/
│   │   ├── login_screen.dart       (Authentication UI)
│   │   ├── admin_dashboard.dart    (Admin interface)
│   │   ├── lecturer_dashboard.dart (Lecturer interface)
│   │   └── student_dashboard.dart  (Student interface)
│   │
│   └── services/
│       └── database_service.dart   (SQLite operations)
│
├── pubspec.yaml          (Dependencies)
├── README.md            (Full documentation)
├── ANALYSIS.txt         (Technical analysis)
└── setup_instructions.md (This file)
```

## Database Initialization

The SQLite database is automatically created on first app launch with:
- Users table with 4 pre-loaded accounts
- Carry marks table with 2 sample records
- Database file: `ict602_app.db`

No manual database setup is required.

## Troubleshooting

### Issue: "Command 'flutter' is not recognized"
**Solution:**
- Add Flutter to PATH environment variables
- Restart PowerShell after installation

### Issue: "Target of URI doesn't exist"
**Solution:**
```powershell
flutter pub get
flutter clean
flutter pub get
```

### Issue: "No connected devices"
**Solution:**
- Start Android emulator from Android Studio
- Or connect a physical device
- Run `flutter devices` to list available devices

### Issue: "Database locked"
**Solution:**
- Close and reopen the app
- Clear app data and try again

### Issue: "Cannot find pubspec.yaml"
**Solution:**
- Ensure you're in the correct directory
- Run `cd ict602_app` before running commands

## Running in Different Modes

### Debug Mode (Development):
```powershell
flutter run
```

### Release Mode (Optimized):
```powershell
flutter run --release
```

### Profile Mode (Performance Testing):
```powershell
flutter run --profile
```

## Building for Release

### Android APK:
```powershell
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Windows EXE:
```powershell
flutter build windows
```
Output: `build/windows/runner/Release/ict602_app.exe`

## IDE Setup (Recommended)

### VS Code:
1. Install Flutter extension by Dart Code
2. Open the project folder
3. Click "Get Packages" when prompted

### Android Studio:
1. Install Flutter plugin from Plugins menu
2. Open as Flutter project
3. Run or Debug from toolbar

## Performance Tips

- Use release mode for better performance
- Close unnecessary apps before running
- Use emulator hardware acceleration if available
- Profile with `flutter run --profile` to identify bottlenecks

## Debugging

### View logs:
```powershell
flutter logs
```

### Enable verbose logging:
```powershell
flutter run -v
```

### Device console output:
```powershell
flutter run -v 2>&1 | Tee-Object -FilePath debug.log
```

## Creating Signed APK (Production)

1. Create keystore (one-time):
```powershell
keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Build signed APK:
```powershell
flutter build apk --release
```

3. Sign APK:
```powershell
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore key.jks build/app/outputs/flutter-apk/app-release.apk upload
```

## Additional Resources

- Flutter Documentation: https://flutter.dev/docs
- Dart Language: https://dart.dev
- SQLite Tutorials: https://www.sqlitetutorial.net/
- Material Design: https://material.io/design

## Support

For issues or questions:
1. Check Flutter logs: `flutter logs`
2. Run: `flutter doctor` for environment issues
3. Consult README.md for feature documentation
4. Check ANALYSIS.txt for technical details

## Version Information

- Flutter: >=2.19.0
- Dart: >=2.19.0
- Minimum SDK: Android 21, iOS 11
- Created: December 3, 2025

---

**Ready to run?** Start with Step 1 and follow through Step 5!
