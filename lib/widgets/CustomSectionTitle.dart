
// Custom Section Title
import 'package:flutter/cupertino.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;

  const CustomSectionTitle({
    Key? key,
    required this.title,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }
}