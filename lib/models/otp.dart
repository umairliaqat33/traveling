import 'package:flutter/material.dart';
import 'package:traveling/models/otpField.dart';

void main() {
  runApp(OTP());
}

final textFieldController1 = TextEditingController();
final textFieldController2 = TextEditingController();
final textFieldController3 = TextEditingController();
final textFieldController4 = TextEditingController();
final textFieldController5 = TextEditingController();
final textFieldController6 = TextEditingController();

class OTP extends StatefulWidget {
  const OTP({Key? key}) : super(key: key);

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Text("Enter OTP",style: TextStyle(
                fontSize: 40
              ),),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [

                  otpField(textFieldController3),
                  otpField(textFieldController4),
                  otpField(textFieldController5),
                  otpField(textFieldController6),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
