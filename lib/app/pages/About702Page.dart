import 'package:flutter/material.dart';
import 'package:for_you/app/utils/app_themes.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

class About702Page extends StatelessWidget {
  const About702Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About 702FORU",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.splashBackgroundColor,

        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Sign In / Sign Up button — clearly visible
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // prominent color
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 3,
            ),
            onPressed: () => _showAuthDialog(context),
            child: const Text(
              'Sign In / Sign Up',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ---------- HEADER BANNER ----------
            Container(
              width: Get.width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.splashBackgroundColor,

                // gradient: const LinearGradient(
                //   colors: [Colors.deepPurple, Colors.purpleAccent],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Image.asset("assets/logo.png", height: 110),
                  const SizedBox(height: 10),
                  const Text(
                    "Discover. Connect. Experience.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ---------- TITLE ----------
            const Text(
              "What is 702FORU?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// ---------- MAIN TEXT ----------
            const Text(
              "702FORU is an innovative platform designed to assist both locals "
              "and visitors in discovering top‑notch restaurants, hairdressers, "
              "handymen, and more, offering valuable information on quality "
              "services and deals.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),

            /// ---------- SUBTITLE ----------
            const Text(
              "Why AI Integration?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            const Text(
              "Collaborating with a trusted AI development company significantly "
              "enhances 702FORU’s functionality, providing users with a seamless "
              "and personalized experience while ensuring the platform remains "
              "up‑to‑date with the latest technological advancements.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),

            /// ---------- FEATURE LIST ----------
            const Text(
              "Key Improvements with AI:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 15),

            _featureItem(
              Icons.star,
              "Smart recommendations for restaurants and services.",
            ),
            _featureItem(Icons.location_on, "Location‑based suggestions."),
            _featureItem(Icons.person_pin, "Personalized user experience."),
            _featureItem(Icons.trending_up, "Real‑time updates and trends."),
            _featureItem(Icons.security, "Enhanced safety and data accuracy."),

            const SizedBox(height: 35),

            /// ---------- FOOTER ----------
            Center(
              child: Text(
                "© 702FORU • All Rights Reserved",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ Show a simple auth dialog (placeholder)
  // -----------------------------------------------------------
  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Welcome to 702FORU'),
          content: const Text(
            'Choose an option to continue. (Replace with your auth flow)',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: navigate to Sign In screen
                // Navigator.pushNamed(context, '/signin');
              },
              child: const Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // TODO: navigate to Sign Up screen
                // Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }
}
