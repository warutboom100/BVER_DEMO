import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:bver_app_em/configs/schemas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IndoormapScreen extends StatefulWidget {
  const IndoormapScreen({Key? key}) : super(key: key);

  @override
  _IndoormapScreenState createState() => _IndoormapScreenState();
}

enum _Action { scale, pan }

const _defaultMarkerSize = 35.0;

class _IndoormapScreenState extends State<IndoormapScreen>
    with SingleTickerProviderStateMixin {
  Offset _pos =
      Offset.zero; // Position could go from -1 to 1 in both directions
  _Action? action; // pan or pinch, useful to know if we need to scale down pin
  final _transformationController = TransformationController();
  final formkey = GlobalKey<FormState>();
  List<dynamic> location_x = [1000, 1000, 1000, 1000];
  List<dynamic> location_y = [1000, 1000, 1000, 1000];
  int num = 0;
  late AnimationController controller;
  Profile profile = Profile.getInstance();
  String? offsetValue;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  Timer? timer;

  Future<dynamic> _loadUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          num = 0;
          for (final doc in snapshot.docs) {
            final user = doc.data() as Map<String, dynamic>;
            final location = user['location'] as Map<String, dynamic>;
            location_x[num] = location['x'] as int;
            location_y[num] = location['y'] as int;
            num++;
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    offsetValue = profile.passward;

    controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    // Load user markers initially

    // Start the timer to update user markers every 5 seconds
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _loadUsers();
      // location_x[0] = profile.x;
      // location_y[0] = profile.y;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final size = _defaultMarkerSize / scale;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double realme = 0.02725;
    List<double> offset = [-0.5, 0];
    // int.parse(profile.passward ?? '0')
    final x1 = location_x[0] / 100.0 + offset[0];
    // final y1 = location_y[0] * (0.3325) / 100.0 + offset[1]; 0.019 - 0.305
    // final y1 = double.parse(profile.passward ?? '0');
    final y1 = ((location_y[0] * 0.139) / 100) - 0.212;
    final x2 = location_x[1] / 100.0 + offset[0];
    final y2 = ((location_y[1] * 0.139) / 100) - 0.212;
    final x3 = location_x[2] / 100.0 + offset[0];
    final y3 = ((location_y[2] * 0.139) / 100) - 0.212;
    final x4 = location_x[3] / 100.0 + offset[0];
    final y4 = ((location_y[3] * 0.139) / 100) - 0.212;

    return Scaffold(
      body: InteractiveViewer(
        transformationController: _transformationController,
        maxScale: 5,
        minScale: 1,
        child: Stack(
          children: [
            Center(child: Image.asset('assets/maphospital.png')),
            Positioned(
              top: _pos.dy * (screenHeight / 2) +
                  (screenHeight / 2) -
                  size / 2 +
                  y1 * (screenHeight - size),
              left: _pos.dx * (screenWidth / 2) +
                  (screenWidth / 2) -
                  size / 2 +
                  x1 * (screenWidth - size),
              child: ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/pear.jpg'), // Replace with your desired image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight / 2 +
                  _pos.dy * (screenHeight / 2) -
                  size / 2 +
                  (screenHeight * y2),
              left: screenWidth / 2 +
                  _pos.dx * (screenWidth / 2) -
                  size / 2 +
                  (screenWidth * x2),
              child: ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/ratcha.jpg'), // Replace with your desired image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight / 2 +
                  _pos.dy * (screenHeight / 2) -
                  size / 2 +
                  (screenHeight * y3),
              left: screenWidth / 2 +
                  _pos.dx * (screenWidth / 2) -
                  size / 2 +
                  (screenWidth * x3),
              child: ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/big.jpg'), // Replace with your desired image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight / 2 +
                  _pos.dy * (screenHeight / 2) -
                  size / 2 +
                  (screenHeight * y4),
              left: screenWidth / 2 +
                  _pos.dx * (screenWidth / 2) -
                  size / 2 +
                  (screenWidth * x4),
              child: ClipOval(
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/boom.jpg'), // Replace with your desired image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onInteractionStart: (details) {
          // No need to call setState as we don't need to rebuild
          action = null;
        },
        onInteractionUpdate: (details) {
          if (action == null) {
            if (details.scale == 1)
              action = _Action.pan;
            else
              action = _Action.scale;
          }
          if (action == _Action.scale) {
            // Need to resize the pins so that they keep the same size
            setState(() {});
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    timer?.cancel();
  }
}
