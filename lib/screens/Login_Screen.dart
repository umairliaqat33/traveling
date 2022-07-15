import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:traveling/models/constants.dart';
import 'package:traveling/screens/Login_Screen.dart';
import 'package:traveling/screens/welcome_screen.dart';
import 'Registration_Screen.dart';

import '../menuScreen.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  late String verificationId;

  final phoneController = TextEditingController();
  final OTPController = TextEditingController();
  String pattern = r'(^(?:[+]9)?[0-9]{13,13}$)';
  final _formKey = GlobalKey<FormState>();
  final _OTPFormKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  getMobileFormWidget(context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('assets/images/Traveling_logo.png'),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      // this will be checking if we have any value in it or not?
                      return "Field required";
                    }
                    if (!RegExp(pattern).hasMatch(value)) {
                      // this will be checking whether the value in it is a phone number or not?
                      return null;
                    }
                    return "Enter a valid phone";
                  },
                  cursorColor: Colors.teal,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  controller: phoneController,
                  decoration: kMessageTextFieldDecoration.copyWith(
                    hintText: '+92----------',
                    icon: Icon(Icons.phone),
                  ),
                ),
                SizedBox(
                  height: 24.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            showSpinner = true;
                          });
                          await _auth.verifyPhoneNumber(
                            phoneNumber: phoneController.text,
                            verificationCompleted: (phoneAuthCredential) async {
                              setState(() {
                                showSpinner = false;
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WelcomeUserScreen()));
                              Fluttertoast.showToast(msg: "Number verified");
                              print(phoneAuthCredential.toString());
                            },
                            verificationFailed: (verificationFailed) async {
                              Fluttertoast.showToast(
                                  msg: "Verification Failed" +
                                      verificationFailed.message.toString());
                              print(verificationFailed.message.toString());
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                            },
                            codeSent: (verificationID, resendingToken) async {
                              setState(() {
                                this.verificationId = verificationID;
                                showSpinner = false;
                                // sleep(const Duration(seconds: 5));
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => OTP()),
                                // );
                                currentState =
                                    MobileVerificationState.SHOW_OTP_FORM_STATE;
                              });
                              Fluttertoast.showToast(msg: "Code Sent");
                              print(verificationID.toString());
                              print(resendingToken.toString());
                            },
                            codeAutoRetrievalTimeout: (verificationId) async {},
                            timeout: Duration(seconds: 90),
                          );
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                        ;
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Log In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Don\'t have an account? '),
                    TextButton(
                      style: ButtonStyle(
                          splashFactory: NoSplash
                              .splashFactory //removing onclick splash color
                          ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen()));
                      },
                      child: Text("SignUp"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getOTPFormWidget(context) {
    return Column(
      children: [
        Text(
          "Enter OTP",
          style: TextStyle(fontSize: 40),
        ),
        Container(
          width: 400,
          child: Form(
            key: _OTPFormKey,
            child: TextFormField(
              inputFormatters: <TextInputFormatter>[
                new LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value!.isEmpty) {
                  // this will be checking if we have any value in it or not?
                  return "Field required";
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              cursorColor: Colors.teal,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
              controller: OTPController,
              decoration: numberFieldDecoration,
            ),
          ),
        ),
        Text("code will be sent after 90 seconds if not verified"),
        TextButton(
            onPressed: () async {
              if (_OTPFormKey.currentState!.validate()) {
                PhoneAuthCredential phoneAuthController =
                    PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: OTPController.text);
                signInWithPhoneAuthCredential(phoneAuthController);
              }
            },
            child: Text("Verify"))
      ],
    );
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthController) async {
    setState(() {
      showSpinner = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthController);
      setState(() {
        showSpinner = false;
      });
      if (authCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomeUserScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showSpinner = false;
      });
      Fluttertoast.showToast(msg: e.message.toString());
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.teal,
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()));
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
            ? getMobileFormWidget(context)
            : getOTPFormWidget(context),
        padding: EdgeInsets.all(16),
      ),
    );
  }

// void singIn(String email, String password) async {
//   if (_formKey.currentState!.validate()) {
//     try {
//       await _auth
//           .signInWithEmailAndPassword(email: email, password: password)
//           .then((uid) {
//         Fluttertoast.showToast(msg: "Login Successful");
//       });
//       Navigator.pushReplacement(context,
//               MaterialPageRoute(builder: (context) => WelcomeUserScreen()))
//           .catchError((e) {
//         Fluttertoast.showToast(msg: e);
//       });
//     } catch (e) {
//       sleep(const Duration(seconds: 5));
//       showSpinner = false;
//       Fluttertoast.showToast(msg: e.toString());
//     }
//   } else {
//     Fluttertoast.showToast(
//         msg: "Please check email or password and try again");
//     showSpinner = false;
//   }
// }
}
