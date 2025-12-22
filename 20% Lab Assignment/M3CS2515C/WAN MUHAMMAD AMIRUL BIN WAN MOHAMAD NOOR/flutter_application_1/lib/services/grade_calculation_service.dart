import '../models/models.dart';

class GradeCalculationService {
  // Calculate final exam mark needed for target grade
  // Carry mark is 50% of final grade, exam is 50%
  static double calculateExamMarkNeeded({
    required double carryMarkPercentage,
    required double targetGradeMin,
  }) {
    // Formula: (targetGradeMin * 100 - carryMarkPercentage * 50) / 50
    // Rearranged from: finalGrade = (carryMark * 0.5) + (examMark * 0.5)
    double examMarkNeeded = (targetGradeMin - (carryMarkPercentage * 0.5)) / 0.5;
    
    // Ensure exam mark is between 0 and 100
    if (examMarkNeeded < 0) {
      examMarkNeeded = 0;
    } else if (examMarkNeeded > 100) {
      examMarkNeeded = 100;
    }
    
    return examMarkNeeded;
  }

  // Calculate final grade based on carry mark and exam mark
  static double calculateFinalGrade({
    required double carryMarkPercentage,
    required double examMarkPercentage,
  }) {
    return (carryMarkPercentage * 0.5) + (examMarkPercentage * 0.5);
  }

  // Get grade from percentage
  static GradeTarget? getGradeFromPercentage(double percentage) {
    final grades = GradeTarget.getAllGrades();
    for (final grade in grades) {
      if (percentage >= grade.minPercentage && percentage <= grade.maxPercentage) {
        return grade;
      }
    }
    return null;
  }

  // Get all grade targets with exam marks needed
  static List<Map<String, dynamic>> getGradeTargetsWithExamMarks(
    double carryMarkPercentage,
  ) {
    final grades = GradeTarget.getAllGrades();
    return grades.map((grade) {
      final examMarkNeeded = calculateExamMarkNeeded(
        carryMarkPercentage: carryMarkPercentage,
        targetGradeMin: grade.minPercentage,
      );

      return {
        'grade': grade.grade,
        'description': grade.description,
        'minPercentage': grade.minPercentage,
        'maxPercentage': grade.maxPercentage,
        'examMarkNeeded': examMarkNeeded,
        'isAchievable': examMarkNeeded <= 100,
      };
    }).toList();
  }
}
