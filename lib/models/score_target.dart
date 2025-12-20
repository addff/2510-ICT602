class ScoreTarget {
  final String grade;
  final double minScore;
  final double maxScore;
  final double requiredExamMark;

  ScoreTarget({
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.requiredExamMark,
  });

  factory ScoreTarget.fromValues(
      String grade, double minScore, double maxScore) {
    // Calculate required exam mark based on grade target
    // Formula: Final Mark = Carry Mark (0-50) + Exam Mark (0-50) = Final Grade (0-100)
    // So: Required Exam Mark = (Target Grade - Carry Mark) / 0.5

    double midPoint = (minScore + maxScore) / 2;
    return ScoreTarget(
      grade: grade,
      minScore: minScore,
      maxScore: maxScore,
      requiredExamMark: midPoint,
    );
  }

  static List<ScoreTarget> getAllTargets() {
    return [
      ScoreTarget(
          grade: 'A+', minScore: 90, maxScore: 100, requiredExamMark: 0),
      ScoreTarget(grade: 'A', minScore: 80, maxScore: 89, requiredExamMark: 0),
      ScoreTarget(grade: 'A-', minScore: 75, maxScore: 79, requiredExamMark: 0),
      ScoreTarget(grade: 'B+', minScore: 70, maxScore: 74, requiredExamMark: 0),
      ScoreTarget(grade: 'B', minScore: 65, maxScore: 69, requiredExamMark: 0),
      ScoreTarget(grade: 'B-', minScore: 60, maxScore: 64, requiredExamMark: 0),
      ScoreTarget(grade: 'C+', minScore: 55, maxScore: 59, requiredExamMark: 0),
      ScoreTarget(grade: 'C', minScore: 50, maxScore: 54, requiredExamMark: 0),
    ];
  }
}
