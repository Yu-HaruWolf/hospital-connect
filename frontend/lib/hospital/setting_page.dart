import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int numOfDepartment = 1;
  List<String> isSelectedValue = ['A'];

  // TODO デザインを整える

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < numOfDepartment; i++)
          Row(
            children: [
              DropdownButton(
                items: [
                  DropdownMenuItem(
                    child: Text('value'),
                    value: 'B',
                  ),
                  DropdownMenuItem(
                    child: Text('value2'),
                    value: 'A',
                  ),
                ],
                value: isSelectedValue[i],
                onChanged: (value) {
                  setState(() {
                    isSelectedValue[i] = value!;
                  });
                },
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextField(
                    onChanged: (value) => print(value),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  )),
            ],
          ),
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    numOfDepartment++;
                    isSelectedValue.add('A');
                  });
                },
                child: Text('Add')),
            ElevatedButton.icon(
                onPressed: () {}, icon: Icon(Icons.send), label: Text('Send')),
          ],
        ),
      ],
    );
  }
}
