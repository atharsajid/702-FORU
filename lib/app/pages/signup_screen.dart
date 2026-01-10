import 'package:flutter/material.dart';
import 'package:for_you/app/pages/loginscreen.dart';
import 'package:get/get.dart';

import '../utils/app_themes.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    final obscure = true.obs;
    final agree = false.obs;
    final isLoading = false.obs;

    void onGoogle() => Get.snackbar('Google', 'Google Sign-Up tapped');
    void onFacebook() => Get.snackbar('Facebook', 'Facebook Sign-Up tapped');

    Future<void> onSignUp() async {
      if (!formKey.currentState!.validate()) return;
      if (!agree.value) {
        Get.snackbar(
          'Terms & Conditions',
          'Please accept the terms to continue',
          backgroundColor: Colors.orange.shade700,
          colorText: Colors.white,
        );
        return;
      }
      isLoading.value = true;
      // TODO: replace with Firebase createUserWithEmailAndPassword + save name
      await Future.delayed(const Duration(milliseconds: 800));
      isLoading.value = false;
      Get.offAllNamed('/home');
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Full name
                          TextFormField(
                            controller: nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Full name',
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Email
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Enter your email',
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'Email is required';
                              final ok = RegExp(
                                r'^[\w\.\-\+]+@[\w\-]+\.[\w\.\-]+$',
                              ).hasMatch(value);
                              return ok ? null : 'Enter a valid email';
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password
                          Obx(
                            () => TextFormField(
                              controller: passCtrl,
                              obscureText: obscure.value,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: 'Enter password',
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      obscure.value = !obscure.value,
                                  icon: Icon(
                                    obscure.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                final value = v ?? '';
                                if (value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'At least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Terms & conditions
                          Obx(
                            () => Row(
                              children: [
                                Checkbox(
                                  value: agree.value,
                                  onChanged: (v) => agree.value = v ?? false,
                                ),
                                const Expanded(
                                  child: Text(
                                    "I agree with FixIt’s term & conditions",
                                    style: TextStyle(color: AppColors.darkGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Sign Up button
                          Obx(
                            () => ElevatedButton(
                              onPressed: isLoading.value ? null : onSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        GestureDetector(
                          onTap: () =>
                              Get.to(() => LoginScreen()), // simple Get.toNamed
                          child: const Text(
                            'Sign in now',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Divider "Or"
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Or'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Sign up with',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                    const SizedBox(height: 12),

                    // Social buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onGoogle,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Google'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onFacebook,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.transparent,
                                  child: Text(
                                    'f',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Facebook'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
