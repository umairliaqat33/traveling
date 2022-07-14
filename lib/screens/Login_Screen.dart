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
  MobileVerificationState currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  late String verificationId;

  final phoneController = TextEditingController();
  final OTPController = TextEditingController();
  String pattern = r'(^(?:[0]9)?[0-9]{11,12}$)';
  final _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();

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
                      // this will be checking whether the value in it is an email or not?
                      return "Enter a valid phone";
                    }
                    return null;
                  },
                  cursorColor: Colors.teal,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  controller: phoneController,
                  decoration: kMessageTextFieldDecoration.copyWith(
                    hintText: 'Enter Your phone',
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
                        setState(() {
                          showSpinner = true;
                        });
                        await _auth.verifyPhoneNumber(
                          phoneNumber: phoneController.text,
                          verificationCompleted: (phoneAuthCredential) async {
                            setState(() {
                              showSpinner = false;
                            });
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>WelcomeUserScreen()));
                          },
                          verificationFailed: (verificationFailed) async {
                            _scaffoldState.currentState!.showBottomSheet(
                              (context) => SnackBar(
                                content:
                                    Text(verificationFailed.message.toString()),
                              ),
                            );
                            Navigator.of(context).pop();
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
                              currentState=MobileVerificationState.SHOW_OTP_FORM_STATE;
                            });
                          },
                          codeAutoRetrievalTimeout: (verificationId) async {},
                        );
                        FocusManager.instance.primaryFocus?.unfocus();
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
        TextButton(
            onPressed: () async {
              PhoneAuthCredential phoneAuthController =
                  PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: OTPController.text);
              signInWithPhoneAuthCredential(phoneAuthController);
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
      _scaffoldState.currentState!.showBottomSheet((context) => SnackBar(
            content: Text(e.message.toString()),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
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
