import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../services/printer_service.dart';

class CustomReceiptDialog {
  static void show(BuildContext context) {
    final printerService = Get.find<PrinterService>();
    final current = printerService.receiptConfig.value;

    final nameCtrl = TextEditingController(text: current.name);
    final phoneCtrl = TextEditingController(text: current.phone);
    final addressCtrl = TextEditingController(text: current.address);
    final footerCtrl = TextEditingController(text: current.footerMessage);

    final isSaving = false.obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kustom Header & Footer Struk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data ini akan otomatis tercetak di bagian Header dan Footer seluruh struk kasir dan preview.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Restoran (Header Utama)',
                    hintText: 'SEAFOOD RESTO POS',
                    prefixIcon: const Icon(Icons.business_rounded, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alamat Restoran',
                    hintText: 'Jl. Pelabuhan Ikan No. 88',
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon Restoran',
                    hintText: '0812-3456-7890',
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: footerCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Pesan Footer (Bawah Struk)',
                    hintText: '*** TERIMA KASIH ***\nSelamat Menikmati Hidangan Kami',
                    prefixIcon: const Icon(Icons.message_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSaving.value
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        AppHelpers.showWarning(message: 'Nama Restoran tidak boleh kosong');
                        return;
                      }

                      isSaving.value = true;
                      try {
                        final newConfig = current.copyWith(
                          name: name,
                          address: addressCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          footerMessage: footerCtrl.text.trim(),
                        );
                        await printerService.saveReceiptConfig(newConfig);
                        Get.back();
                        AppHelpers.showSuccess(
                          message: 'Pengaturan header & footer struk berhasil disimpan',
                          title: 'Berhasil',
                        );
                      } catch (e) {
                        AppHelpers.showError(
                          message: 'Gagal menyimpan pengaturan: $e',
                          title: 'Gagal',
                        );
                      } finally {
                        isSaving.value = false;
                      }
                    },
              icon: isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan Pengaturan'),
            ),
          ),
        ],
      ),
    );
  }
}
