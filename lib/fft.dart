// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddetect/give_report.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CalculateFFT extends StatefulWidget {
  const CalculateFFT({super.key});

  @override
  State<CalculateFFT> createState() => _CalculateFFTState();
}

class _CalculateFFTState extends State<CalculateFFT> {
  late File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  String? docIDReport;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  late String fftValue;

  late bool isVisible;

  double _uploadProgress = 0.0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _pickedImage = null;
    isVisible = false;

    fftValue = "";
  }

  Future<void> requestPermissions() async {
    final PermissionStatus cameraStatus = await Permission.camera.request();
    final PermissionStatus cameraStatus2 = await Permission.photos.request();

    if (cameraStatus.isGranted && cameraStatus2.isGranted) {
      // _pickAndCropImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permission Denied'),
            content: const Text(
              'Please grant camera and gallery permissions from your device settings.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  String? urlVal;

  User? user = FirebaseAuth.instance.currentUser;

  Future<void> _uploadImage() async {
    if (_pickedImage == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    File? image = File(_pickedImage!.path);
    String fileName = image.path.split('/').last;

    final Reference storageRef = _storage.ref().child('images/$fileName.jpg');
    final UploadTask uploadTask = storageRef.putFile(File(_pickedImage!.path));

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _uploadProgress = (snapshot.bytesTransferred / snapshot.totalBytes);
      });
    }, onError: (Object e) {
      print('Error: $e');
    });

    final TaskSnapshot downloadUrl = (await uploadTask.whenComplete(() {
      setState(() {
        _isUploading = false;
      });
    }));

    urlVal = await downloadUrl.ref.getDownloadURL();
    if (urlVal!.isNotEmpty) {
      _checkFFT(urlVal!);
    }
  }

  Future<void> _pickAndCropImage(ImageSource imageSource) async {
    await requestPermissions();

    final pickedFile = await _imagePicker.pickImage(source: imageSource);

    if (pickedFile == null) {
      return;
    }

    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop the image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            statusBarColor: Colors.blue,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile == null) return;

      setState(() {
        _pickedImage = File(croppedFile.path);
      });

      setState(() {
        _pickedImage = File(croppedFile.path);
        isVisible = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error during image cropping: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_pickedImage != null)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 28.0,
                    left: 15,
                    right: 15.0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        // height: 200.0,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            30.0,
                          ),
                        ),
                        child: Card(
                          elevation: 2.0,
                          child: Center(
                            child: Image.file(
                              _pickedImage!,
                              width: 200,
                              height: 200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(
                    top: 28.0,
                    left: 15,
                    right: 15.0,
                  ),
                  child: Container(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        30.0,
                      ),
                    ),
                    child: const Card(
                      elevation: 2.0,
                      child: Center(
                        child: Text(
                          'No Image Selected',
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.only(
                  top: 30.0,
                  left: 18.0,
                  right: 18.0,
                ),
                child: Text(
                  'Take a clear picture of your nail.',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 50.0,
                  left: 18.0,
                  right: 18.0,
                ),
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            'Select Image Source',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                GestureDetector(
                                  child: const Text(
                                    'Camera',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _pickAndCropImage(ImageSource.camera);
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                ),
                                GestureDetector(
                                  child: const Text(
                                    'Gallery',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _pickAndCropImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  style: ButtonStyle(
                    side: WidgetStateProperty.all<BorderSide>(
                      const BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        'Click an Image',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isVisible,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 50.0,
                    left: 18.0,
                    right: 18.0,
                  ),
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _uploadImage();
                        },
                        style: ButtonStyle(
                          side: WidgetStateProperty.all<BorderSide>(
                            const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.blue.shade200),
                        ),
                        child: SizedBox(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width,
                          child: const Center(
                            child: Text(
                              'Upload Image',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey,
                  ),
                ),
              Visibility(
                visible: fftValue.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30.0,
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          "See Report Generated",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReportsPage(
                                  docID: docIDReport!,
                                  userID: user!.uid,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            side: WidgetStateProperty.all<BorderSide>(
                              const BorderSide(
                                color: Colors.blue,
                                width: 1.0,
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                Colors.blue.shade200),
                          ),
                          child: SizedBox(
                            height: 50.0,
                            width: MediaQuery.of(context).size.width,
                            child: const Center(
                              child: Text(
                                'See Report',
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
                        height: 50.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkFFT(String imageUrl) async {
    const String apiUrl =
        'https://adarshnagrikar11.pythonanywhere.com/calculate';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{'imageUrl': imageUrl}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String result = data['result'];
        print('Result: $result');

        setState(() {
          fftValue = result;
          isVisible = !isVisible;
        });

        _uploadReport();
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String getConclusion(String fftValue) {
    if (fftValue.isNotEmpty) {
      String valueString = fftValue.split(":")[1];
      double value = double.parse(valueString);
      print(value);

      return value > 1.8
          ? "You are likely Suffering with a disease.The nail analysis result for the nail image is more than 1.8, above the reference range. This indicates that you are suffering from liver disease and needs to consult a doctor immediately. Please Conatct the doctor with this Report."
          : "Range falls within the normal range. This indicates that you are NOT likely Suffering with a disease. Incase of further clarification, Please Conatct the doctor with this Report.";
    } else {
      return "";
    }
  }

  void _uploadReport() async {
    String imageUrl = urlVal!;
    String userName = user!.displayName!;
    String userMail = user!.email!;
    String userValues = fftValue;
    String userID = user!.uid;

    String dateTime =
        "Report ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";

    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection("Reports");

    DocumentReference docRef = await collectionRef.add({
      'Image': imageUrl,
      'Name': userName,
      "UserID": userID,
      "Values": userValues,
      "Email": userMail,
      "Date": dateTime,
    });

    String docID = docRef.id;
    setState(() {
      docIDReport = docID;
    });

    Fluttertoast.showToast(msg: "Report uploaded successfully.");
  }
}

class DataTableExample extends StatelessWidget {
  final String dataString;

  const DataTableExample({super.key, required this.dataString});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> parsedData = [];
    var parts = dataString.split(': ');
    parsedData.add({'label': parts[0], 'value': parts[1]});

    return Center(
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text(
              'Method',
              style: TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Value',
              style: TextStyle(
                  fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: parsedData.map((data) {
          return DataRow(
            cells: <DataCell>[
              DataCell(Text(data['label']!)),
              DataCell(Text(data['value']!)),
              // const DataCell(Text("")),
            ],
          );
        }).toList(),
      ),
    );
  }
}
