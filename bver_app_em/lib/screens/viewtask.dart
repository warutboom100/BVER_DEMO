import 'package:bver_app_em/configs/paletts.dart';
import 'package:bver_app_em/configs/schemas.dart';
import 'package:bver_app_em/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewtaskScreen extends StatefulWidget {
  @override
  _ViewtaskScreenState createState() => _ViewtaskScreenState();
}

class _ViewtaskScreenState extends State<ViewtaskScreen> {
  Profile profile = Profile.getInstance();
  bool alert = false;
  @override
  void initState() {
    super.initState();
    alert = profile.alertjob ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.primaryColor,
      appBar: CustomAppBar1(),
      body: alert == false ? _buildBody() : _buildEmptyState(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Job> jobList = [];
          snapshot.data!.docs.forEach((doc) {
            Map<String, dynamic> data = doc.data();
            if (data['Status'] == 'notcomplete') {
              Job job = Job(
                data['ID'] ?? 0,
                data['JobsInformation']['Destination'] ?? '',
                data['JobsInformation']['PatientName'] ?? '',
                data['JobsInformation']['Priority'] ?? '',
                data['JobsInformation']['Service'] ?? '',
                data['EquipmentRequired']['Infusionpump'] ?? 0,
                data['EquipmentRequired']['Oxygentank'] ?? 0,
                data['EquipmentRequired']['Stretcher'] ?? 0,
                data['EquipmentRequired']['Walker'] ?? 0,
                data['EquipmentRequired']['Wheelchair'] ?? 0,
                data['Note'] ?? '',
                data['Date'] ?? '',
              );
              jobList.add(job);
            }
          });
          return ListView.builder(
            itemCount: jobList.length,
            itemBuilder: (context, index) {
              Job job = jobList[index];
              return _buildJobCard(job);
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildJobCard(Job job) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: ListTile(
          title: Text(
            "ID:${job.id}    " + job.destination + ("    (${job.date})"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            'Patient Name: ${job.patientName}    - Priority: ${job.priority}',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ),
        children: [
          ListTile(
            title: Text(
              'Infusion Pump: ${job.infusionPump} , Oxygen Tank: ${job.oxygenTank} , Stretcher: ${job.stretcher} \nWalker: ${job.walker} , Wheelchair: ${job.wheelchair} , Others: ...',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Note: ${job.note}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final CollectionReference usersCollection =
                      FirebaseFirestore.instance.collection('users');
                  final CollectionReference tasksCollection =
                      FirebaseFirestore.instance.collection('tasks');
                  final QuerySnapshot snapshot = await usersCollection
                      .where('deviceID', isEqualTo: profile.username ?? '')
                      .get();
                  final QuerySnapshot snapshot_task = await tasksCollection
                      .where('ID', isEqualTo: job.id)
                      .get();
                  if (snapshot.docs.isNotEmpty) {
                    final DocumentSnapshot document = snapshot.docs.first;
                    await document.reference.update({
                      'status': "Booking",
                    });
                  }
                  if (snapshot_task.docs.isNotEmpty &&
                      profile.alertjob == false) {
                    String name = "";
                    final DocumentSnapshot document = snapshot_task.docs.first;
                    for (QueryDocumentSnapshot doc in snapshot.docs) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      name = data['name'];
                    }

                    await document.reference.update({
                      'Status': "in-progress",
                      'CommitBy': name,
                      'StartTime': DateTime.now()
                          .toString()
                          .split(' ')[1]
                          .substring(0, 8),
                    });
                  }
                  profile.alertjob = true;
                  profile.taskid = job.id;
                  profile.tarketplace = job.destination;
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                ),
                child: Text('Accept'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle decline button pressed
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                child: Text('Decline'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Please complete the previous task first.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class Job {
  final int id;
  final String destination;
  final String patientName;
  final String priority;
  final String service;
  final int infusionPump;
  final int oxygenTank;
  final int stretcher;
  final int walker;
  final int wheelchair;
  final String note;
  final String date;

  Job(
    this.id,
    this.destination,
    this.patientName,
    this.priority,
    this.service,
    this.infusionPump,
    this.oxygenTank,
    this.stretcher,
    this.walker,
    this.wheelchair,
    this.note,
    this.date,
  );
}
