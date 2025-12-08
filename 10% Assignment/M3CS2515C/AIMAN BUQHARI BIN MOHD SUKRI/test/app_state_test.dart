import 'package:flutter_test/flutter_test.dart';
import 'package:ict602/state/app_state.dart';

void main() {
  group('AppState calculations', () {
    test('requiredExamForTarget caps and floors', () {
      final s = AppState();
      expect(s.requiredExamForTarget(50, 90), 80);
      expect(s.requiredExamForTarget(95, 90), 0);
      expect(s.requiredExamForTarget(0, 100), 101);
    });

    test('examTargets produce expected labels and values', () {
      final s = AppState();
      final t = s.examTargets(50);
      expect(t.first['label'], 'A+ (90-100)');
      expect(t.first['required'], '80/100');
      final t2 = s.examTargets(10);
      final last = t2.last; // C (50-54)
      expect(last['label'], 'C (50-54)');
      expect(last['required'], '80/100');
    });
  });
}
