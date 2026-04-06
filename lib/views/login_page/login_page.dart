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

  Widget _buildVerificationUI(BuildContext context, LoginController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () {
                controller.closeVerificationUI();
              },
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF9810FA).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.mail_outline, color: Color(0xFF9810FA), size: 36),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Please verify your account',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Please verify the message sent to your email id:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            controller.emailController.text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Courier',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF18181B), // dark card bg
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.textPrimary.withOpacity(0.10),
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFF22C55E)),
                      ),
                      child: const Icon(Icons.check, color: Color(0xFF22C55E), size: 12),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Click the verification link',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Open the email we just sent and click "Verify Email" to activate your account.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF22C55E).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFF22C55E)),
                      ),
                      child: const Icon(Icons.check, color: Color(0xFF22C55E), size: 12),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete your profile',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Once verified, you\'ll be redirected to login and can start creating your digital cards.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: GetBuilder<LoginController>(
              builder: (controller) {
                if (controller.showVerificationUI) {
                  return _buildVerificationUI(context, controller);
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     const SizedBox(height: 40), // top breathing room

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
                        child: Center(
                          child: Image.asset(
                            'assets/login_logo.png',
                            height: 30,
                            width: 30,
                          ),
                        ),
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
                          border: Border.all(
                            color: AppColors.textPrimary.withOpacity(0.10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  controller.isLoginMode = true;
                                  controller.clearFields();
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: controller.isLoginMode
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFF6339A),
                                                Color(0xFF9810FA),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
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
                                onTap: () => setState(() {
                                  controller.isLoginMode = false;
                                  controller.clearFields();
                                }),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: !controller.isLoginMode
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFF6339A),
                                                Color(0xFF9810FA),
                                              ],
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
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
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.isLoginMode
                                  ? 'Welcome Back'
                                  : 'Create Account',
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
                            // User Type Selection (Sign Up only)
                            if (!controller.isLoginMode) ...[
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.textPrimary
                                        .withOpacity(0.10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          controller.selectedUserType =
                                              'individual';
                                          controller.clearFields();
                                        }),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                          decoration: BoxDecoration(
                                            color:
                                                controller
                                                        .selectedUserType ==
                                                    'individual'
                                                ? AppColors.textFieldColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Individual',
                                              style: TextStyle(
                                                color:
                                                    AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          controller.selectedUserType =
                                              'organization';
                                          controller.clearFields();
                                        }),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 8,
                                              ),
                                          decoration: BoxDecoration(
                                            color:
                                                controller
                                                        .selectedUserType ==
                                                    'organization'
                                                ? AppColors.textFieldColor
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Organization',
                                              style: TextStyle(
                                                color:
                                                    AppColors.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Organization Name (Sign Up only, if Organization selected)
                              if (controller.selectedUserType ==
                                  'organization') ...[
                                const Text(
                                  'Organization Name',
                                  style: TextStyle(
                                    color: AppColors.textGrayPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                CustomTextField(
                                  key: const ValueKey('org_name'),
                                  controller:
                                      controller.organizationNameController,
                                  hintText: 'Enter organization name',
                                  icon: Icons.business_outlined,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                            // Names (Sign Up only)
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
                                key: const ValueKey('signup_first_name'),
                                controller: controller.firstNameController,
                                hintText: 'Enter your first name',
                                icon: Icons.person_outline,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                key: const ValueKey('signup_last_name'),
                                controller: controller.lastNameController,
                                hintText: 'Enter your last name',
                                icon: Icons.person_outline,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                              key: const ValueKey('signup_email'),
                              controller: controller.emailController,
                              hintText: 'Enter Email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
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
                              key: const ValueKey('signup_password'),
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
                                  colors: [
                                    Color(0xFFF6339A),
                                    Color(0xFF9810FA),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        controller.isLoginMode
                                            ? controller.login()
                                            : controller.register();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        controller.isLoginMode
                                            ? 'Login'
                                            : 'Sign Up',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            // if (!controller.isLoginMode) ...[
                            const SizedBox(height: 14),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    controller.isLoginMode
                                        ? 'Don\'t have an account?'
                                        : 'Already have an account?',
                                    style: TextStyle(
                                      color: AppColors.lightText,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (controller.isLoginMode) {
                                        controller.isLoginMode = false;
                                      } else {
                                        controller.isLoginMode = true;
                                      }
                                      setState(() {});
                                    },
                                    child: Text(
                                      controller.isLoginMode
                                          ? 'Sign Up'
                                          : 'Login',
                                      style: TextStyle(
                                        color: AppColors.switchBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
