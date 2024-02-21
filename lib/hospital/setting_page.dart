import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_connect/ambulance/department.dart';
import 'package:hospital_connect/app_state.dart';
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
    var appState = context.watch<ApplicationState>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        appState.screenId = 0;
      },
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
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
                                    added.add(
                                        notAdded[selectedForAddDepartment]);
                                    notAdded.removeAt(selectedForAddDepartment);
                                    selectedForAddDepartment = -1;
                                  });
                                },
                                child: const Text('Add')),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            appState.isLoading = true;
                            for (int i = 0; i < added.length; i++) {
                              await updateFirebase(
                                  context
                                      .read<ApplicationState>()
                                      .loggedInHospital,
                                  added[i]);
                            }
                            appState.isLoading = false;
                            appState.screenId = 0;
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Save')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (appState.isLoading)
            const Opacity(
              opacity: 0.7,
              child: ModalBarrier(
                dismissible: true,
                color: Colors.black,
              ),
            ),
          if (appState.isLoading)
            const Center(
              child: CircularProgressIndicator(),
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
