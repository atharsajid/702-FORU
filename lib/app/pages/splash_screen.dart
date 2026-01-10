import 'dart:async';
import 'package:flutter/material.dart';
import 'package:for_you/app/pages/home.dart';
import 'package:for_you/app/pages/loginscreen.dart';
import 'package:for_you/app/utils/app_themes.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait 3 seconds then move to LoginScreen
    Timer(const Duration(seconds: 3), () {
      Get.off(() => HomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackgroundColor, // #77D1DA
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/logo.png', // make sure logo.png is added in assets
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              "FixIt Services",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
