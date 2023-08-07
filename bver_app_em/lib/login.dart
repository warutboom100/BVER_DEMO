import 'package:bver_app_em/configs/schemas.dart';
import 'package:bver_app_em/loadding.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isUsernameValid = true;
  bool _isPasswordValid = true;

  void _validateLogin() {
    setState(() {
      _isUsernameValid = _usernameController.text.isNotEmpty;
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });

    if (_isUsernameValid && _isPasswordValid) {
      _checkUsernameMatchesDeviceID();
    }
  }

  void _checkUsernameMatchesDeviceID() async {
    String enteredUsername = _usernameController.text;
    String enteredpassword = _passwordController.text;
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    bool usernameMatchesDeviceID = false;
    for (QueryDocumentSnapshot doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String documentDeviceId = data['deviceID'];

      if (documentDeviceId == enteredUsername) {
        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');
        final QuerySnapshot snapshot1 = await usersCollection
            .where('deviceID', isEqualTo: enteredUsername)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot document = snapshot1.docs.first;
          await document.reference.update({
            'status': "Online",
          });
        }
        Profile profile = Profile.getInstance();
        profile.username = enteredUsername;
        profile.passward = enteredpassword;
        profile.alertjob = false;
        usernameMatchesDeviceID = true;
        break;
      }
    }

    if (usernameMatchesDeviceID) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingPage()),
      );
    } else {
      // Username ไม่ตรงกับ deviceID
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Username is incorrect Please try again."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Login to your account",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: <Widget>[
                        inputFile(
                          label: "Username",
                          obscureText: false,
                          isValid: _isUsernameValid,
                          controller: _usernameController,
                        ),
                        inputFile(
                          label: "Password",
                          obscureText: true,
                          isValid: _isPasswordValid,
                          controller: _passwordController,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Container(
                      padding: EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.black),
                            left: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                          )),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: _validateLogin,
                        color: Color(0xFF118ab2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 100),
                    height: 200,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/Logo1.jpg"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget inputFile({
  label,
  obscureText = false,
  isValid = true,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 5),
      TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(189, 189, 189, 1)),
          ),
          errorText: isValid ? null : 'Please enter a valid $label',
          errorStyle: TextStyle(color: Colors.red),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(189, 189, 189, 1)),
          ),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}
