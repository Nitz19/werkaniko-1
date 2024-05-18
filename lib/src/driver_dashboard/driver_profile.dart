// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav_driver.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({super.key});

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;
String? userFname;
String? userLname;
String? userAddress;
String? userPhone;
String? userProfileImageUrl;

class _DriverProfileState extends State<DriverProfile> {
  final CollectionReference _drivers =
  FirebaseFirestore.instance.collection('Drivers');

  Future getStatus() async {
    //--------------------get user's details--------------------------
    QuerySnapshot driverQuery =
    await _drivers.where("email", isEqualTo: userEmail).get();

    if (driverQuery.docs.isNotEmpty) {
      userFname = await driverQuery.docs.first['fname'];
      userLname = await driverQuery.docs.first['lname'];
      userAddress = await driverQuery.docs.first['address'];
      userPhone = await driverQuery.docs.first['phone'];
      userProfileImageUrl = await driverQuery.docs.first['profile_image_url'];
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
      bottomNavigationBar: BottomNavDriverWidget(),
      body: userFname == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 140,
                backgroundImage: userProfileImageUrl != null
                    ? NetworkImage(userProfileImageUrl!)
                    : AssetImage('assets/images/profile.jpg')
                as ImageProvider,
              ),
              SizedBox(
                height: 20,
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
              ElevatedButton(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final userEmail = FirebaseAuth.instance.currentUser?.email;
                  print('User email: $userEmail'); // Add this line for debugging
                  if (userEmail != null) {
                    print('Navigating to edit profile screen...');
                    router.go('/driver/driverProfile/editDriverProfile?email=$userEmail');
                  } else {
                    // Handle the case where userEmail is null
                    print('User email is null. Showing error dialog...');
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('User email is null. Please try again.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
