// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddetect/splashscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddDetails extends StatefulWidget {
  const AddDetails({super.key});

  @override
  State<AddDetails> createState() => _AddDetailsState();
}

class _AddDetailsState extends State<AddDetails> {
  TextEditingController userName = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController dobController = TextEditingController();
  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    setState(() {
      userName.text = user!.displayName!;
    });
  }

  @override
  void dispose() {
    dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                top: 25.0,
                left: 20.0,
              ),
              child: Text(
                "Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 18.0,
                left: 18.0,
                right: 18.0,
              ),
              child: TextField(
                controller: userName,
                decoration: InputDecoration(
                  labelText: "Name",
                  enabled: false,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 25.0,
                left: 20.0,
              ),
              child: Text(
                "Select Date of Birth",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 18.0,
                left: 18.0,
                right: 18.0,
                bottom: 18.0,
              ),
              child: TextField(
                controller: dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: "Select your date of birth",
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 25.0,
                left: 20.0,
              ),
              child: Text(
                "Select Gender",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 18.0,
                left: 18.0,
                right: 18.0,
                bottom: 50.0,
              ),
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                hint: const Text("Select your gender"),
                onChanged: (newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                items: genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.green,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: OutlinedButton(
                onPressed: () => insertData(),
                style: ButtonStyle(
                  side: WidgetStateProperty.all<BorderSide>(
                    const BorderSide(
                      color: Colors.blue,
                      width: 1.0,
                    ),
                  ),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.blue.shade200),
                ),
                child: SizedBox(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                    child: Text(
                      'Upload Details',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 100.0,
            )
          ],
        ),
      ),
    );
  }

  Future<void> addDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("detailsAdded", true);
  }

  void insertData() async {
    if (userName.text.isEmpty ||
        dobController.text.isEmpty ||
        selectedGender == null) {
      Fluttertoast.showToast(msg: "Enter Data Please");
    } else {
      _showProgressDialog();

      DocumentReference collectionRef =
          FirebaseFirestore.instance.collection("UserDetails").doc(user!.uid);

      await collectionRef.set({
        'Name': userName.text,
        'DOB': dobController.text,
        'Gender': selectedGender,
      });

      Fluttertoast.showToast(msg: "Item uploaded successfully.");
      addDetails();
      Navigator.of(context).pop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Splashscreen()),
      );
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 25.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 50),
                Text(
                  'Uploading...',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
