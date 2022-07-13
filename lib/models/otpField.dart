import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traveling/models/constants.dart';

class otpField extends StatelessWidget {
  final controller;

  otpField(this.controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          new LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        validator: (value) {
          if (value!.isEmpty) {
            // this will be checking if we have any value in it or not?
            return "Field required";
          }
        },
        textInputAction: TextInputAction.done,
        cursorColor: Colors.teal,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black),
        controller: controller,
        decoration: numberFieldDecoration,
      ),
    );
  }
}
