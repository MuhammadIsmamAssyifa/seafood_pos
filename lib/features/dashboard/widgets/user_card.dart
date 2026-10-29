import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../../auth/models/user_model.dart';
import '../models/outlet_model.dart';

class UserCard extends StatelessWidget {
  final UserModel? user;
  final OutletModel? outlet;

  const UserCard({
    super.key,
    required this.user,
    required this.outlet,
  });

  @override
  Widget build(BuildContext context) {
    final roleName = user?.primaryRole.displayName ?? 'Kasir';
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Kasir Restoran';
    final emailOrUsername = user?.email ?? (user?.username != null ? '@${user!.username}' : 'kasir');

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            // User Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withAlpha(25),
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: AppTextStyle.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // User & Shift Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Role Pill Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondary.withAlpha(60), width: 1),
                        ),
                        child: Text(
                          roleName,
                          style: AppTextStyle.caption.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailOrUsername,
                    style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        outlet?.activeShift ?? 'Shift Aktif',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        outlet?.name ?? 'Cabang Utama',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

