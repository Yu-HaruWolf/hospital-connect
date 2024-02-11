import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget {
  const TextWithIcon({
    super.key,
    required this.textStyle,
    required this.iconData,
    required this.text,
  });

  final TextStyle textStyle;
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          iconData,
          color: Colors.black38,
        ),
        Text(
          text,
          style: textStyle,
        ),
      ],
    );
  }
}
