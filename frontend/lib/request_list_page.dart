import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'custom_widgets/text_with_icon.dart';

class RequestListPage extends StatelessWidget {
  const RequestListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.read<ApplicationState>().screenId = 0;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < 5; i++)
              const HospitalCard(
                  title: 'Title',
                  department: 'Department',
                  lastUpdateTime: '2000/1/1 12:34:56',
                  id: 'aaa'),
          ],
        ),
      ),
    );
  }
}

class HospitalCard extends StatelessWidget {
  const HospitalCard({
    super.key,
    required this.title,
    required this.department,
    required this.lastUpdateTime,
    required this.id,
  });

  final String title;
  final String department;
  final String lastUpdateTime;
  final String id;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ApplicationState>();
    TextStyle nameStyle = const TextStyle(
      fontSize: 20,
    );
    TextStyle normalStyle = const TextStyle();
    return Card(
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWithIcon(
                    iconData: Icons.fact_check,
                    text: title,
                    textStyle: nameStyle),
                TextWithIcon(
                    textStyle: normalStyle,
                    iconData: Icons.domain,
                    text: department),
                TextWithIcon(
                    textStyle: normalStyle,
                    iconData: Icons.schedule,
                    text: lastUpdateTime),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
