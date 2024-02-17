import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app_state.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int numOfDepartment = 1;
  List<String> isSelectedValue = ['A'];

  // TODO デザインを整える

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<ApplicationState>().screenId = 0;
      },
      child: Column(
        children: [
          for (int i = 0; i < numOfDepartment; i++)
            Row(
              children: [
                DropdownButton(
                  items: const [
                    DropdownMenuItem(
                      value: 'B',
                      child: Text('value'),
                    ),
                    DropdownMenuItem(
                      value: 'A',
                      child: Text('value2'),
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
                  child: const Text('Add')),
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                  label: const Text('Send')),
            ],
          ),
        ],
      ),
    );
  }
}
