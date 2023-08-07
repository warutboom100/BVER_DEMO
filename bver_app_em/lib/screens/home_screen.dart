import 'dart:async';

import 'package:bver_app_em/ble/ble_data.dart';
import 'package:bver_app_em/configs/schemas.dart';
import 'package:flutter/material.dart';
import 'package:bver_app_em/widgets/widgets.dart';
import 'package:bver_app_em/configs/paletts.dart';
import 'package:bver_app_em/configs/styles.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool alert = false;
  Profile profile = Profile.getInstance();
  String? usernameValue;
  String? lastseen;
  String? targetplace;
  int rssi = 0;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    usernameValue = profile.username;
    // lastseen = profile.lastplace;
    // targetplace = profile.tarketplace;
    // alert = profile.alertjob ?? false;
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        lastseen = profile.lastplace;
        targetplace = profile.tarketplace;
        alert = profile.alertjob ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar1(),
      body: Column(
        children: [
          _buildHeader(screenHeight, alert),
          Expanded(
            child: IndoormapScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double screenHeight, bool alert) {
    final Color backgroundColor = alert
        ? Color.fromRGBO(241, 121, 113, 1)
        : Color.fromARGB(255, 132, 210, 236);
    final String textShow =
        alert ? 'Target is at ${targetplace}' : 'Now place:${lastseen}';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/urgent_icon.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    textShow,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: alert,
                child: Container(
                  height: 30, // Adjust the height of the container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromRGBO(233, 83, 72, 1),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(); // Call the method to show the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                      minimumSize:
                          Size(40, 20), // Adjust the size of the button
                    ),
                    child: Text(
                      'Enter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Adjust the font size of the text
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void updateAlert(bool newAlert) {
    setState(() {
      alert = newAlert;
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to submit job?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // ปุ่ม "Complete" ถูกกด
                Navigator.of(context)
                    .pop("complete"); // ปิด Dialog และส่งค่า true กลับ
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // สีพื้นหลังของปุ่ม "Complete"
                primary: Colors.white, // สีตัวอักษรของปุ่ม "Complete"
              ),
              child: Text('Complete'),
            ),
            TextButton(
              onPressed: () {
                // ปุ่ม "Abandon" ถูกกด
                Navigator.of(context)
                    .pop("abandon"); // ปิด Dialog และส่งค่า true กลับ
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // สีพื้นหลังของปุ่ม "Abandon"
                primary: Colors.white, // สีตัวอักษรของปุ่ม "Abandon"
              ),
              child: Text('Abandon'),
            ),
            TextButton(
              onPressed: () {
                // ปุ่ม "Back" ถูกกด
                Navigator.of(context)
                    .pop(false); // ปิด Dialog และส่งค่า false กลับ
              },
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(
                    255, 159, 164, 167), // สีพื้นหลังของปุ่ม "Back"
                primary: Colors.white, // สีตัวอักษรของปุ่ม "Back"
              ),
              child: Text('Back'),
            ),
          ],
        );
      },
    ).then((value) async {
      // รับค่าที่ส่งกลับมาจาก Dialog
      if (value == "complete") {
        profile.alertjob = false;
        updateAlert(false);
        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');
        final CollectionReference tasksCollection =
            FirebaseFirestore.instance.collection('tasks');
        final QuerySnapshot snapshot1 = await usersCollection
            .where('deviceID', isEqualTo: profile.username ?? '')
            .get();
        final QuerySnapshot snapshot = await tasksCollection
            .where('ID', isEqualTo: profile.taskid ?? 0)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot document = snapshot.docs.first;
          await document.reference.update({
            'Status': "completed",
            'FinishTime':
                DateTime.now().toString().split(' ')[1].substring(0, 8),
          });
        }
        if (snapshot1.docs.isNotEmpty) {
          final DocumentSnapshot document = snapshot1.docs.first;
          await document.reference.update({
            'status': "Online",
          });
        }
      } else if (value == "abandon") {
        updateAlert(false);
        profile.alertjob = false;
        final CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');
        final CollectionReference tasksCollection =
            FirebaseFirestore.instance.collection('tasks');
        final QuerySnapshot snapshot1 = await usersCollection
            .where('deviceID', isEqualTo: profile.username ?? '')
            .get();
        final QuerySnapshot snapshot = await tasksCollection
            .where('ID', isEqualTo: profile.taskid ?? 0)
            .get();
        if (snapshot.docs.isNotEmpty) {
          final DocumentSnapshot document = snapshot.docs.first;
          await document.reference.update({
            'Status': "cancelled",
            'FinishTime':
                DateTime.now().toString().split(' ')[1].substring(0, 8),
          });
        }
        if (snapshot1.docs.isNotEmpty) {
          final DocumentSnapshot document = snapshot1.docs.first;
          await document.reference.update({
            'status': "Online",
          });
        }
      }
    });
  }
}
