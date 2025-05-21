import 'package:flutter/material.dart';
import 'package:kinclongin/screen/loginregister/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
    if (mounted) {  // ← Add this check
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo_blue.png",
            width: 93,
            height: 122,
            ),
            SizedBox(height: 11),
            Text("KinclongIn",
            style: TextStyle(color: Colors.blue,fontSize: 32, fontWeight: FontWeight.bold)
            ),
          ],
        ),
      ),
    );
  }
}