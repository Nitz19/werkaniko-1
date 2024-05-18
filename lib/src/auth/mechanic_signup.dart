// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:motor_rescue/src/widgets/text_widget.dart';
import 'package:motor_rescue/src/widgets/toast_widget.dart';

import '../controllers/auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class MechanicSignup extends StatefulWidget {
  const MechanicSignup({super.key});

  @override
  State<MechanicSignup> createState() => _MechanicSignupState();
}

late TextEditingController fnameController;
late TextEditingController lnameController;
late TextEditingController emailController;
late TextEditingController passwordController;
late TextEditingController addressController;
late TextEditingController phoneController;
late TextEditingController confirmpasswordController;

LocationData? currentLocation;

final _formKey = GlobalKey<FormState>();

class _MechanicSignupState extends State<MechanicSignup> {
  void getCurrentLocation() async {
    Location location = Location();

    await location.getLocation().then((location) {
      currentLocation = location;
    });
  }

  //-------validate------------------------

  bool isButtonEnabled = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fnameController.removeListener(_validateForm);
    lnameController.removeListener(_validateForm);
    emailController.removeListener(_validateForm);
    passwordController.removeListener(_validateForm);
    confirmpasswordController.removeListener(_validateForm);
    addressController.removeListener(_validateForm);
    phoneController.removeListener(_validateForm);
    fnameController.dispose();
    lnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isButtonEnabled = fnameController.text.isNotEmpty &&
          lnameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          phoneController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    isButtonEnabled = false;
    fnameController = TextEditingController();
    lnameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
    confirmpasswordController = TextEditingController();

    fnameController.addListener(_validateForm);
    lnameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    confirmpasswordController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    addressController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
  }

  late String fileName = '';

  late File imageFile;

  late String imageURL = '';

  Future<void> uploadPicture(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName = path.basename(pickedImage.path);
      imageFile = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName')
            .putFile(imageFile);
        imageURL = await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName')
            .getDownloadURL();

        setState(() {});

        Navigator.of(context).pop();
        showToast('Image uploaded!');
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  late String fileName1 = '';

  late File imageFile1;

  late String imageURL1 = '';

  Future<void> uploadPicture1(String inputSource) async {
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = (await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920))!;

      fileName1 = path.basename(pickedImage.path);
      imageFile1 = File(pickedImage.path);

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const Padding(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: AlertDialog(
                title: Row(
              children: [
                CircularProgressIndicator(
                  color: Colors.black,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  'Loading . . .',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'QRegular'),
                ),
              ],
            )),
          ),
        );

        await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName1')
            .putFile(imageFile1);
        imageURL1 = await firebase_storage.FirebaseStorage.instance
            .ref('Pictures/$fileName1')
            .getDownloadURL();

        setState(() {});

        Navigator.of(context).pop();
        showToast('Image uploaded!');
      } on firebase_storage.FirebaseException catch (error) {
        if (kDebugMode) {
          print(error);
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Sign-up',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                fontFamily: 'Bold',
              ),
            ),
            SizedBox(height: size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      maxRadius: 75,
                      minRadius: 75,
                      backgroundImage: NetworkImage(imageURL),
                    ),
                    TextButton(
                      onPressed: () {
                        uploadPicture('gallery');
                      },
                      child: TextWidget(
                        text: 'Upload ID Front',
                        fontSize: 14,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      maxRadius: 75,
                      minRadius: 75,
                      backgroundImage: NetworkImage(imageURL1),
                    ),
                    TextButton(
                      onPressed: () {
                        uploadPicture1('gallery');
                      },
                      child: TextWidget(
                        text: 'Upload ID Back',
                        fontSize: 14,
                        fontFamily: 'Bold',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: size.height * 0.03),
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
                  buildEmail(),
                  SizedBox(height: size.height * 0.03),
                  buildPassword(),
                  SizedBox(height: size.height * 0.03),
                  buildPassword1(),
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
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black),
                      ),
                      onPressed: isButtonEnabled
                          ? () => confirmpasswordController.text ==
                                  passwordController.text
                              ? _signUp(context, imageURL, imageURL1)
                              : showToast('Password do not match!')
                          : null,
                      child: const Text(
                        'SIGN-UP',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(fontSize: 15),
                ),
                GestureDetector(
                  onTap: () => GoRouter.of(context).go('/mechanicLogin'),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//-----------------------------------------------------------------

Widget buildFirstName() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          controller: fnameController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.person,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'First Name',
          ),
        ),
      ),
    ],
  );
}

//-----------------------------------------------------------

Widget buildLastName() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          controller: lnameController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.person,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Last Name',
          ),
        ),
      ),
    ],
  );
}

//-----------------------------------------------------------

Widget buildEmail() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          controller: emailController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.email,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Email',
          ),
        ),
      ),
    ],
  );
}

//-----------------------------------------------------

Widget buildPassword() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          obscureText: true,
          controller: passwordController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.lock,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Password',
          ),
        ),
      ),
    ],
  );
}

Widget buildPassword1() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          obscureText: true,
          controller: confirmpasswordController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.lock,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Confirm Password',
          ),
        ),
      ),
    ],
  );
}

//-------------------------------------------------------

Widget buildAddress() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          controller: addressController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.house,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Work Address',
          ),
        ),
      ),
    ],
  );
}

//------------------------------------------------------

Widget buildPhone() {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
          keyboardType: TextInputType.phone,
          controller: phoneController,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            icon: Icon(
              Icons.phone,
              color: Colors.blue,
              size: 30,
            ),
            hintText: 'Phone',
          ),
        ),
      ),
    ],
  );
}

//-----------------------------------------------------

Future<void> _signUp(
    BuildContext context, String imageURL, String imageURL1) async {
  if (imageURL != '' && imageURL1 != '') {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String result = await AuthMethods().signUpMechanic(
          idfront: imageURL,
          idback: imageURL1,
          fname: fnameController.text,
          lname: lnameController.text,
          email: emailController.text,
          password: passwordController.text,
          address: addressController.text,
          phone: phoneController.text,
          lat: currentLocation!.latitude,
          lng: currentLocation!.longitude);

      if (result == 'success') {
        GoRouter.of(context).go('/MechanicLogin');
      } else {
        print(result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    GoRouter.of(context).pop();
  } else {
    showToast('Please upload your ID');
  }
}
