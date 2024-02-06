import 'package:flutter/material.dart';
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
    }
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle selectedButtonStyle = const ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(Colors.lightBlue),
    );
    ButtonStyle buttonStyle = const ButtonStyle();
    double buttonWidth = MediaQuery.of(context).size.width * 0.4;
    EdgeInsets buttonPadding = const EdgeInsets.all(8.0);
    List<String> department = ['あ', '内科', 'う', 'え', 'お', 'か', 'き', 'く'];

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
                      child: Text(department.elementAt(i * 2 + j)),
                    ),
                  ),
                ),
            ],
          ),
        ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send),
            label: const Text('送信'))
      ],
    );
  }
}
