import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/ambulance/department.dart';
import 'package:frontend/app_state.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  List<DepartmentsAcceptStatus> added = [];
  List<DepartmentsAcceptStatus> notAdded = [];

  int selectedForAddDepartment = -1;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    String hospitalId = context.read<ApplicationState>().loggedInHospital;
    var doc = await FirebaseFirestore.instance
        .collection('hospital')
        .doc(hospitalId)
        .get();
    List<Department> departments = context.read<ApplicationState>().departments;

    List<DepartmentsAcceptStatus> forAddList = [];
    List<DepartmentsAcceptStatus> forNotAddedList = [];
    for (var department in departments) {
      var status = doc.data()!['department'][department.id];
      if (status['accepted'] == false && status['numOfAccepted'] == 0) {
        forNotAddedList.add(DepartmentsAcceptStatus(
          department: department,
          isAccept: false,
          amount: 0,
        ));
      } else {
        forAddList.add(DepartmentsAcceptStatus(
            department: department,
            isAccept: status['accepted'],
            amount: status['numOfAccepted']));
      }
    }

    setState(() {
      added = forAddList;
      notAdded = forNotAddedList;
    });
  }

  Future<void> updateFirebase(String hospitalId,
      DepartmentsAcceptStatus departmentsAcceptStatus) async {
    await FirebaseFirestore.instance
        .collection('hospital')
        .doc(hospitalId)
        .update({
      'department.${departmentsAcceptStatus.department.id}.accepted':
          departmentsAcceptStatus.isAccept,
      'department.${departmentsAcceptStatus.department.id}.numOfAccepted':
          departmentsAcceptStatus.amount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<ApplicationState>().screenId = 0;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Center(child: Text('Department')),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Center(child: Text('Active')),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.15,
                child: Center(child: Text('Amount')),
              ),
            ],
          ),
          for (int i = 0; i < added.length; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(added[i].department.name),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Checkbox(
                    value: added[i].isAccept,
                    onChanged: (bool? value) {
                      setState(() {
                        added[i].isAccept = value!;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: TextFormField(
                      initialValue: added[i].amount.toString(),
                      onChanged: (value) {
                        if (value == '') {
                          added[i].amount = 0;
                        } else {
                          added[i].amount = int.parse(value);
                        }
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    )),
              ],
            ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: DropdownButton(
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          enabled: false,
                          value: -1,
                          child: Text('Please Select'),
                        ),
                        for (int i = 0; i < notAdded.length; i++)
                          DropdownMenuItem(
                            enabled: true,
                            value: i,
                            child: Text(notAdded[i].department.name),
                          ),
                      ],
                      value: selectedForAddDepartment,
                      onChanged: (value) {
                        setState(() {
                          selectedForAddDepartment = value as int;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (selectedForAddDepartment == -1) return;
                            added.add(notAdded[selectedForAddDepartment]);
                            notAdded.removeAt(selectedForAddDepartment);
                            selectedForAddDepartment = -1;
                          });
                        },
                        child: const Text('Add')),
                  ),
                ],
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    for (int i = 0; i < added.length; i++) {
                      updateFirebase(
                          context.read<ApplicationState>().loggedInHospital,
                          added[i]);
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }
}

class DepartmentsAcceptStatus {
  DepartmentsAcceptStatus({
    required this.department,
    required this.isAccept,
    required this.amount,
  });

  Department department;
  bool isAccept;
  int amount;
}
