import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // In Sprint 1 Foundation, simulate entry or guide to Sprint 2
      Get.offAllNamed(AppRoutes.DASHBOARD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 34,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.appName,
                          style: AppTextStyle.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Silakan masuk untuk melanjutkan transaksi',
                          style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email / Username',
                          hint: 'nama@restoran.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          validator: AppValidators.requiredField,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          validator: AppValidators.password,
                        ),
                        const SizedBox(height: 26),
                        Obx(
                          () => AppButton(
                            text: 'Masuk ke POS',
                            isLoading: _authController.isLoading.value,
                            onPressed: _handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

