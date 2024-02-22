import 'package:flutter/material.dart';
import 'package:hospital_connect/ambulance/department.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class SelectDepartment extends StatefulWidget {
  const SelectDepartment({super.key});

  @override
  State<SelectDepartment> createState() => _SelectDepartmentState();
}

class _SelectDepartmentState extends State<SelectDepartment> {
  late List<String> selected;

  @override
  void initState() {
    super.initState();
    selected = context.read<ApplicationState>().selectedDepartments;
  }

  void toggleSelected(var id) {
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
      //print(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle selectedButtonStyle = const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.cyan),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      side: MaterialStatePropertyAll(
          BorderSide(color: Colors.lightBlue, width: 3)),
    );

    ButtonStyle cancelButtonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.red),
      foregroundColor: const MaterialStatePropertyAll(Colors.black),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

    ButtonStyle sendButtonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
      foregroundColor: const MaterialStatePropertyAll(Colors.black),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );

    ButtonStyle buttonStyle = const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      side: MaterialStatePropertyAll(BorderSide(color: Colors.black, width: 2)),
    );

    double buttonWidth = MediaQuery.of(context).size.width * 0.4;
    EdgeInsets buttonPadding = const EdgeInsets.all(8.0);
    var appState = context.watch<ApplicationState>();
    EdgeInsets underPadding =
        const EdgeInsets.only(top: 30, right: 8, bottom: 8, left: 8);
    List<Department> department = appState.departments;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        appState.screenId = 0;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (int i = 0; i < department.length / 2; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int j = 0; j < 2 && (i * 2 + j < department.length); j++)
                  Padding(
                    padding: buttonPadding,
                    child: SizedBox(
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            toggleSelected(department.elementAt(i * 2 + j).id);
                          });
                        },
                        style: selected
                                .contains(department.elementAt(i * 2 + j).id)
                            ? selectedButtonStyle
                            : buttonStyle,
                        child: Text(
                          department.elementAt(i * 2 + j).name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: underPadding,
                child: SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        selected.clear();
                        //print(selected);
                      });
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Clear'),
                    style: cancelButtonStyle,
                  ),
                ),
              ),
              Padding(
                padding: underPadding,
                child: SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appState.selectedDepartments = selected;
                      appState.screenId = 2;
                    },
                    icon: const Icon(Icons.send),
                    label: selected.isNotEmpty
                        ? Text('Send ${selected.length}')
                        : const Text('Send'),
                    style: sendButtonStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
