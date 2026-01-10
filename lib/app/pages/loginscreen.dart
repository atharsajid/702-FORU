import 'package:flutter/material.dart';
import 'package:for_you/app/pages/signup_screen.dart';
import 'package:for_you/app/utils/app_themes.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final obscure = true.obs;
    final isLoading = false.obs;

    void onLogin() async {
      if (!formKey.currentState!.validate()) return;
      isLoading.value = true;
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // TODO: replace with Firebase auth
      isLoading.value = false;
      Get.offAllNamed('/home'); // TODO: your home route
    }

    void onForgot() {
      // TODO: implement forgot password flow
      Get.snackbar(
        'Forgot password',
        'Password reset link will be sent to your email',
      );
    }

    void onGoogle() {
      // TODO: implement Google Sign-In
      Get.snackbar('Google', 'Google Sign-In tapped');
    }

    void onFacebook() {
      // TODO: implement Facebook Login
      Get.snackbar('Facebook', 'Facebook Login tapped');
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
                    // Title
                    const SizedBox(height: 12),
                    const Text(
                      'Sign In',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
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
                          Obx(
                            () => TextFormField(
                              controller: passCtrl,
                              obscureText: obscure.value,
                              decoration: InputDecoration(
                                labelText: 'Enter your password',
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
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: onForgot,
                              child: const Text('Forgot password?'),
                            ),
                          ),

                          const SizedBox(height: 6),
                          Obx(
                            () => ElevatedButton(
                              onPressed: isLoading.value ? null : onLogin,
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
                                      'Sign In',
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
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Haven’t an account? "),
                        GestureDetector(
                          onTap: () => Get.to(() => SignUpScreen()),
                          child: const Text(
                            'Sign up now',
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
                      'Log in with',
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
