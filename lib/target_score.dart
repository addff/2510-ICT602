import 'package:flutter/material.dart';

class TargetScorePage extends StatefulWidget {
  const TargetScorePage({super.key});
  @override
  State<TargetScorePage> createState() => _TargetScorePageState();
}

class _TargetScorePageState extends State<TargetScorePage> {
  final carry = TextEditingController();
  String output = '';

  void calculate(String grade) {
    final mapping = <String,int>{
      'A+':90, 'A':80, 'A-':75, 'B+':70, 'B':65, 'B-':60, 'C+':55, 'C':50
    };
    final targetMin = mapping[grade]!;
    final current = double.tryParse(carry.text) ?? 0.0;
    // assume final weight 50%
    final need = (targetMin - current) / 0.5;
    setState(() {
      if (need <= 0) output = 'You already achieved $grade or higher.';
      else if (need > 100) output = 'Impossible (need >100%).';
      else output = 'To get $grade you need at least ${need.toStringAsFixed(2)}% in final exam.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Target Score Calculator')),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: carry, decoration: const InputDecoration(labelText: 'Current Carry Mark')),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: ['A+','A','A-','B+','B','B-','C+','C'].map((g) => ElevatedButton(onPressed: () => calculate(g), child: Text(g))).toList()),
        const SizedBox(height: 20),
        Text(output, style: const TextStyle(fontSize: 16)),
      ])),
    );
  }
}
