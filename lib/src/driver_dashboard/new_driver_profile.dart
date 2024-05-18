import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/bottom_nav_driver.dart';

class NewDriverProfile extends StatefulWidget {
  final String email;

  NewDriverProfile({super.key, required this.email});

  @override
  State<NewDriverProfile> createState() => _NewDriverProfileState();
}

class _NewDriverProfileState extends State<NewDriverProfile> {
  final CollectionReference _drivers = FirebaseFirestore.instance.collection('Drivers');
  String? userFname;
  String? userLname;
  String? userAddress;
  String? userPhone;
  String? profileImageUrl;

  Future<void> getStatus() async {
    print('Fetching driver data for email: ${widget.email}'); // Debug print

    QuerySnapshot driverQuery = await _drivers.where("email", isEqualTo: widget.email).get();

    if (driverQuery.docs.isNotEmpty) {
      var driverData = driverQuery.docs.first.data() as Map<String, dynamic>;
      userFname = driverData['fname'];
      userLname = driverData['lname'];
      userAddress = driverData['address'];
      userPhone = driverData['phone'];
      profileImageUrl = driverData['profile_image_url']; // Correct field name

      print('Driver Data: $driverData'); // Print entire driver data
      print('Driver Profile Image URL: $profileImageUrl'); // Debug print
    } else {
      print('No driver found with email: ${widget.email}');
    }
    if (mounted) {
      setState(() {});
    }
  }

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
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
                    : AssetImage('assets/images/profile.jpg') as ImageProvider,
              ),
              SizedBox(height: 20),
              Text(
                '$userFname $userLname',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                widget.email, // Displaying widget.email for verification
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey, height: 1),
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
              Divider(color: Colors.grey, height: 1),
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
              Divider(color: Colors.grey, height: 1),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
