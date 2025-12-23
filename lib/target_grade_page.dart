import 'package:flutter/material.dart';

class TargetGradePage extends StatefulWidget {
  const TargetGradePage({super.key});

  @override
  State<TargetGradePage> createState() => _TargetGradePageState();
}

class _TargetGradePageState extends State<TargetGradePage> {
  final _subjectController = TextEditingController();
  final _carryMarkController = TextEditingController();

  String _selectedGrade = 'A';
  double? _requiredFinal;
  bool _notAchievable = false;

  // Grade thresholds (total marks)
  final Map<String, double> gradeTargets = {
    'A+': 90,
    'A': 80,
    'A-': 75,
    'B+': 70,
    'B': 65,
    'B-': 60,
    'C+': 55,
    'C': 50,
  };

  void _calculate() {
    final subject = _subjectController.text.trim();
    final carryText = _carryMarkController.text.trim();

    if (subject.isEmpty || carryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final carryMark = double.tryParse(carryText);
    if (carryMark == null || carryMark < 0 || carryMark > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carry mark must be between 0 and 50'),
        ),
      );
      return;
    }

    final target = gradeTargets[_selectedGrade]!;

    // Carry = 50%, Final = 50%
    final needed = ((target - carryMark) / 50) * 100;

    setState(() {
      _requiredFinal = needed;
      _notAchievable = needed > 100;
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _carryMarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Grade Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject Code (e.g. ICT602)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _carryMarkController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Carry Mark (0–50)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Select Target Grade',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            DropdownButton<String>(
              value: _selectedGrade,
              items: gradeTargets.keys.map((grade) {
                return DropdownMenuItem(
                  value: grade,
                  child: Text(grade),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGrade = value!;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate Required Final Mark'),
              ),
            ),

            const SizedBox(height: 24),

            if (_requiredFinal != null) ...[
              Text(
                'Required final exam score: '
                '${_requiredFinal!.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (_notAchievable)
                const Text(
                  '⚠ This target grade is NOT achievable.\n'
                  'The required final exam score exceeds 100%.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                const Text(
                  '✅ This target grade is achievable.',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
