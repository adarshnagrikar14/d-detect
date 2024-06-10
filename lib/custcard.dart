// ignore_for_file: avoid_print

import 'package:ddetect/give_report.dart';
import 'package:flutter/material.dart';

class CustomCard4 extends StatefulWidget {
  final String assetUrl;
  final String title;
  final String description;
  final String productID;
  final String productType;
  final String userID;
  final String docID;

  const CustomCard4({
    required this.assetUrl,
    required this.title,
    required this.description,
    required this.productID,
    required this.productType,
    required this.userID,
    required this.docID,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomCard4> createState() => _CustomCard4State();
}

class _CustomCard4State extends State<CustomCard4> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportsPage(
              docID: widget.docID,
              userID: widget.userID,
            ),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          color: Colors.blue.shade50,
          elevation: 0.7,
          margin: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: 12.0,
            top: 20.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.network(
                    widget.assetUrl,
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const Divider(
                  thickness: 1.0,
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          top: 12.0,
                        ),
                        child: Text(
                          "Date of ${widget.productType}",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          top: 12.0,
                        ),
                        child: Text(
                          "User Name: ${widget.title}",
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          top: 12.0,
                        ),
                        child: Text(
                          "User Email: ${widget.productID}",
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
