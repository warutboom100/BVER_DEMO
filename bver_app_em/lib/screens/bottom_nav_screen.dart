import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bver_app_em/ble/scanpage.dart';
import 'package:bver_app_em/configs/schemas.dart';
import 'package:bver_app_em/screens/screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bver_app_em/ble/ble_data.dart';
import 'package:get/get.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({Key? key}) : super(key: key);
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List<Widget> _screens = [
    StatsScreen(),
    HomeScreen(),
    ViewtaskScreen(),
    Scanpage_app(),
    Scaffold(),
  ];
  int _currentIndex = 0;
  Profile profile = Profile.getInstance();
  String? usernameValue;
  var bleController = Get.put(BLEResult());
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = true;
  int scanMode = 1;
  List<dynamic> rssi_data = [-999.0, -999.0, -999, -999, -999.0, -999, -999];
  List<dynamic> mac_data = ['', '', '', '', '', '', ''];
  // BLE value
  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';
  Timer? timer;
  @override
  void initState() {
    super.initState();
    usernameValue = profile.username;
    toggleState(); // เริ่มการสแกน Bluetooth LE เมื่อหน้าจอถูกโหลด
    scan();

    timer = Timer.periodic(Duration(milliseconds: 3000), (timer) {
      setState(() {
        sendlocation();
        sendlocation_http();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    int itemcount = bleController.scanResultList.length;
    for (int idx = 0; idx < itemcount; idx++) {
      toStringBLE(bleController.scanResultList[idx]);
      // if ( //(macAddress == "D3:B7:A7:91:0B:FC" ||
      //     //     macAddress == "EF:43:DF:C2:9D:7B" ||
      //     macAddress == "E0:C6:9F:94:51:A6" || //beacon0
      //         macAddress == "DD:EE:07:58:61:32" || //beacon3
      //         macAddress == "CD:5F:0E:0D:C1:58" || //beacon5
      //         macAddress == "F3:66:AB:6E:ED:36") {
      //   //beacon6
      //   bleController.updateBLEList(
      //       deviceName: deviceName,
      //       macAddress: macAddress,
      //       rssi: rssi,
      //       serviceUUID: serviceUUID,
      //       manuFactureData: manuFactureData,
      //       tp: tp);
      // }
      if (macAddress == "E0:C6:9F:94:51:A6") {
        //0
        // ทำ something
        mac_data[0] = macAddress;
        rssi_data[0] = rssi;
      } else if (macAddress == "DD:EE:07:58:61:32") {
        //3
        mac_data[1] = macAddress;
        rssi_data[1] = rssi;
        // ทำ something
      } else if (macAddress == "C8:EC:06:1D:7B:DF") {
        //beacon4
        mac_data[2] = macAddress;
        rssi_data[2] = rssi;
        // ทำ something
      } else if (macAddress == "CD:5F:0E:0D:C1:58") {
        //5
        mac_data[3] = macAddress;
        rssi_data[3] = rssi;
        // ทำ something
      } else if (macAddress == "F3:66:AB:6E:ED:36") {
        //6
        mac_data[4] = macAddress;
        rssi_data[4] = rssi;
      } else if (macAddress == "DF:0E:44:8D:32:C1") {
        //7
        mac_data[5] = macAddress;
        rssi_data[5] = rssi;
      } else if (macAddress == "C9:8E:E2:64:45:CC") {
        //5D
        mac_data[6] = macAddress;
        rssi_data[6] = rssi;
      }
    }
    // sendlocation();

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        elevation: 0.0,
        items: [
          Icons.home,
          Icons.navigation_rounded,
          Icons.event_note,
          Icons.info,
        ]
            .asMap()
            .map(
              (key, value) => MapEntry(
                key,
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: _currentIndex == key
                          ? Color(0xFF118ab2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Icon(value),
                  ),
                  label: '', // Empty label
                ),
              ),
            )
            .values
            .toList(),
      ),
    );
  }

  void toggleState() {
    if (isScanning) {
      flutterBlue.startScan(
          scanMode: ScanMode(scanMode), allowDuplicates: true);
      scan();
    } else {
      flutterBlue.stopScan();
      bleController.initBLEList();
    }
    setState(() {});
  }

  void scan() async {
    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      bleController.scanResultList = results;
      // update state
      setState(() {});
    });
  }

  String deviceNameCheck(ScanResult r) {
    String name;

    if (r.device.name.isNotEmpty) {
      // Is device.name
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      // Is advertisementData.localName
      name = r.advertisementData.localName;
    } else {
      // null
      name = 'N/A';
    }
    return name;
  }

  void toStringBLE(ScanResult r) {
    deviceName = deviceNameCheck(r);
    macAddress = r.device.id.id;

    serviceUUID = r.advertisementData.serviceUuids
        .toString()
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '');
    manuFactureData = r.advertisementData.manufacturerData
        .toString()
        .replaceAll('{', '')
        .replaceAll('}', '');
    tp = r.advertisementData.txPowerLevel.toString();
    rssi = r.rssi.toString();
  }

  void sendlocation() async {
    // var user = [
    //   {"E0:C6:9F:94:51:A6": -90},
    //   {"DD:EE:07:58:61:32": -71},
    //   {"CD:5F:0E:0D:C1:58": -55},
    //   {"F3:66:AB:6E:ED:36": -86}
    // ];

    var user = [
      {mac_data[0]: rssi_data[0]},
      {mac_data[1]: rssi_data[1]},
      {mac_data[2]: rssi_data[2]},
      {mac_data[3]: rssi_data[3]},
      {mac_data[4]: rssi_data[4]},
      {mac_data[5]: rssi_data[5]},
      {mac_data[6]: rssi_data[6]}
    ];
    user.sort((a, b) => a.values.first.compareTo(b.values.first));
    var location = [0, 0];
    String place = "";
    if (user.first.keys.first == "E0:C6:9F:94:51:A6") {
      //0
      // ทำ something
      location = [10, 50];
      place = "VIP(Room 12)";
    } else if (user.first.keys.first == "DD:EE:07:58:61:32") {
      //3
      // ทำ something
      location = [26, 52];
      place = "VIP(Room 15)";
    } else if (user.first.keys.first == "C8:EC:06:1D:7B:DF") {
      //4
      // ทำ something
      location = [43, 48];
      place = "Nurse Station";
    } else if (user.first.keys.first == "CD:5F:0E:0D:C1:58") {
      //5
      // ทำ something
      location = [71, 64];
      place = "XLVIP(Room 22)";
    } else if (user.first.keys.first == "F3:66:AB:6E:ED:36") {
      //6
      location = [88, 52];
      place = "XXLVIP(Room 25)";
    } else if (user.first.keys.first == "DF:0E:44:8D:32:C1") {
      //7
      location = [90, 93];
      place = "Service hall";
    } else if (user.first.keys.first == "C9:8E:E2:64:45:CC") {
      //5d
      location = [57, 28];
      place = "Elevator hall";
    }
    profile.lastplace = place;
    var maxValue =
        user.first.values.first; // ตัวแปรที่เก็บค่าของค่าที่มากที่สุด
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    // ค้นหาเอกสารที่มี deviceid ตรงกับ key ของค่าที่มากที่สุด
    final QuerySnapshot snapshot = await usersCollection
        .where('deviceID', isEqualTo: usernameValue ?? '')
        .get();

    if (snapshot.docs.isNotEmpty) {
      // หากมีเอกสารที่ตรงกับเงื่อนไข
      final DocumentSnapshot document = snapshot.docs.first;
      print('พบเอกสารที่มี deviceid ตรงกับ key ที่มากที่สุด');
      // อัปเดตค่า rssi ในฟิลด์ location
      await document.reference.update({
        'location.x': location[0],
        'location.y': location[1],
        'lastupdate': DateTime.now().toString().split(' ')[1].substring(0, 8),
        'origin': place
      });
    } else {
      // หากไม่พบเอกสารที่ตรงกับเงื่อนไข
      print('ไม่พบเอกสารที่มี deviceid ตรงกับ key ที่มากที่สุด');
    }
  }

  void sendlocation_http() async {
    // var user = [
    //   {"E0:C6:9F:94:51:A6": -90},
    //   {"DD:EE:07:58:61:32": -71},
    //   {"CD:5F:0E:0D:C1:58": -55},
    //   {"F3:66:AB:6E:ED:36": -86}
    // ];

    var user = [
      {mac_data[0]: rssi_data[0]},
      {mac_data[1]: rssi_data[1]},
      {mac_data[2]: rssi_data[2]},
      {mac_data[3]: rssi_data[3]},
      {mac_data[4]: rssi_data[4]},
      {mac_data[5]: rssi_data[5]},
      {mac_data[6]: rssi_data[6]}
    ];
    user.sort((a, b) => a.values.first.compareTo(b.values.first));
    var location = [0, 0];
    String place = "";
    if (user.first.keys.first == "E0:C6:9F:94:51:A6") {
      //0
      // ทำ something
      location = [10, 50];
      place = "VIP(Room 12)";
    } else if (user.first.keys.first == "DD:EE:07:58:61:32") {
      //3
      // ทำ something
      location = [26, 52];
      place = "VIP(Room 15)";
    } else if (user.first.keys.first == "C8:EC:06:1D:7B:DF") {
      //4
      // ทำ something
      location = [43, 48];
      place = "Nurse Station";
    } else if (user.first.keys.first == "CD:5F:0E:0D:C1:58") {
      //5
      // ทำ something
      location = [71, 64];
      place = "XLVIP(Room 22)";
    } else if (user.first.keys.first == "F3:66:AB:6E:ED:36") {
      //6
      location = [88, 52];
      place = "XXLVIP(Room 25)";
    } else if (user.first.keys.first == "DF:0E:44:8D:32:C1") {
      //7
      location = [90, 93];
      place = "Service hall";
    } else if (user.first.keys.first == "C9:8E:E2:64:45:CC") {
      //5d
      location = [57, 28];
      place = "Elevator hall";
    }
    profile.lastplace = place;
    profile.x = location[0];
    profile.y = location[1];
    Map data = {
      "lastplace": place,
      "x": location[0],
      "y": location[1],
      "timestamp": DateTime.now().toString().split(' ')[1].substring(0, 8)
    };

    String body = json.encode(data);

    var response = await http.post(
      Uri.parse('https://a1b62c0da8b2.ngrok.app/postexcel'),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    int counter = response.statusCode;
    return Future.value(counter);
  }

  void updateStatus() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');
    final QuerySnapshot snapshot1 =
        await usersCollection.where('deviceID', isEqualTo: usernameValue).get();
    final DocumentSnapshot document = snapshot1.docs.first;
    await document.reference.update({
      'status': "Offline",
    });
  }
}
