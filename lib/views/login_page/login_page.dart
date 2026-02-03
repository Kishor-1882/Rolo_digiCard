import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/common_textfield.dart';
import 'package:rolo_digi_card/controllers/login/login_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController loginConftroller = Get.put(LoginController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: GetBuilder<LoginController>(
            builder: (controller) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Image.asset('assets/login_logo.png',height: 30,width: 30,)),
                        ),
                        const SizedBox(height: 23),
                        // Title
                        const Text(
                          'Rolo Digi Card',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your Digital Business Card Solution',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Toggle Buttons
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(30),
                            border:Border.all(
                              color: AppColors.textPrimary.withOpacity(0.10)
                            )
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState((){
                                    controller.isLoginMode = true;
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: controller.isLoginMode
                                            ? const LinearGradient(
                                          colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                                        )
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Login',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState((){
                                    controller.isLoginMode = false;

                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: !controller.isLoginMode
                                            ? const LinearGradient(
                                          colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                                        )
                                            : null,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 9),
                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF18181B), Color(0xFF27272A)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.10),
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isLoginMode ? 'Welcome Back' : 'Create Account',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                controller.isLoginMode
                                    ? 'Login to manage your digital cards'
                                    : 'Start creating digital business cards',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Full Name (Sign Up only)
                              if (!controller.isLoginMode) ...[

                                const Text(
                                  'First Name',
                                  style: TextStyle(
                                    color: AppColors.textGrayPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                 CustomTextField(
                                  controller: controller.firstNameController,
                                  hintText: 'Enter your first name',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 12),

                                const Text(
                                  'Last Name',
                                  style: TextStyle(
                                    color: AppColors.textGrayPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                CustomTextField(
                                  controller: controller.lastNameController,
                                  hintText: 'Enter your last name',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 12),
                              ],
                              // Email
                              const Text(
                                'Email',
                                style: TextStyle(
                                  color: AppColors.textGrayPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                               CustomTextField(
                                controller: controller.emailController,
                                hintText: 'Enter Email',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 12),
                              // Password
                              const Text(
                                'Password',
                                style: TextStyle(
                                  color: AppColors.textGrayPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                               CustomTextField(
                                hintText: 'Enter password',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                controller: controller.passwordController,
                              ),
                              const SizedBox(height: 18),
                              // Submit Button
                              Container(
                                width: double.infinity,
                                height: 33,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed:  controller.isLoading.value ? null : () {
                                    controller.isLoginMode ?  controller.login() :  controller.register();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: controller.isLoading.value ? SizedBox(height:50,width:50,child: Center(child: CircularProgressIndicator(color: Colors.white,),)):Text(
                                    controller.isLoginMode ? 'Login' : 'Sign Up',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              if (controller.isLoginMode) ...[
                                const SizedBox(height: 14),
                                const Center(
                                  child: Text(
                                    'Demo: Use any email/password',
                                    style: TextStyle(
                                      color: AppColors.lightText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}
