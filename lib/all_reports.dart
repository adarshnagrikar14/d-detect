import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddetect/custcard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View All Reports",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFeaturedItems(user!.email!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Reports found.'));
          } else {
            final items = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: items.map((item) {
                  String docID = item['docID'];
                  return CustomCard4(
                    docID: docID,
                    userID: user!.uid,
                    assetUrl: item['Image'],
                    title: item['Name'],
                    description: item["Values"],
                    productID: item["Email"],
                    productType: item["Date"],
                  );
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFeaturedItems(String email) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Reports")
        .orderBy("Date", descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['docID'] = doc.id;
      return data;
    }).toList();
  }
}
