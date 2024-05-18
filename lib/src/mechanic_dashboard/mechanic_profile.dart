// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../driver_dashboard/driver_home.dart';
import '../widgets/bottom_nav_mechanic.dart';

class MechanicProfile extends StatefulWidget {
  const MechanicProfile({Key? key}) : super(key: key);

  @override
  State<MechanicProfile> createState() => _MechanicProfileState();
}

final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;
String? userFname;
String? userLname;
String? userAddress;
String? userPhone;
String? profileImageUrl;

class _MechanicProfileState extends State<MechanicProfile> {
  final CollectionReference _mechanics =
  FirebaseFirestore.instance.collection('Mechanics');

  Future getStatus() async {
    QuerySnapshot mechanicQuery =
    await _mechanics.where("email", isEqualTo: userEmail).get();

    if (mechanicQuery.docs.isNotEmpty) {
      userFname = mechanicQuery.docs.first['fname'];
      userLname = mechanicQuery.docs.first['lname'];
      userAddress = mechanicQuery.docs.first['address'];
      userPhone = mechanicQuery.docs.first['phone'];
      profileImageUrl = mechanicQuery.docs.first['profileImageUrl'];
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

// Method to handle QR code upload
  Future<void> _uploadQRCode() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the picked image to Firebase Storage
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('qr_codes/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await firebaseStorageRef.putFile(File(pickedFile.path));

      // Get the download URL of the uploaded image
      String qrCodeUrl = await firebaseStorageRef.getDownloadURL();

      // Update the Firestore document with the URL of the uploaded QR code image
      QuerySnapshot mechanicQuery = await _mechanics.where("email", isEqualTo: userEmail).get();
      if (mechanicQuery.docs.isNotEmpty) {
        String mechanicId = mechanicQuery.docs.first.id; // Get the document ID
        await FirebaseFirestore.instance
            .collection('Mechanics')
            .doc(mechanicId)
            .update({'gcashQrCodeUrl': qrCodeUrl})
            .then((value) {
          print("QR code uploaded successfully");
        }).catchError((error) {
          print("Failed to upload QR code: $error");
        });
      } else {
        print("Error: Mechanic document not found");
      }
    } else {
      // User canceled picking an image
      print('No QR code image selected.');
    }
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
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl!)
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
                onPressed: () {
                  GoRouter.of(context).go(
                      '/mechanic/mechanicProfile/editMechanicProfile');
                },
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: _uploadQRCode, // Call the upload method
                child: const Text(
                  'Upload QR Code',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
