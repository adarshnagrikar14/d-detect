// ignore_for_file: use_build_context_synchronously

import "package:ddetect/splashscreen.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:google_sign_in/google_sign_in.dart";

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Gap(30.0),
            FutureBuilder(
              future: _getUserInfo(),
              builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasData) {
                    User? user = snapshot.data;
                    return Column(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundImage: NetworkImage(user?.photoURL ?? ""),
                          radius: 50,
                        ),
                        const Gap(20.0),
                        Text(
                          "Name: ${user!.displayName}",
                          style: const TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Email: ${user.email}"),
                      ],
                    );
                  } else {
                    return const Text("User not logged in");
                  }
                }
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: ElevatedButton(
                onPressed: _signOut,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(12.0),
                    child: const Center(
                        child: Text(
                      "Sign Out",
                      style: TextStyle(fontSize: 18.0),
                    ))),
              ),
            ),
            const Gap(50.0),
          ],
        ),
      ),
    );
  }

  Future<User?> _getUserInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user;
    }
    return null;
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Splashscreen(),
      ),
    );
  }
}
