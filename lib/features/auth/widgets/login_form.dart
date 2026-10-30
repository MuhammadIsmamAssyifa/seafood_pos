import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import 'password_field.dart';

enum LoginMode { staffPin, emailPassword }

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _authController = Get.find<AuthController>();

  LoginMode _selectedMode = LoginMode.staffPin;

  // Controllers for Staff Login
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();

  // Controllers for Email Login
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedMode == LoginMode.staffPin) {
        _authController.staffLogin(
          username: _usernameController.text,
          pin: _pinController.text,
        );
      } else {
        _authController.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Segmented Login Mode Switch
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildModeTab(
                    title: 'Kasir / Staff (PIN)',
                    icon: Icons.pin_rounded,
                    isSelected: _selectedMode == LoginMode.staffPin,
                    onTap: () {
                      setState(() {
                        _selectedMode = LoginMode.staffPin;
                        _authController.errorMessage.value = null;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildModeTab(
                    title: 'Admin / Manager',
                    icon: Icons.admin_panel_settings_outlined,
                    isSelected: _selectedMode == LoginMode.emailPassword,
                    onTap: () {
                      setState(() {
                        _selectedMode = LoginMode.emailPassword;
                        _authController.errorMessage.value = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error alert message banner if available
          Obx(() {
            final error = _authController.errorMessage.value;
            if (error == null || error.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withAlpha(80),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      error,
                      style: AppTextStyle.bodySmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Inputs based on selected mode
          if (_selectedMode == LoginMode.staffPin) ...[
            AppTextField(
              controller: _usernameController,
              label: 'Username Staff',
              hint: 'Contoh: kasir1 / pelayan1',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
              validator: (val) => AppValidators.requiredField(
                val,
                message: 'Username staff wajib diisi',
              ),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _pinController,
              label: 'PIN Kasir (4-6 Angka)',
              hint: '••••',
              isPin: true,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'PIN wajib diisi';
                if (val.trim().length < 4) return 'PIN minimal 4 angka';
                return null;
              },
              onSubmitted: (_) => _submit(),
            ),
          ] else ...[
            AppTextField(
              controller: _emailController,
              label: 'Email Akun',
              hint: 'manager@seafood.id',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              validator: AppValidators.email,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
              validator: AppValidators.password,
              onSubmitted: (_) => _submit(),
            ),
          ],

          const SizedBox(height: 28),

          // Submit Button
          Obx(
            () => AppButton(
              text: 'Masuk',
              isLoading: _authController.isLoading.value,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.caption.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
