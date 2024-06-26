// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison, use_build_context_synchronously, avoid_print, avoid_init_to_null, unrelated_type_equality_checks, dead_code, prefer_is_empty

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_rescue/src/driver_dashboard/new_driver_profile.dart';
import '../widgets/bottom_nav_mechanic.dart';

class MechanicHome extends StatefulWidget {
  const MechanicHome({super.key});

  @override
  State<MechanicHome> createState() => _MechanicHomeState();
}

final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;
String? mecEmail;
String? driverEmail;
String? userName;
String? type;

class _MechanicHomeState extends State<MechanicHome> {
  late TextEditingController feeController;
  late TextEditingController descriptionController;
  late TextEditingController vehicleNumController;
  String? status;
  String docId = "";
  final CollectionReference _jobs =
      FirebaseFirestore.instance.collection('Jobs');
  final CollectionReference _mechanics =
      FirebaseFirestore.instance.collection('Mechanics');

  Future getStatus() async {
    QuerySnapshot requestsQuery = await _jobs
        .where("mechanicEmail", isEqualTo: userEmail)
        .where("jobRequestStatus", whereIn: ["requested", "accepted"]).get();

    status = "";
    if (requestsQuery.docs.isNotEmpty) {
      type = requestsQuery.docs.first['type'];
      mecEmail = requestsQuery.docs.first['mechanicEmail'];
      driverEmail = requestsQuery.docs.first['driverEmail'];
    }

    for (var document in requestsQuery.docs) {
      // status = document['jobRequestStatus'];
      // docId = document.id;

      if (document['jobRequestStatus'] == 'requested' ||
          document['jobRequestStatus'] == "") {
        status = "requested";
        docId = requestsQuery.docs.first.id;
      } else if (document['jobRequestStatus'] == 'accepted') {
        status = "accepted";
        docId = requestsQuery.docs.first.id;
      } else {
        status = "";
      }
    }

    //--------------------get user's name--------------------------

    QuerySnapshot mechanicQuery =
        await _mechanics.where("email", isEqualTo: userEmail).get();

    if (mechanicQuery.docs.isNotEmpty) {
      userName = await mechanicQuery.docs.first['fname'];
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    feeController = TextEditingController();
    descriptionController = TextEditingController();
    vehicleNumController = TextEditingController();
    getStatus();
    super.initState();
  }

  @override
  void dispose() {
    feeController.dispose();
    descriptionController.dispose();
    vehicleNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      bottomNavigationBar: BottomNavMechanicWidget(),
      body: userName == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width * 0.5),
                        child: Text(
                          'Hello... Welcome back $userName',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Bold",
                            color: Color.fromARGB(255, 3, 48, 85),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    StreamBuilder(
                      stream: _jobs
                          .where("mechanicEmail", isEqualTo: userEmail)
                          .where("jobRequestStatus", whereIn: [
                        "requested",
                        "accepted",
                        "completed"
                      ]).snapshots(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.docs.length > 0) {
                            if (snapshot.data!.docs[0]['jobRequestStatus'] ==
                                'requested') {
                              getStatus();
                              return jobRequestWidget(context);
                            } else if (snapshot.data!.docs[0]
                                    ['jobRequestStatus'] ==
                                'accepted') {
                              getStatus();
                              return currentJobWidget(context);
                            } else {
                              getStatus();
                              return emptyJobWidget(context);
                            }
                          } else {
                            getStatus();
                            return emptyJobWidget(context);
                          }
                        }
                        // if (status == 'requested') {
                        //   return jobRequestWidget(context);
                        // } else if (status == 'accepted') {
                        //   return currentJobWidget(context);
                        // } else {
                        //   return emptyJobWidget(context);
                        // }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    previousJobsWidget(context),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        profileWidget(context),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  //---------------------------------------------------------------

  Widget chatAdminWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () =>
          GoRouter.of(context).go('/mechanic/chatWithAdmin/$userName-admin'),
      child: Container(
        height: size.height * 0.15,
        width: size.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.7),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.0015),
            Text(
              'Chat Admin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Bold",
              ),
            ),
            SizedBox(height: size.height * 0.0015),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0),
                    bottom: Radius.circular(20),
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/chatAdmin.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //-------------------------------------------------------------

  Widget profileWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => GoRouter.of(context).go('/mechanic/mechanicProfile'),
      child: Container(
        height: size.height * 0.15,
        width: size.width * 0.4,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.7),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.0015),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Bold",
              ),
            ),
            SizedBox(height: size.height * 0.0015),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0),
                    bottom: Radius.circular(20),
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile1.png'),
                    //fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //------------------------------------------------------------

  Widget previousJobsWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => GoRouter.of(context).go('/mechanic/jobHistoryMechanic'),
      child: Container(
        height: size.height * 0.2,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.7),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.01),
            Text(
              'Job History',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Bold",
                  color: Colors.white),
            ),
            SizedBox(height: size.height * 0.01),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0),
                    bottom: Radius.circular(20),
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/previousJobs.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

