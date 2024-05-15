// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav_mechanic.dart';

class NewMechanicProfile extends StatefulWidget {
  String email;

  NewMechanicProfile({super.key, required this.email});

  @override
  State<NewMechanicProfile> createState() => _NewMechanicProfileState();
}

final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;
String? userFname;
String? userLname;
String? userAddress;
String? userPhone;
double ratings = 0;

class _NewMechanicProfileState extends State<NewMechanicProfile> {
  final CollectionReference _mechanics =
      FirebaseFirestore.instance.collection('Mechanics');
  Future getStatus() async {
    //--------------------get user's details--------------------------

    QuerySnapshot mechanicQuery =
        await _mechanics.where("email", isEqualTo: widget.email).get();

    if (mechanicQuery.docs.isNotEmpty) {
      userFname = await mechanicQuery.docs.first['fname'];
      userLname = await mechanicQuery.docs.first['lname'];
      userAddress = await mechanicQuery.docs.first['address'];
      userPhone = await mechanicQuery.docs.first['phone'];
      ratings = await mechanicQuery.docs.first['rating'];
    }
    if (mounted) {
      setState(() {});
    }
  }

  //----------------------------------------------

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff24688e)),
        toolbarHeight: 75,
        leadingWidth: 75,
      ),
      bottomNavigationBar: BottomNavMechanicWidget(),
      body: userFname == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 118,
                      backgroundImage: AssetImage('assets/images/profile.jpg'),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '☆ $ratings',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.amber),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '$userFname $userLname',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '$userEmail',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(
                        'Address',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('$userAddress'),
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 1,
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(
                        'Phone',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text('$userPhone'),
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 1,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
