import 'package:flutter/material.dart';
import 'package:skill_share/screens/Auth/login.dart';
import 'package:skill_share/theme.dart';
import 'package:skill_share/widgets/custom_snackbar.dart';
import 'package:skill_share/widgets/primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;
  late String _email;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: kDefaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 150,
            ),
            Text(
              'Reset Password',
              style: titleText,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Please enter your email address',
              style: subTitle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                readOnly: loading,
                obscureText: false,
                validator: (String? value) =>
                value!.isEmpty ? 'Email is required' : null,
                onSaved: (value) => setState(() {
                  _email = value!;
                }),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            PrimaryButton(buttonText: Text(
              'Reset Password',
              style: textButton.copyWith(color: kWhiteColor),
            ), onClick: () async {
              if(_formKey.currentState!.validate())
              {
                _formKey.currentState!.save();
                try {
                  await _auth.sendPasswordResetEmail(email: _email);
                  ScaffoldMessenger.of(context).showSnackBar(successSnackBar("Email has been sent to you!"));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogInScreen(),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(errorSnackBar("An error occurred!"));
                }
              }
            },)
          ],
        ),
      ),
    );
  }
}
