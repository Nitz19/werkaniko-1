import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewMechanicProfile extends StatelessWidget {
  final String email;

  const NewMechanicProfile({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MechanicProfileView(email: email);
  }
}

class MechanicProfileView extends StatefulWidget {
  final String email;

  const MechanicProfileView({Key? key, required this.email}) : super(key: key);

  @override
  State<MechanicProfileView> createState() => _MechanicProfileViewState();
}

class _MechanicProfileViewState extends State<MechanicProfileView> {
  late Future<Map<String, dynamic>> _mechanicProfile;
  late String idFrontUrl = '';
  late String idBackUrl = '';

  @override
  void initState() {
    super.initState();
    _mechanicProfile = _fetchMechanicProfile();
  }

  Future<Map<String, dynamic>> _fetchMechanicProfile() async {
    final mechanicDoc = await FirebaseFirestore.instance
        .collection('Mechanics')
        .where('email', isEqualTo: widget.email)
        .get();

    if (mechanicDoc.docs.isNotEmpty) {
      final profileData = mechanicDoc.docs.first.data() as Map<String, dynamic>;
      idFrontUrl = profileData['idfront'] ?? '';
      idBackUrl = profileData['idback'] ?? '';
      return profileData;
    } else {
      throw Exception('Mechanic not found');
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _mechanicProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final profileData = snapshot.data!;
            final profileImageUrl = profileData['profileImageUrl'] ?? '';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 140,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : AssetImage('assets/images/profile.jpg') as ImageProvider,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${profileData['fname']} ${profileData['lname']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.email,
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
                      subtitle: Text(profileData['address'] ?? ''),
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
                      subtitle: Text(profileData['phone'] ?? ''),
                    ),
                    Divider(color: Colors.grey, height: 1),
                    SizedBox(height: 20),
                    Text(
                      'Rating: ${profileData['rating'] ?? 'N/A'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    // ID Images
                    Text(
                      'ID Images',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    if (idFrontUrl.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Image.network(idFrontUrl),
                            ),
                          );
                        },
                        child: Text('Show ID Front'),
                      ),
                    SizedBox(height: 10),
                    if (idBackUrl.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: Image.network(idBackUrl),
                            ),
                          );
                        },
                        child: Text('Show ID Back'),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
