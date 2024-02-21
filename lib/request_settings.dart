import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_connect/ambulance/department.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';

class RequestSettingPage extends StatefulWidget {
  final List<String> departments;
  const RequestSettingPage(List<String> requestedDepartments,
      {super.key, required this.departments});

  @override
  State<RequestSettingPage> createState() => _RequestSettingPageState();
}

class _RequestSettingPageState extends State<RequestSettingPage> {
  late List<String> selectedDepartments;
  @override
  void initState() {
    selectedDepartments = widget.departments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Select Departments'),
      ),
      body: Center(
        child: Column(
          children: [
            for (Department department in appState.departments)
              Row(
                children: [
                  Checkbox(
                    value: selectedDepartments.contains(department.id),
                    onChanged: (value) {
                      if (value!) {
                        setState(() {
                          selectedDepartments.add(department.id);
                          selectedDepartments = selectedDepartments;
                        });
                      } else {
                        setState(() {
                          selectedDepartments.remove(department.id);
                          selectedDepartments = selectedDepartments;
                        });
                      }
                    },
                  ),
                  Text(department.name),
                ],
              ),
            ElevatedButton.icon(
                onPressed: () async {
                  appState.isLoading = true;
                  final hospitalDoc = FirebaseFirestore.instance
                      .collection('hospital')
                      .doc(appState.loggedInHospital);
                  for (String departmentId in selectedDepartments) {
                    await hospitalDoc.update({
                      "department.${departmentId}.numOfAccepted":
                          FieldValue.increment(-1)
                    });
                  }
                  appState.isLoading = false;
                  Navigator.pop(context);
                },
                icon: Icon(Icons.send),
                label: Text('Send')),
          ],
        ),
      ),
    );
  }
}
