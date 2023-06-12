import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:skill_share/screens/Auth/login.dart';
import 'package:skill_share/theme.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void navigateToOtherScreen(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.push(context, MaterialPageRoute(builder: (context) => LogInScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          child: DefaultTextStyle(
            style: const TextStyle(color: kWhiteColor, fontSize: 25, fontWeight: FontWeight.w700),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText('TRAINING & SKILL DEVELOPMENT', speed: Duration(milliseconds: 200)),
              ],
            ),
          ),
        )
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    navigateToOtherScreen(context);
  }
}
