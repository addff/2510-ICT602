double requiredFinalExamMark({required double carryTotal, required double targetOverall, double finalWeight = 0.5}) {
  // carryTotal and targetOverall are 0..100
  // Formula: overall = carryTotal + final * finalWeight => required final = (targetOverall - carryTotal) / finalWeight
  return (targetOverall - carryTotal) / finalWeight;
}

Map<String, double> requiredForGrades({required double carryTotal, double finalWeight = 0.5}) {
  const gradeMap = {
    'A+': 90.0,
    'A': 80.0,
    'A-': 75.0,
    'B+': 70.0,
    'B': 65.0,
    'B-': 60.0,
    'C+': 55.0,
    'C': 50.0,
  };

  return gradeMap.map((k, v) => MapEntry(k, requiredFinalExamMark(carryTotal: carryTotal, targetOverall: v, finalWeight: finalWeight)));
}
