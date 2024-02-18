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
          for (int i = 0; i < numOfDepartment; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: DropdownButton(
                    isExpanded: true,
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
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                  child: Checkbox(
                    value: true,
                    onChanged: (bool? value) {},
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: TextField(
                      onChanged: (value) => print(value),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    )),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      numOfDepartment++;
                      isSelectedValue.add('A');
                    });
                  },
                  child: const Text('Add')),
              SizedBox(
                width: 10,
              ),
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
