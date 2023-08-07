import 'package:bver_app_em/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bver_app_em/ble/ble_data.dart';
import 'package:get/get.dart';

class Scanpage_app extends StatefulWidget {
  const Scanpage_app({Key? key}) : super(key: key);

  @override
  _Scanpage_app createState() => _Scanpage_app();
}

class _Scanpage_app extends State<Scanpage_app> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final Color color1 = Color(0xffFA696C);
  final Color color2 = Color(0xffFA8165);
  final Color color3 = Color(0xffFB8964);

  var bleController = Get.put(BLEResult());
  final _pageController = PageController();
  TextEditingController textController = TextEditingController();

  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  bool isScanning = true;
  int scanMode = 1;

  // BLE value
  String deviceName = '';
  String macAddress = '';
  String rssi = '';
  String serviceUUID = '';
  String manuFactureData = '';
  String tp = '';

  var _tabScanModeIndex = 1;
  final _scanModeList = ['Low Power', 'Balanced', 'Performance'];
  @override
  void initState() {
    super.initState();
    toggleState(); // เริ่มการสแกน Bluetooth LE เมื่อหน้าจอถูกโหลด
    scan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onToggleState: toggleState),
      key: _key,
      body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            pageBLEScan(),
          ]),
    );
  }

  Center pageBLEScan() => Center(
        child:
            /* listview */
            ListView.separated(
                itemCount: bleController.scanResultList.length,
                itemBuilder: (context, index) =>
                    widgetBLEList(index, bleController.scanResultList[index]),
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider()),
      );
  Widget widgetBLEList(int index, ScanResult r) {
    toStringBLE(r);

    bleController.updateBLEList(
        deviceName: deviceName,
        macAddress: macAddress,
        rssi: rssi,
        serviceUUID: serviceUUID,
        manuFactureData: manuFactureData,
        tp: tp);
    if (macAddress == "D3:B7:A7:91:0B:FC" ||
        macAddress == "EF:43:DF:C2:9D:7B" ||
        macAddress == "E0:C6:9F:94:51:A6" ||
        macAddress == "DD:EE:07:58:61:32" ||
        macAddress == "CD:5F:0E:0D:C1:58" ||
        macAddress == "F3:66:AB:6E:ED:36") {
      bleController.flagList[index];
      bleController.updateFlagList(flag: true, index: index);
    }
    serviceUUID.isEmpty ? serviceUUID = 'null' : serviceUUID;
    manuFactureData.isEmpty ? manuFactureData = 'null' : manuFactureData;
    bool switchFlag = bleController.flagList[index];
    switchFlag ? deviceName = '$deviceName (beacon)' : deviceName;
    bleController.updateselectedDeviceIdxList();
    return ExpansionTile(
      leading: leading(r),
      title: Text(deviceName,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      subtitle: Text(macAddress,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      trailing: Text(rssi,
          style:
              TextStyle(color: switchFlag ? Colors.lightBlue : Colors.black)),
      children: <Widget>[
        ListTile(
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'UUID : $serviceUUID\nManufacture data : $manuFactureData\nTX power : ${tp == 'null' ? tp : '${tp}dBm'}',
                  style: const TextStyle(fontSize: 10),
                ),
              ]),
        )
      ],
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

  Widget leading(ScanResult r) => const CircleAvatar(
        backgroundColor: Colors.cyan,
        child: Icon(
          Icons.bluetooth,
          color: Colors.white,
        ),
      );
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
    // if (macAddress == "DD:EE:07:58:61:32") {
    //   rssi = kf.getFilteredValue(r.rssi.toDouble()).toString();
    // }
    // if (macAddress == "D3:B7:A7:91:0B:FC") {
    //   rssi = kf1.getFilteredValue(r.rssi.toDouble()).toString();
    // }
    // if (macAddress == "C8:EC:06:1D:7B:DF") {
    //   rssi = kf2.getFilteredValue(r.rssi.toDouble()).toString();
    // }
    // if (macAddress == "DF:0E:44:8D:32:C1") {
    //   rssi = kf3.getFilteredValue(r.rssi.toDouble()).toString();
    // }
  }
}
