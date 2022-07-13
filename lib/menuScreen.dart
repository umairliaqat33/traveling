import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:traveling/models/RoundButton.dart';
import 'package:traveling/screens/Login_Screen.dart';
import 'package:traveling/screens/Registration_Screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    animation = ColorTween(
      begin: Color(0x183B59),
      end: Colors.white,
    ).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: animation.value,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        child: Hero(
                          tag: 'logo',
                          child:
                              Image.asset('assets/images/Traveling_logo.png'),
                        ),
                      ),
                      Text(
                        "Traveller",
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      )
                    ],
                  ),
                  AnimatedTextKit(animatedTexts: [
                    WavyAnimatedText(
                      'Let \'s Explore!!!!!!',
                      speed: Duration(milliseconds: 100),
                      textStyle: TextStyle(fontSize: 25, color: Colors.teal),
                    ),
                  ])
                ],
              ),
              SizedBox(
                height: 48.0,
              ),
              RoundedButton(Colors.teal, 'Registration', () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegistrationScreen()));
              }),
              SizedBox(
                height: 8.0,
              ),
              RoundedButton(Colors.blueGrey, 'Login', () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
