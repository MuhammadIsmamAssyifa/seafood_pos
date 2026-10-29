import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withAlpha(25),
                    child: Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                      style: AppTextStyle.h1.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Nama Pengguna',
                    style: AppTextStyle.h3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.primaryRole.displayName ?? 'Staff',
                    style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow('ID Pengguna', user?.id.toString() ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow('Username', user?.username ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow('Email', user?.email ?? '-'),
                    const Divider(height: 24),
                    _buildInfoRow('Status Akun', user?.status ?? 'Aktif'),
                    const Divider(height: 24),
                    _buildInfoRow('Hak Akses', user?.roles.join(', ') ?? '-'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyle.titleSmall),
      ],
    );
  }
}

