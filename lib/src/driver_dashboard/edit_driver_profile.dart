import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../widgets/bottom_nav_driver.dart';

class EditDriverProfile extends StatefulWidget {
  final String? email;

  const EditDriverProfile({Key? key, this.email}) : super(key: key);

  @override
  State<EditDriverProfile> createState() => _EditDriverProfileState();
}


final FirebaseAuth auth = FirebaseAuth.instance;
final String? userEmail = auth.currentUser!.email;
String? userFname;
String? userLname;
String? userAddress;
String? userPhone;
String? userProfileImageUrl;

final fnameController = TextEditingController();
final lnameController = TextEditingController();
final emailController = TextEditingController();
final passwordController = TextEditingController();
final addressController = TextEditingController();
final phoneController = TextEditingController();

final _formKey = GlobalKey<FormState>();

class _EditDriverProfileState extends State<EditDriverProfile> {
  final CollectionReference _drivers =
  FirebaseFirestore.instance.collection('Drivers');
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${auth.currentUser!.uid}.jpg');
      final UploadTask uploadTask = storageRef.putFile(File(_image!.path));
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
      await _updateProfileImageUrl(downloadUrl);
    }
  }

  Future<void> _updateProfileImageUrl(String imageUrl) async {
    QuerySnapshot driverQuery =
    await _drivers.where("email", isEqualTo: userEmail).get();
    if (driverQuery.docs.isNotEmpty) {
      String tempId = driverQuery.docs.first.id;
      await _drivers.doc(tempId).update({"profile_image_url": imageUrl});
    }
  }

  Future<void> _editDetails(BuildContext context) async {
    QuerySnapshot driverQuery =
    await _drivers.where("email", isEqualTo: userEmail).get();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      String tempId;
      if (driverQuery.docs.isNotEmpty) {
        tempId = driverQuery.docs.first.id;

        await _drivers.doc(tempId).update({
          "fname":
          fnameController.text == "" ? userFname : fnameController.text,
          'lname':
          lnameController.text == "" ? userLname : lnameController.text,
          'address': addressController.text == ""
              ? userAddress
              : addressController.text,
          'phone': phoneController.text == "" ? userPhone : phoneController.text
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated details.'),
            backgroundColor: Colors.green,
          ),
        );

        GoRouter.of(context).pop();
        GoRouter.of(context).go('/driver');
      }
    }
  }

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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff24688e)),
        toolbarHeight: 75,
        leadingWidth: 75,
      ),
      bottomNavigationBar: BottomNavDriverWidget(),
      body: userFname == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                fontFamily: 'Gabriela-Regular',
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Divider(
              color: Colors.grey,
              height: 1,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _image == null
                    ? (userProfileImageUrl != null
                    ? NetworkImage(userProfileImageUrl!) as ImageProvider
                    : AssetImage('assets/images/profile.jpg') as ImageProvider)
                    : FileImage(File(_image!.path)) as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(child: buildFirstName()),
                      SizedBox(width: size.width * 0.03),
                      Flexible(child: buildLastName()),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  buildAddress(),
                  SizedBox(height: size.height * 0.03),
                  buildPhone(),
                  SizedBox(height: size.height * 0.03),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    height: 75,
                    child: ElevatedButton(
                      onPressed: () => _editDetails(context),
                      child: const Text(
                        'Update Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildFirstName() {
    return TextFormField(
      controller: fnameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: '$userFname',
      ),
    );
  }

  TextFormField buildLastName() {
    return TextFormField(
      controller: lnameController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: '$userLname',
      ),
    );
  }

  TextFormField buildAddress() {
    return TextFormField(
      controller: addressController,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: '$userAddress',
      ),
    );
  }

  TextFormField buildPhone() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: '$userPhone',
      ),
    );
  }
}
