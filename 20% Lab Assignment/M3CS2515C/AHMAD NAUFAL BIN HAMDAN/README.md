# Carry Mark Management Application

A Flutter mobile application for managing student carry marks with multi-level login (Administrator, Lecturer, Student).

## Features
- YOUTUBE LINK 
https://youtu.be/lvG2fx4bLu4

### 1. **Multi-Level Authentication**
- Administrator Login
- Lecturer Login
- Student Login
- Firebase Authentication Integration

### 2. **Administrator Dashboard**
- Direct access to Web-Based Management System
- Link to external web management portal

### 3. **Lecturer Dashboard**
- Enter/Update student carry marks
- Mark Breakdown:
  - Test: 20% (0-20 marks)
  - Assignment: 10% (0-10 marks)
  - Project: 20% (0-20 marks)
- View all student records
- Delete student records (if needed)

### 4. **Student Dashboard**
- View personal carry marks
- Grade Calculator
  - Calculate required final exam mark based on target grade
  - Grades: A+ (90-100), A (80-89), A- (75-79), B+ (70-74), B (65-69), B- (60-64), C+ (55-59), C (50-54)
- Final exam mark is 50% of total grade (Carry mark is also 50%)

## Project Structure

```
carry_mark_app/
├── lib/
│   ├── main.dart                 # Main app entry point
│   ├── firebase_options.dart     # Firebase configuration
│   ├── providers/
│   │   └── auth_provider.dart    # Authentication logic
│   └── screens/
│       ├── login_screen.dart     # Login/Sign up screen
│       ├── admin_screen.dart     # Admin dashboard
│       ├── lecturer_screen.dart  # Lecturer dashboard
│       └── student_screen.dart   # Student dashboard
├── pubspec.yaml
└── android/
    └── app/
        └── google-services.json  # Firebase config (to be added)
```

## Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Database
- `provider` - State management
- `url_launcher` - Open web links
- `intl` - Internationalization

## Setup Instructions

### 1. **Prerequisites**
- Flutter SDK installed
- Firebase project created
- Laragon/MySQL database setup (optional - can use Firestore instead)

### 2. **Firebase Setup**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Enable Firestore Database
5. Download `google-services.json` for Android
6. Place it in `android/app/` directory

### 3. **Update Firebase Configuration**

Edit `lib/firebase_options.dart` with your Firebase project details:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'your-project-id',
  storageBucket: 'your-project.appspot.com',
);
```

### 4. **Install Dependencies**

```bash
cd carry_mark_app
flutter pub get
```

### 5. **Enable Developer Mode (Windows)**

Run: `start ms-settings:developers` and enable Developer Mode for symlink support.

### 6. **Run the App**

```bash
flutter run
```

## Database Schema (Firestore)

### Collection: `users`
```json
{
  "email": "user@example.com",
  "role": "student|lecturer|admin",
  "createdAt": "timestamp",
  "studentId": "A123456",
  "lecturerId": "L001"
}
```

### Collection: `carry_marks`
```json
{
  "studentId": "A123456",
  "test": 18,
  "assignment": 9,
  "project": 19,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## User Roles & Access

### Administrator
- Access to Web-Based Management System
- Can manage users and system settings
- Direct link to external web portal

### Lecturer
- Enter/Update student carry marks
- View all student records
- Manage mark submissions

### Student
- View personal carry marks
- Calculate required final exam mark
- Check grade requirements

## Grade Calculation

**Final Grade Calculation:**
- Total Grade = (Carry Mark / 50) × 50 + (Final Exam Mark / 50) × 50
- Carry Mark Components:
  - Test: 20% (0-20 points)
  - Assignment: 10% (0-10 points)
  - Project: 20% (0-20 points)
  - Total: 50 points

**Example:**
- If a student has 40/50 in carry marks (80%)
- To achieve Grade A (85%), they need: (85 - 80×0.5) / 0.5 = 90% in final exam

## Testing Account Examples

### Admin Account
- Email: `admin@gmail.com`
- Password: `123456`
- Role: `admin`

### Lecturer Account
- Email: `lecturer1@gmail.com`
- Password: `123123`
- Role: `lecturer`

### Student Account
- Email: `student1@gmail.com`
- Password: `123123`
- Role: `student`

## Important Notes

1. **Password Security**: Currently set to NOT hash lecturer passwords (as per requirements). In production, implement proper password hashing.

2. **MySQL Integration**: The app uses Firebase/Firestore. To use MySQL via Laragon:
   - Create a backend API
   - Connect Flutter app to the API
   - Use HTTP package for API calls

3. **Web Admin Portal**: Update the URL in `admin_screen.dart`:
   ```dart
   const url = 'http://localhost/carry-mark-management';
   ```

4. **Error Handling**: Ensure stable internet connection for Firebase operations.

## Future Enhancements

- SMS/Email notifications for marks updates
- Export marks to CSV/PDF
- Student performance analytics
- Mobile app push notifications
- Dark mode support
- Multi-language support

## Troubleshooting

### Build Issues
- Run: `flutter clean` then `flutter pub get`
- For Windows: Enable Developer Mode

### Firebase Connection Issues
- Verify Firebase credentials in `firebase_options.dart`
- Check internet connection
- Ensure Firestore rules allow access

### Symlink Errors (Windows)
- Enable Developer Mode: `start ms-settings:developers`
- Run Flutter with administrator privileges

## Support

For issues or questions, contact: ICT 602 Lab Instructor

## License

Academic Project - ICT 602

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
