import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/core/services/url_launcher_service.dart';
import 'package:rms_tenant_app/features/payment/payment_provider.dart';
import 'package:rms_tenant_app/features/smart_home/smart_home_provider.dart';
import 'package:rms_tenant_app/shared/models/smart_devices_model.dart';

class SmartHomeScreen extends ConsumerWidget {
  const SmartHomeScreen({super.key});

  // Pull-to-refresh handler
  Future<void> _handleRefresh(WidgetRef ref) async {
    ref.invalidate(smartDevicesProvider);
    await ref.read(smartDevicesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsyncValue = ref.watch(smartDevicesProvider);
    const Color primaryColor = Color(0xFF076633);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Add Smart Lock button in AppBar
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Smart Lock',
            onPressed: () {
              context.push('/smart-home/add-lock');
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: devicesAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        error: (err, stack) => RefreshIndicator(
          onRefresh: () => _handleRefresh(ref),
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading devices',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => ref.invalidate(smartDevicesProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        data: (deviceData) {
          return RefreshIndicator(
            onRefresh: () => _handleRefresh(ref),
            color: primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- Smart Meters Section ---
                const Text(
                  'Smart Meters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (deviceData.meters.isEmpty)
                  const Text('No smart meters found.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deviceData.meters.length,
                    itemBuilder: (context, index) {
                      return _buildMeterCard(context, deviceData.meters[index], ref);
                    },
                  ),
                
                const SizedBox(height: 24),

                // --- Smart Locks Section ---
                const Text(
                  'Smart Locks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (deviceData.locks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No smart locks found.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Add Smart Lock" to get started',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deviceData.locks.length,
                    itemBuilder: (context, index) {
                      return _buildLockCard(context, deviceData.locks[index]);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeterCard(BuildContext context, SmartMeter meter, WidgetRef ref) {
    final isOnline = meter.connectionStatus.toLowerCase() == 'online';
    final isPowerOn = meter.powerStatus.toLowerCase() == 'on';
    const Color primaryColor = Color(0xFF076633);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.electric_bolt, color: primaryColor, size: 30),
                const SizedBox(width: 12),
                Text(
                  meter.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoColumn(
                  'Balance',
                  '${meter.balanceUnit.toStringAsFixed(2)} kWh',
                ),
                _buildInfoColumn(
                  'Unit Price',
                  'RM ${meter.unitPrice.toStringAsFixed(2)} / kWh',
                ),
                _buildInfoColumn(
                  'Power',
                  meter.powerStatus.toUpperCase(),
                  valueColor: isPowerOn ? Colors.green : Colors.red,
                ),
                _buildInfoColumn(
                  'Status',
                  meter.connectionStatus.toUpperCase(),
                  valueColor: isOnline ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                _showTopUpDialog(context, meter, ref);
              },
              child: const Text('Top Up'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockCard(BuildContext context, SmartLock lock) {
    const Color primaryColor = Color(0xFF076633);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          context.go('/smart-home/detail', extra: lock);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.lock, color: primaryColor, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Smart Lock (${lock.serialNumber})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showTopUpDialog(BuildContext context, SmartMeter meter, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final unitController = TextEditingController();
    String calculatedPrice = "0.00";
    bool _isPaying = false;
    const Color primaryColor = Color(0xFF076633);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Top-up Smart Meter"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Enter the number of units (kWh) to top-up."),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: unitController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'Units (kWh)',
                        hintText: 'Min: ${meter.minimumTopupUnit} units',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        double units = double.tryParse(value) ?? 0.0;
                        double price = units * meter.unitPrice;
                        setState(() {
                          calculatedPrice = price.toStringAsFixed(2);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter units';
                        }
                        int? units = int.tryParse(value);
                        if (units == null) {
                          return 'Invalid number';
                        }
                        if (units < meter.minimumTopupUnit) {
                          return 'Minimum top-up is ${meter.minimumTopupUnit} units';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Calculated Price: RM $calculatedPrice',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isPaying ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() { _isPaying = true; });
                      
                      final double amount = double.parse(calculatedPrice);
                      
                      final url = await ref
                          .read(paymentProvider.notifier)
                          .generatePaymentLink(
                            payableType: 'meter',
                            payableId: meter.id,
                            amount: amount,
                          );
                      
                      setState(() { _isPaying = false; });
                      
                      if (url != null && context.mounted) {
                        Navigator.of(context).pop();
                        launchUrlHelper(context, url);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to generate payment link.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: _isPaying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Confirm Top-up"),
                )
              ],
            );
          },
        );
      },
    );
  }
}