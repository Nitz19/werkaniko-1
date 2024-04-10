// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, override_on_non_overriding_member, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:motor_rescue/src/landing.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;

String? userName;

class BottomNavDriverWidget extends StatelessWidget {
  BottomNavDriverWidget({
    super.key,
  });

  //--------------------get user's name--------------------------
  final CollectionReference _drivers =
      FirebaseFirestore.instance.collection('Drivers');

  Future getChat(BuildContext context) async {
    QuerySnapshot driverQuery =
        await _drivers.where("email", isEqualTo: userEmail).get();

    if (driverQuery.docs.isNotEmpty) {
      userName = await driverQuery.docs.first['fname'];
    }

    GoRouter.of(context).go('/driver/chatWithAdmin/$userName-admin');
  }

  //-------------------- signout ------------------------
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    () {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                      fontFamily: 'QBold', fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Are you sure you want to Logout?',
                  style: TextStyle(fontFamily: 'QRegular'),
                ),
                actions: <Widget>[
                  MaterialButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                          fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const LandingWidget()));
                    },
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                          fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ));
    };
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.blue.shade700,
            padding: EdgeInsets.all(10),
            gap: 5,
            onTabChange: (index) {
              switch (index) {
                case 0:
                  GoRouter.of(context).go('/driver');
                  break;
                case 1:
                  GoRouter.of(context).go('/driver/driverProfile');
                  break;
                case 2:
                  _signOut(context);

                  break;
                default:
                  GoRouter.of(context).go('/driver');
              }
            },
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Home',
                iconSize: 30,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
                iconSize: 30,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                              'Logout Confirmation',
                              style: TextStyle(
                                  fontFamily: 'QBold',
                                  fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              'Are you sure you want to Logout?',
                              style: TextStyle(fontFamily: 'QRegular'),
                            ),
                            actions: <Widget>[
                              MaterialButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                      fontFamily: 'QRegular',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LandingWidget()));
                                },
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                      fontFamily: 'QRegular',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ));
                },
                icon: Icons.logout,
                text: 'Logout',
                iconSize: 30,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
