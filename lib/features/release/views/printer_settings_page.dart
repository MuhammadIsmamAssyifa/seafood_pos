import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_style.dart';
import '../controllers/release_controller.dart';
import '../services/printer_service.dart';

class PrinterSettingsPage extends GetView<ReleaseController> {
  const PrinterSettingsPage({super.key});

  void _showAddNetworkPrinterDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Printer Dapur (LAN)');
    final ipCtrl = TextEditingController(text: '192.168.1.188');
    final portCtrl = TextEditingController(text: '9100');

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
              child: const Icon(Icons.lan_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Tambah Printer LAN / IP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan alamat IP printer thermal lokal di dapur atau kasir:'),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nama Printer',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: TextField(
                    controller: ipCtrl,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'IP Address',
                      hintText: '192.168.1.xxx',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: portCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Port',
                      hintText: '9100',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final ip = ipCtrl.text.trim();
              final port = int.tryParse(portCtrl.text.trim()) ?? 9100;
              if (ip.isNotEmpty) {
                Get.back();
                await controller.printerService.addNetworkPrinter(nameCtrl.text.trim(), ip, port: port);
              }
            },
            child: const Text('Simpan & Hubungkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pengaturan Printer Thermal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Pindai Ulang',
            onPressed: () => controller.scanPrinters(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bluetooth Hardware Status Warning Banner
            Obx(() {
              final isBtOn = controller.printerService.isBluetoothEnabled.value;
              final isPermGranted = controller.printerService.isBluetoothPermissionGranted.value;

              if (isBtOn && isPermGranted) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bluetooth_connected_rounded, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bluetooth Perangkat Aktif dan Siap Terhubung ke Printer.',
                          style: TextStyle(color: Colors.green.shade900, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final isPermissionIssue = !isPermGranted;
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPermissionIssue ? Icons.security_rounded : Icons.bluetooth_disabled_rounded,
                      color: Colors.amber.shade900,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isPermissionIssue
                            ? 'Izin Bluetooth belum diberikan! Klik "Izinkan" untuk mengizinkan akses printer.'
                            : 'Bluetooth belum terdeteksi aktif. Pastikan Bluetooth di perangkat aktif, lalu klik "Cek Ulang".',
                        style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.printerService.checkBluetoothStatus(requestPermission: true),
                      child: Text(
                        isPermissionIssue ? 'Izinkan' : 'Cek Ulang',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Current Active Printer Card
            Obx(() {
              final active = controller.printer.value;
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.print_rounded,
                                color: active != null && active.isConnected
                                    ? Colors.green.shade600
                                    : AppColors.textSecondary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Printer Utama',
                                style: AppTextStyle.h3,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: active != null && active.isConnected
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active != null && active.isConnected
                                    ? Colors.green.shade300
                                    : Colors.grey.shade400,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: active != null && active.isConnected
                                        ? Colors.green.shade600
                                        : Colors.grey.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  active != null && active.isConnected ? 'Terhubung' : 'Terputus',
                                  style: AppTextStyle.caption.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: active != null && active.isConnected
                                        ? Colors.green.shade800
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        active?.name ?? 'Belum ada printer yang dipilih',
                        style: AppTextStyle.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alamat: ${active?.address ?? "-"}  •  Tipe: ${active?.type.name.toUpperCase() ?? "BLUETOOTH"}',
                        style: AppTextStyle.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),

                      // Paper Size Selector
                      Row(
                        children: [
                          Text('Ukuran Kertas: ', style: AppTextStyle.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('58 MM'),
                            selected: active?.paperSize == PrinterPaperSize.mm58,
                            onSelected: (val) {
                              if (val) controller.printerService.setPaperSize(PrinterPaperSize.mm58);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('80 MM'),
                            selected: active?.paperSize == PrinterPaperSize.mm80,
                            onSelected: (val) {
                              if (val) controller.printerService.setPaperSize(PrinterPaperSize.mm80);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: controller.isPrinting.value
                                  ? null
                                  : () => controller.testPrint(),
                              icon: controller.isPrinting.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.receipt_long_rounded, size: 20),
                              label: const Text('Test Print Struk'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Scan Action & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Perangkat Tersedia',
                  style: AppTextStyle.h3,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lan_outlined),
                      tooltip: 'Tambah Printer LAN / IP',
                      onPressed: () => _showAddNetworkPrinterDialog(context),
                    ),
                    const SizedBox(width: 6),
                    Obx(() => OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: controller.isScanning.value ? null : () => controller.scanPrinters(),
                          icon: controller.isScanning.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.bluetooth_searching_rounded, size: 18),
                          label: Text(controller.isScanning.value ? 'Memindai...' : 'Pindai Printer'),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Discovered Printers List
            Obx(() {
              final list = controller.scannedPrinters;
              if (controller.isScanning.value && list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Mencari perangkat Bluetooth & Thermal Printer...'),
                      ],
                    ),
                  ),
                );
              }

              if (list.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.print_disabled_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Belum ada printer terdeteksi.'),
                          const SizedBox(height: 4),
                          Text(
                            'Pastikan Bluetooth printer aktif atau tambahkan via tombol LAN (IP).',
                            style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final printer = list[index];
                  final isCurrent = controller.printer.value?.address == printer.address &&
                      controller.printer.value?.isConnected == true;

                  return Card(
                    elevation: isCurrent ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent ? AppColors.primary : Colors.grey.shade300,
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isCurrent ? AppColors.primary.withAlpha(25) : Colors.grey.shade100,
                        child: Icon(
                          printer.type == PrinterType.network
                              ? Icons.lan_rounded
                              : Icons.bluetooth_rounded,
                          color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      title: Text(
                        printer.name,
                        style: AppTextStyle.titleSmall.copyWith(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${printer.address} • ${printer.type.name.toUpperCase()} • ${printer.paperSize.name.toUpperCase()}',
                        style: AppTextStyle.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: isCurrent
                          ? const Chip(
                              label: Text('Aktif', style: TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.zero,
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => controller.connectPrinter(printer),
                              child: const Text('Hubungkan'),
                            ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
