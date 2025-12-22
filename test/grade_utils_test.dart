import 'package:flutter_test/flutter_test.dart';
import 'package:ict602_carrymark/utils/grade_utils.dart';

void main() {
  test('requiredFinalExamMark basic', () {
    final r = requiredFinalExamMark(carryTotal: 40, targetOverall: 80, finalWeight: 0.5);
    expect(r, 80.0);
  });

  test('requiredForGrades produces map for carry = 50', () {
    final res = requiredForGrades(carryTotal: 50);
    expect(res['A'], (80 - 50) / 0.5);
    expect(res['C'], (50 - 50) / 0.5);
  });

  test('impossible >100', () {
    final r = requiredFinalExamMark(carryTotal: 10, targetOverall: 90, finalWeight: 0.5);
    expect(r > 100, true);
  });
}
