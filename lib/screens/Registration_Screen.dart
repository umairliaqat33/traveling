import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:traveling/menuScreen.dart';
import 'package:traveling/models/constants.dart';
import 'package:traveling/models/user_model.dart';
import 'package:traveling/screens/Login_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:traveling/screens/welcome_screen.dart';

enum MobileVerificationState {
  SHOW_REGISTER_FORM_STATE,
  SHOW_OTP_FORM_STATE,
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final phoneController = TextEditingController();
  final L_name_Controller = TextEditingController();
  final F_name_Controller = TextEditingController();
  final OTPController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _OTPFormKey = GlobalKey<FormState>();

  bool showSpinner = false;
  String pattern = '^(?:[+0]9)?[0-9]{11}\$';
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_REGISTER_FORM_STATE;
  late String verificationId;

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
      postDetailsToFireStore(context);
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
      print(e.message.toString());
    }
  }

  getRegister(context) {
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
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      // this will be checking if we have any value in it or not?
                      return "First name is required";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  cursorColor: Colors.teal,
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  controller: F_name_Controller,
                  decoration: kMessageTextFieldDecoration.copyWith(
                    hintText: 'Enter Your First Name',
                    icon: Icon(Icons.account_circle),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      // this will be checking if we have any value in it or not?
                      return "First name is required";
                    }
                    if (value == F_name_Controller.text) {
                      return "First and last name can not b same";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  cursorColor: Colors.teal,
                  keyboardType: TextInputType.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  controller: L_name_Controller,
                  decoration: kMessageTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Last Name',
                    icon: Icon(Icons.account_circle),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  // inputFormatters: <TextInputFormatter>[
                  //   // FilteringTextInputFormatter.digitsOnly
                  // ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      // this will be checking if we have any value in it or not?
                      return "Field required";
                    }
                    if (!RegExp(pattern).hasMatch(value)) {
                      // this will be checking whether the value in it is a phone or not?
                      return "Enter a valid phone";
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                  cursorColor: Colors.teal,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                  controller: phoneController,
                  decoration: kMessageTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Phone',
                    icon: Icon(Icons.phone),
                  ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        try {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              showSpinner = true;
                            });
                            await _auth.verifyPhoneNumber(
                              phoneNumber: phoneController.text,
                              verificationCompleted:
                                  (phoneAuthCredential) async {
                                setState(() {
                                  showSpinner = false;
                                });
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            WelcomeUserScreen()));
                                Fluttertoast.showToast(msg: "Number verified");
                              },
                              verificationFailed: (verificationFailed) async {
                                // Fluttertoast.showToast(msg: verificationFailed.message.toString());
                                print(verificationFailed.message.toString());
                                Fluttertoast.showToast(
                                    msg: "Verification Failed" +
                                        verificationFailed.message.toString());
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
                                  currentState = MobileVerificationState
                                      .SHOW_OTP_FORM_STATE;
                                });
                                Fluttertoast.showToast(msg: "Code Sent");
                                print(verificationID);
                                print(resendingToken);
                              },
                              codeAutoRetrievalTimeout:
                                  (verificationId) async {},
                              timeout: Duration(seconds: 90),
                            );
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        } catch (e) {
                          print(e.toString());
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      },
                      splashColor: null,
                      minWidth: 200.0,
                      height: 42.0,
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.teal),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          splashFactory: NoSplash
                              .splashFactory //removing onclick splash color
                          ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                      },
                      child: Text(
                        "LogIn",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
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
        child: currentState == MobileVerificationState.SHOW_REGISTER_FORM_STATE
            ? getRegister(context)
            : getOTPFormWidget(context),
        padding: EdgeInsets.all(16),
      ),
    );
  }

  void SignUp(String phoneNumb) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithPhoneNumber(phoneNumb)
            .then((value) {})
            .catchError((e) {
          Fluttertoast.showToast(msg: e.toString());
          print(e.toString());
        });
      } catch (e) {
        sleep(const Duration(seconds: 5));
        showSpinner = false;
        Fluttertoast.showToast(msg: e.toString());
        print(e.toString());
      }
    } else {
      sleep(const Duration(seconds: 5));
      showSpinner = false;
    }
  }

  postDetailsToFireStore(BuildContext context) async {
    //calling our fireStore
    //calling user model
    //sending values
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();
    userModel.phone = user?.phoneNumber;
    userModel.Fname = F_name_Controller.text;
    userModel.Lname = L_name_Controller.text;
    userModel.uid = user?.uid;

    try {
      await firebaseFirestore
          .collection('users')
          .doc(user?.uid)
          .set(userModel.toMap());
      showSpinner = false;
      Fluttertoast.showToast(msg: "Account Created Successfully");
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => WelcomeUserScreen()));
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
