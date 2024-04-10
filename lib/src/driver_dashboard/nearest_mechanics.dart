// ignore_for_file: prefer_const_constructors, unused_local_variable, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:motor_rescue/src/widgets/bottom_nav_driver.dart';
import 'package:motor_rescue/src/widgets/toast_widget.dart';

class NearestMechanics extends StatefulWidget {
  const NearestMechanics({super.key});

  @override
  State<NearestMechanics> createState() => _NearestMechanicsState();
}

LocationData? currentLocation;
String mecEmail = "";
double dis = 0;

final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;

class _NearestMechanicsState extends State<NearestMechanics> {
  final CollectionReference _mechanics =
      FirebaseFirestore.instance.collection('Mechanics');
  final CollectionReference _jobs =
      FirebaseFirestore.instance.collection('Jobs');
  DateTime currentDate = DateTime.now();

  void getCurrentLocation() async {
    Location location = Location();

    await location.getLocation().then((location) {
      currentLocation = location;
    });
  }

  void getNearestMechanics() async {
    getCurrentLocation();
    QuerySnapshot requestsQuery = await _mechanics.get();

    for (var document in requestsQuery.docs) {
      dis = Geolocator.distanceBetween(document['lat'], document['lng'],
          currentLocation!.latitude!, currentLocation!.longitude!);
      dis = double.parse((dis / 1000).toStringAsExponential(2));
      await _mechanics.doc(document.id).update({'distance': dis});
    }
  }

  bool hasLoaded = false;

  double lat = 0;
  double lng = 0;

  void getLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      lat = location.latitude!;
      lng = location.longitude!;
      //currentLocation = location;
      //sourceLocation = location;
    });

    setState(() {
      hasLoaded = true;
    });
  }

  @override
  void initState() {
    determinePosition();
    // getNearestMechanics();
    getLocation();
    super.initState();
  }

  List<String> carIssues = [
    'Out of Fuel',
    'Engine malfunction',
    'Tire puncture',
    'Battery failure',
    'Transmission issues',
    'Brake system malfunction',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff24688e)),
        toolbarHeight: 75,
        leadingWidth: 75,
      ),
      bottomNavigationBar: BottomNavDriverWidget(),
      body: hasLoaded
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Text(
                        'Available mechanics near you',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gabriela-Regular",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  StreamBuilder(
                    stream: _mechanics
                        .orderBy('distance', descending: false)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        return SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: GoogleMap(
                            markers: {
                              for (int i = 0;
                                  i < streamSnapshot.data!.docs.length;
                                  i++)
                                Marker(
                                  infoWindow: InfoWindow(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: SizedBox(
                                                  height: 400,
                                                  width: 400,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: GridView.builder(
                                                      itemCount:
                                                          carIssues.length,
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  2),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () async {
                                                            QuerySnapshot requestsQuery = await _jobs
                                                                .where(
                                                                    "mechanicEmail",
                                                                    isEqualTo: streamSnapshot
                                                                            .data!
                                                                            .docs[i]
                                                                        [
                                                                        'email'])
                                                                .where(
                                                                    "jobRequestStatus",
                                                                    whereIn: [
                                                                  "requested",
                                                                  "accepted"
                                                                ]).get();

                                                            if (requestsQuery
                                                                .docs.isEmpty) {
                                                              if (userEmail !=
                                                                  null) {
                                                                try {
                                                                  QuerySnapshot
                                                                      eventsQuery =
                                                                      await _mechanics
                                                                          .where(
                                                                              "email",
                                                                              isEqualTo: streamSnapshot.data!.docs[i]['email'])
                                                                          .get();

                                                                  for (var document
                                                                      in eventsQuery
                                                                          .docs) {
                                                                    mecEmail =
                                                                        document[
                                                                            'email'];
                                                                  }
                                                                  print(
                                                                      mecEmail);
                                                                  print(
                                                                      userEmail);
                                                                  final json = {
                                                                    'type':
                                                                        carIssues[
                                                                            index],
                                                                    'driverEmail':
                                                                        userEmail,
                                                                    'mechanicEmail':
                                                                        mecEmail,
                                                                    'jobRequestStatus':
                                                                        'requested',
                                                                    'latitude':
                                                                        lat,
                                                                    'longitude':
                                                                        lng,
                                                                    'distance':
                                                                        dis,
                                                                    'date': DateTime(
                                                                            currentDate
                                                                                .year,
                                                                            currentDate
                                                                                .month,
                                                                            currentDate
                                                                                .day)
                                                                        .toLocal()
                                                                        .toString()
                                                                        .split(
                                                                            ' ')[0],
                                                                    'time':
                                                                        "${currentDate.hour} : ${currentDate.minute}",
                                                                    'rating':
                                                                        null,
                                                                    'feedback':
                                                                        null,
                                                                    'fee': null
                                                                  };
                                                                  await _jobs
                                                                      .doc()
                                                                      .set(
                                                                          json);
                                                                } catch (e) {
                                                                  print(e);
                                                                }
                                                              } else {
                                                                showToast(
                                                                    'Please turn on your phones location!');
                                                              }
                                                              GoRouter.of(
                                                                      context)
                                                                  .pushReplacement(
                                                                      '/driver');
                                                            } else {
                                                              print(
                                                                  'already sent request');
                                                            }
                                                          },
                                                          child: Card(
                                                            elevation: 5,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .car_repair,
                                                                  size: 75,
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  carIssues[
                                                                      index],
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )),
                                            );
                                          },
                                        );
                                      },
                                      title: streamSnapshot.data!.docs[i]
                                          ['fname'],
                                      snippet:
                                          'Distance: ${streamSnapshot.data!.docs[i]['distance']}km'),
                                  markerId: MarkerId('currentLocation'),
                                  icon: BitmapDescriptor.defaultMarker,
                                  position: LatLng(
                                      streamSnapshot.data!.docs[i]['lat'],
                                      streamSnapshot.data!.docs[i]['lng']),
                                ),
                            },
                            mapType: MapType.normal,
                            initialCameraPosition: CameraPosition(
                                target: LatLng(lat, lng), zoom: 12),
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