//---------------------------------------------------------------------------

  Widget jobRequestWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.7),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Text(
            'New Job Request - 1KM away...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gabriela-Regular',
            ),
          ),
          Text(
            type!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gabriela-Regular',
            ),
          ),
          Container(
            height: size.height * 0.2,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/images/jobRequest.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            //child: Image(image: AssetImage('assets/images/vBreakdown.png')),
          ),
          SizedBox(height: size.height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    GoRouter.of(context)
                        .go('/mechanic/chatWithDriver/$driverEmail-$mecEmail');
                  },
                  splashColor: Colors.grey.withOpacity(0.5),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3.5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.chat, size: 40, color: Colors.blue),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 90),
                          child: Text(
                            'Chat With Driver',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.025),
                InkWell(
                  onTap: () {
                    try {
                      _jobs.doc(docId).update({
                        "jobRequestStatus": "accepted",
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Job Request Accepted.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      //setState(() {});
                      //getStatus();
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  splashColor: Colors.grey.withOpacity(0.5),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3.5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.done, size: 40, color: Colors.green),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 90),
                          child: Text(
                            'Accept the Job',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.025),
                InkWell(
                  onTap: () async {
                    try {
                      await _jobs.doc(docId).update({
                        "jobRequestStatus": "declined",
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Job Request Declined.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // getStatus();
                      //setState(() {});
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  splashColor: Colors.grey.withOpacity(0.5),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3.5, color: Colors.blue),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.close, size: 40, color: Colors.red),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 90),
                          child: Text(
                            'Decline the Job',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //---------------------------------------------------------------------------------

  Widget currentJobWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.7),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 0.02),
          Text(
            'Current Job',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Gabriela-Regular',
            ),
          ),
          Container(
            height: size.height * 0.2,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                  image: AssetImage('assets/images/jobRequest.jpg'),
                  fit: BoxFit.cover),
            ),
            //child: Image(image: AssetImage('assets/images/vBreakdown.png')),
          ),
          SizedBox(height: size.height * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      GoRouter.of(context).go(
                          '/mechanic/chatWithDriver/$driverEmail-$mecEmail');
                    },
                    splashColor: Colors.grey.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3.5, color: Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.chat, size: 40, color: Colors.blue),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 90),
                            child: Text(
                              'Chat With Driver',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.025),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewDriverProfile(
                                email: driverEmail!,
                              )));
                    },
                    splashColor: Colors.grey.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3.5, color: Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.person, size: 40, color: Colors.blue),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 90),
                            child: Text(
                              'Driver Profile',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.025),
                  InkWell(
                    onTap: () {
                      GoRouter.of(context).go('/mechanic/directions');
                    },
                    splashColor: Colors.grey.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3.5, color: Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.navigation, size: 40, color: Colors.blue),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 90),
                            child: Text(
                              'Get Directions',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.025),
                  InkWell(
                    onTap: () {
                      try {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Job Details'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: vehicleNumController,
                                    decoration: InputDecoration(
                                        labelText: 'Vehicle Number'),
                                  ),
                                  TextField(
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                        labelText: 'Description'),
                                  ),
                                  TextField(
                                    controller: feeController,
                                    decoration:
                                        InputDecoration(labelText: 'Fee'),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    _jobs
                                        .doc(docId)
                                        .update({"fee": feeController.text});
                                    _jobs.doc(docId).update({
                                      "description": descriptionController.text,
                                    });
                                    _jobs.doc(docId).update({
                                      "vehicle": vehicleNumController.text,
                                    });
                                    _jobs.doc(docId).update({
                                      "jobRequestStatus": "completed",
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Job Completed.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Submit'),
                                ),
                              ],
                            );
                          },
                        );
                        //setState(() {});
                        //getStatus();
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    splashColor: Colors.grey.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(width: 3.5, color: Colors.blue),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.done, size: 40, color: Colors.green),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 90),
                            child: Text(
                              'Job Completed',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //------------------input fields when completing the job------------------

  Widget buildFee() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          height: 60,
          child: TextField(
            keyboardType: TextInputType.text,
            controller: feeController,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.email,
                color: Color(0xff5ac18e),
                size: 30,
              ),
              hintText: 'Email',
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
              ),
            ],
          ),
          height: 60,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            controller: descriptionController,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.email,
                color: Color(0xff5ac18e),
                size: 30,
              ),
              hintText: 'Email',
            ),
          ),
        ),
      ],
    );
  }

  //-------------------------------------------------------------------------

  Widget emptyJobWidget(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.33,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.7),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(0),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01),
                Text(
                  'No jobs at the moment   :(',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Gabriela-Regular',
                  ),
                ),
                SizedBox(height: size.height * 0.01),
              ],
            ),
          ),
          Container(
            height: size.height * 0.2,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(0),
                bottom: Radius.circular(20),
              ),
              image: const DecorationImage(
                  image: AssetImage('assets/images/jobRequest.jpg'),
                  fit: BoxFit.cover),
            ),
            //child: Image(image: AssetImage('assets/images/vBreakdown.png')),
          ),
          SizedBox(height: size.height * 0.01),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Check again in few minutes',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (mounted) {
                      //setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      side: BorderSide(width: 3, color: Colors.blue),
                      elevation: 15),
                  child: Text(
                    'Refresh',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
