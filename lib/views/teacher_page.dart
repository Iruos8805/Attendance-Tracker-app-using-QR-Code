import 'package:flutter/material.dart';
import 'dart:math';

class AddClass extends StatefulWidget {
  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  List<String> studentDetails = [];
  List<String> classDetails = [];

  Color? boxColor;
  bool showClassForm = true;
  bool showStudentForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // Use AppBar as the actual AppBar of the Scaffold
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showClassForm) buildClassForm(),
            if (boxColor != null) buildClassDetailsContainer(),
            if (showStudentForm) buildStudentForm(),
            const SizedBox(height: 20),
            if (!showClassForm && !showStudentForm) buildAddStudentDetailsButton(),
            const SizedBox(height: 20),
            if (!showStudentForm) buildStudentDetailsList(),
            buildReturnToHomeButton(),
          ],
        ),
      ),
    );
  }

  Widget buildClassForm() {
    TextEditingController classNameController = TextEditingController();

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: classNameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Class Name',
              prefixIcon: Icon(
                Icons.class_rounded,
                color: Colors.teal,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Class name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (Form.of(context)!.validate()) {
                setState(() {
                  classDetails.add('Class Name: ${classNameController.text},');
                  boxColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
                  showClassForm = false;
                  showStudentForm = false;
                  studentDetails.clear();
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget buildClassDetailsContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((context as Element).findAncestorWidgetOfExactType<Form>()?.key?.toString() ?? 'Default Value'),
        ],
      ),
    );
  }

  Widget buildStudentForm() {
    TextEditingController rollNoController = TextEditingController();
    TextEditingController nameController = TextEditingController();

    return Column(
      children: [
        const SizedBox(height: 20),
        Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: rollNoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Roll No',
                  prefixIcon: Icon(
                    Icons.class_rounded,
                    color: Color.fromARGB(255, 26, 153, 37),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Roll No is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  prefixIcon: Icon(
                    Icons.numbers,
                    color: Color.fromARGB(255, 26, 153, 37),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (Form.of(context)!.validate()) {
                    setState(() {
                      studentDetails.add('Roll No: ${rollNoController.text}, Name: ${nameController.text}');
                      rollNoController.clear();
                      nameController.clear();
                      showStudentForm = false;
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAddStudentDetailsButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showStudentForm = true;
        });
      },
      child: const Text('Add Student Details'),
    );
  }

  Widget buildStudentDetailsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Details :',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        for (var student in studentDetails)
          ListTile(
            title: Text(student),
          ),
      ],
    );
  }

  Widget buildReturnToHomeButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromRGBO(23, 152, 185, 100),
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      ),
      child: const Text('Return to Home'),
    );
  }
}
