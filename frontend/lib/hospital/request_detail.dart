import 'package:flutter/material.dart';

import '../custom_widgets/text_with_icon.dart';

class RequestDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TextWithIcon(iconData: Icons.phone, text: '000000000'),
        const TextWithIcon(iconData: Icons.domain, text: 'Departments'),
        ElevatedButton(onPressed: () {}, child: const Text('Approve')),
        ElevatedButton(onPressed: () {}, child: const Text('Chat')),
      ],
    );
  }
}
