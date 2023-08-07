import 'package:flutter/material.dart';

class Profile {
  String? username;
  String? passward;
  String? lastplace;
  String? tarketplace;
  bool? alertjob;
  int? taskid;
  int? x;
  int? y;

  Profile({
    this.username,
    this.passward,
    this.alertjob,
    this.taskid,
    this.lastplace,
    this.tarketplace,
    this.x,
    this.y,
  });

  static Profile? _instance;

  static Profile getInstance() {
    _instance ??= Profile();
    return _instance!;
  }
}
