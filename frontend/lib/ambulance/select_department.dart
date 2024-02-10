import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:frontend/app_state.dart';
import 'package:provider/provider.dart';

class SelectDepartment extends StatefulWidget {
  const SelectDepartment({super.key});

  @override
  State<SelectDepartment> createState() => _SelectDepartmentState();
}

class _SelectDepartmentState extends State<SelectDepartment> {
  var selected = [];

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
    List<String> department = [
      '内科',
      '小児科',
      '皮膚科',
      '精神科',
      '外科',
      '産婦人科',
      '眼科',
      '耳鼻咽喉科',
      '泌尿器科',
      '脳神経外科',
      '形成外科',
      '整形外科'
    ];

    return Column(
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
                          toggleSelected(i * 2 + j);
                        });
                      },
                      style: selected.contains(i * 2 + j)
                          ? selectedButtonStyle
                          : buttonStyle,
                      child: Text(
                        department.elementAt(i * 2 + j),
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
                  label: const Text('キャンセル'),
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
                    print(selected);
                    print(selected.length);
                    appState.screenId = 2;
                  },
                  icon: const Icon(Icons.send),
                  label: selected.isNotEmpty
                      ? Text('送信 ${selected.length}')
                      : const Text('送信'),
                  style: sendButtonStyle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
