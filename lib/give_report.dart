import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  final String docID;
  final String userID;
  const ReportsPage({
    super.key,
    required this.docID,
    required this.userID,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? name, dob, gender, rDate, rID, age;

  String? email, image, values;

  String? inference = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      name = "";
      dob = "";
      gender = "";
      rDate = "--------------";
      age = "";
      rID = widget.docID;

      email = "";
      image =
          "https://plus.unsplash.com/premium_photo-1683865776032-07bf70b0add1?q=80&w=1932&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";
      values = "----------------";
    });
    fetchDataUser();
    fetchDataReport();
  }

  void fetchDataUser() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("UserDetails")
        .doc(widget.userID)
        .get();

    if (snapshot.exists) {
      setState(() {
        name = snapshot['Name'];
        dob = snapshot['DOB'];
        gender = snapshot['Gender'];
      });

      getAge(dob);
    }
  }

  void fetchDataReport() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("Reports")
        .doc(widget.docID)
        .get();

    if (snapshot.exists) {
      setState(() {
        rDate = snapshot['Date'];
        email = snapshot['Email'];
        values = snapshot['Values'];
        image = snapshot["Image"];
      });

      getValuesInDouble(values!.substring(11));
    }
  }

  void getValuesInDouble(String value) {
    double val = double.parse(value);
    double result = double.parse(val.toStringAsFixed(2));

    if (result > 1.8) {
      setState(() {
        inference =
            "The nail analysis result for the patient is $result, which is above the reference range. This indicates that you are likely suffering liver disease and need to consult a doctor immediately.";
      });
    } else {
      inference =
          "The nail analysis result for the patient is $result, which falls within normal range. This indicates that the person is not suffering from any disease.";
    }
  }

  void getAge(String? dob) {
    if (dob == null) return;

    DateTime birthDate = DateTime.parse(dob);
    DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;

      if (day2 > day1) {
        age--;
      }
    }

    setState(() {
      this.age = age.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Patient Report",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "User Details:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Patient',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Information',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(name!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'DOB',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(dob!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Gender',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(gender!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Report Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(rDate!.substring(7))),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Report ID',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(rID!)),
                      ]),
                      DataRow(cells: [
                        const DataCell(
                          Text(
                            'Age',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(age!)),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Divider(),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Report Details:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    horizontalMargin: 15.0,
                    decoration: const BoxDecoration(),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Test Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Result',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(cells: [
                        const DataCell(Text('Nail Image Analysis')),
                        DataCell(Text(values!.substring(11))),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                "Reference Range",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 1.0,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    horizontalMargin: 15.0,
                    decoration: const BoxDecoration(),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Ref. Range',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Inference',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('1.3 - 1.7')),
                        DataCell(Text('Healthy')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('1.8 and above')),
                        DataCell(Text('Liver Disease')),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Divider(),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Inference:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                inference!.trim(),
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Divider(),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Image:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  image!,
                  width: MediaQuery.of(context).size.width,
                  // height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 150.0),
            ],
          ),
        ),
      ),
    );
  }
}
