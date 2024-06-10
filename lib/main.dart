import 'package:ddetect/firebase_options.dart';
import 'package:ddetect/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MaterialColor mySwatchColor = Colors.blue;

    return MaterialApp(
      title: 'DDetect',
      home: const Splashscreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: mySwatchColor,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          surface: Colors.white,
          onPrimary: Colors.white,
        ),
        textTheme: GoogleFonts.rubikTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
