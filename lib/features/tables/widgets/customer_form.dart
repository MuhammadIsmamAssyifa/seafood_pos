import 'package:flutter/material.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import 'guest_counter.dart';

class CustomerForm extends StatelessWidget {
  final TextEditingController nameController;
  final int guestCount;
  final ValueChanged<int> onGuestCountChanged;

  const CustomerForm({
    super.key,
    required this.nameController,
    required this.guestCount,
    required this.onGuestCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          controller: nameController,
          label: 'Nama Pelanggan',
          hint: 'Contoh: Budi Santoso',
          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
          validator: (val) => AppValidators.requiredField(val, message: 'Nama pelanggan wajib diisi'),
        ),
        const SizedBox(height: 18),
        GuestCounter(
          count: guestCount,
          onChanged: onGuestCountChanged,
        ),
      ],
    );
  }
}

