import 'package:flutter/material.dart';
import 'add_marks_page.dart';

class LecturerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lecturer Home")),
      body: Center(
        child: ElevatedButton(
          child: Text("Insert Carry Marks"),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddMarksPage()));
          },
        ),
      ),
    );
  }
}
