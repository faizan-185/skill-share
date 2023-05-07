import 'package:flutter/material.dart';
import 'package:skill_share/theme.dart';

class PrimaryButton extends StatelessWidget {
  final Widget buttonText;
  final VoidCallback onClick;
  const PrimaryButton({super.key, required this.buttonText, required this.onClick});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.08,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16), color: kPrimaryColor),
        child: buttonText
      ),
    );
  }
}
