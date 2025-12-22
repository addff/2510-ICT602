# ICT602 Grade Management Application

A comprehensive mobile application for managing student grades with support for multiple user roles: Administrator, Lecturer, and Student.

## Features

### 🔐 Authentication & Authorization
- Multi-role authentication system (Admin, Lecturer, Student)
- Secure login and registration
- Firebase Authentication integration
- Role-based access control

### 👨‍💼 Administrator
- Access to Web-Based Management System
- Full system administration capabilities
- Link to external admin panel

### 👨‍🏫 Lecturer
- Enter and manage ICT602 carry marks
- View all student marks in real-time
- Mark components:
  - Test: 20 marks (20% weight)
  - Assignment: 10 marks (10% weight)
  - Project: 20 marks (20% weight)
- Real-time updates to student records

### 👨‍🎓 Student
- View personal carry marks
- Real-time carry mark updates
- Advanced grade calculator
- Calculate final exam marks needed for target grades
- Grade targets supported:
  - A+ (90-100%)
  - A (80-89%)
  - A- (75-79%)
  - B+ (70-74%)
  - B (65-69%)
  - B- (60-64%)
  - C+ (55-59%)
  - C (50-54%)

## Grading System

### Calculation Formula
```
Final Grade = (Carry Mark × 50%) + (Final Exam Mark × 50%)
```

### Carry Mark Breakdown
- **Test**: 20 marks → 20% of final grade
- **Assignment**: 10 marks → 10% of final grade
- **Project**: 20 marks → 20% of final grade
- **Total**: 50 marks → 50% of final grade
- **Final Exam**: 50% of final grade

### Grade Targets
Students can use the calculator to determine what final exam mark they need to achieve their target grade:
- **A+ (90-100%)**: Excellent
- **A (80-89%)**: Very Good
- **A- (75-79%)**: Good
- **B+ (70-74%)**: Very Satisfactory
- **B (65-69%)**: Satisfactory
- **B- (60-64%)**: Barely Satisfactory
- **C+ (55-59%)**: Minimal Pass
- **C (50-54%)**: Minimum Pass

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language

### Backend & Database
- **Firebase Authentication**: Secure user authentication
- **Cloud Firestore**: Real-time NoSQL database
- **Firebase Core**: Firebase platform integration

### Additional Libraries
- **Provider**: State management
- **URL Launcher**: External link handling

## Project Structure

```
lib/
├── main.dart                      # App entry point & Firebase initialization
├── firebase_options.dart          # Firebase configuration
├── models/
│   └── models.dart               # Data models (User, CarryMark, GradeTarget)
├── services/
│   ├── auth_service.dart         # Authentication service
│   ├── carry_mark_service.dart   # Carry mark database operations
│   └── grade_calculation_service.dart  # Grade calculation logic
└── screens/
    ├── login_page.dart           # Login screen
    ├── signup_page.dart          # Registration screen
    ├── admin_dashboard.dart      # Admin interface
    ├── lecturer_dashboard.dart   # Lecturer interface
    └── student_dashboard.dart    # Student interface
```

## Setup & Installation

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Firebase project
- Android Studio or Xcode (for device testing)

### Firebase Setup

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com)

2. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable Email/Password

3. Create Firestore Database:
   - Create a new Cloud Firestore database
   - Set security rules to allow authenticated access

4. Update `firebase_options.dart` with your Firebase project credentials:
   - Get your credentials from Firebase Console
   - Update the API keys and project IDs for each platform

### Installation Steps

1. **Clone or extract the project**:
   ```bash
   cd flutter_application_1
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (if not already done):
   ```bash
   # For Android
   flutterfire configure --platforms=android
   
   # For iOS
   flutterfire configure --platforms=ios
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

## Demo Credentials

Use the following credentials to test the application:

### Administrator Account
- **Email**: `admin@ict602.com`
- **Password**: `password123`
- **Role**: Administrator

### Lecturer Account
- **Email**: `lecturer@ict602.com`
- **Password**: `password123`
- **Role**: Lecturer

### Student Account
- **Email**: `student@ict602.com`
- **Password**: `password123`
- **Role**: Student

**Note**: These demo accounts need to be created first through the Sign Up page or directly in Firebase Console.

## Usage Guide

### For Students

1. **Login** with your student credentials
2. **View Carry Marks**:
   - Check your current carry marks breakdown
   - See Test, Assignment, and Project scores
   - View total carry mark percentage
3. **Calculate Target Grades**:
   - Select your target grade
   - See the exam mark needed
   - Formula shows how calculation is done

### For Lecturers

1. **Login** with your lecturer credentials
2. **Enter Carry Marks**:
   - Navigate to "Enter/Update Carry Marks"
   - Input student information and marks
   - Save marks (updates all students in real-time)
3. **View All Marks**:
   - See complete list of all student marks
   - Click on student to view detailed breakdown

### For Administrators

1. **Login** with admin credentials
2. **Access Web Management**:
   - Click on "Web-Based Management System"
   - Opens external admin panel in browser

## Real-Time Features

The application uses Firestore's real-time updates:
- Students see carry mark updates immediately when lecturers enter them
- Multiple lecturers can update marks simultaneously
- No need to refresh the application

## Security Features

- **Role-Based Access Control**: Each user role has specific permissions
- **Firebase Authentication**: Secure authentication with email/password
- **Database Security Rules**: Firestore rules ensure users can only access their data
- **Password Security**: Minimum 6-character requirement during registration

## Firestore Database Schema

### Users Collection
```
users/
├── {uid}/
│   ├── uid: string
│   ├── email: string
│   ├── role: string (admin|lecturer|student)
│   └── name: string
```

### Carry Marks Collection
```
carry_marks/
├── {studentId}/
│   ├── id: string
│   ├── studentId: string
│   ├── studentEmail: string
│   ├── studentName: string
│   ├── testMark: number (0-20)
│   ├── assignmentMark: number (0-10)
│   ├── projectMark: number (0-20)
│   ├── createdAt: timestamp
│   └── updatedAt: timestamp
```

## Troubleshooting

### Firebase Connection Issues
- Verify internet connection
- Check Firebase project is active
- Confirm API keys in `firebase_options.dart`

### Real-time Updates Not Working
- Check Firestore security rules
- Verify database rules allow read/write for authenticated users
- Restart application

### Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

## Future Enhancements

- Push notifications for grade updates
- PDF export for transcripts
- Offline support with local caching
- Analytics dashboard for lecturers
- GPA calculation features
- Message/notification system

## API Reference

### AuthService
- `signUp()`: Register new user
- `signIn()`: Authenticate user
- `getCurrentUser()`: Get logged-in user
- `signOut()`: Logout user
- `isAuthenticated()`: Check auth status

### CarryMarkService
- `setCarryMarks()`: Save/update marks
- `getStudentCarryMarks()`: Get specific student marks
- `getAllCarryMarks()`: Get all marks
- `getStudentCarryMarksStream()`: Real-time stream for student
- `getAllCarryMarksStream()`: Real-time stream for all marks

### GradeCalculationService
- `calculateExamMarkNeeded()`: Calculate required exam mark
- `calculateFinalGrade()`: Calculate final grade
- `getGradeFromPercentage()`: Get grade for percentage
- `getGradeTargetsWithExamMarks()`: Get all grades with exam requirements

## Support & Contact

For issues or questions, please contact the development team or create an issue in the project repository.

## License

This project is part of the ICT602 course assignment.

---

**Last Updated**: December 2024
**Version**: 1.0.0
