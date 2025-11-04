import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ttlock_flutter/ttlock.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';

class AddSmartLockScreen extends ConsumerStatefulWidget {
  const AddSmartLockScreen({super.key});

  @override
  ConsumerState<AddSmartLockScreen> createState() => _AddSmartLockScreenState();
}

class _AddSmartLockScreenState extends ConsumerState<AddSmartLockScreen> {
  final List<TTLockScanModel> _nearbyLocks = [];
  bool _isScanning = false;
  bool _isInitializing = false;
  static const Color primaryColor = Color(0xFF076633);

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  void dispose() {
    TTLock.stopScanLock();
    super.dispose();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      _nearbyLocks.clear();
    });

    TTLock.startScanLock((scanModel) {
      setState(() {
        // Check if lock already exists in list
        bool exists = _nearbyLocks.any((lock) => lock.lockMac == scanModel.lockMac);
        
        if (!exists) {
          _nearbyLocks.add(scanModel);
          // Sort by initialization status (uninitialized first) and signal strength
          _nearbyLocks.sort((a, b) {
            if (a.isInited != b.isInited) {
              return a.isInited ? 1 : -1;
            }
            return b.rssi.compareTo(a.rssi);
          });
        }
      });
    });
  }

  void _stopScan() {
    TTLock.stopScanLock();
    setState(() {
      _isScanning = false;
    });
  }

  void _showAddLockDialog(TTLockScanModel scanModel) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Smart Lock'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Serial: ${scanModel.lockMac}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Lock Name',
                  hintText: 'e.g., Room1',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a lock name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                _initializeLock(scanModel, nameController.text.trim());
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _initializeLock(TTLockScanModel scanModel, String lockName) async {
    setState(() {
      _isInitializing = true;
    });

    // Stop scanning during initialization
    _stopScan();

    try {
      Map initMap = {
        "lockMac": scanModel.lockMac,
        "lockVersion": scanModel.lockVersion,
        "isInited": scanModel.isInited,
      };

      TTLock.initLock(
        initMap,
        (lockData) async {
          // Lock initialized successfully
          print('Lock initialized successfully: $lockData');
          
          // Now send to API
          await _saveLockToServer(
            lockName: lockName,
            serialNumber: scanModel.lockMac,
            lockData: lockData,
          );
        },
        (errorCode, errorMsg) {
          setState(() {
            _isInitializing = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to initialize lock: $errorMsg'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveLockToServer({
    required String lockName,
    required String serialNumber,
    required String lockData,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      // Get unit/room ID from current tenancy
      final tenancyAsync = ref.read(homeTenancyProvider);
      final tenancy = tenancyAsync.asData?.value;
      
      if (tenancy == null) {
        throw 'Unable to get tenancy information';
      }

      final response = await apiClient.post(
        '/locks',
        data: {
          'unit_id': 6, // You'll need to get the actual unit_id from tenancy
          'name': lockName,
          'serial_number': serialNumber,
          'lock_data': lockData, // Store lock data for future operations
        },
      );

      setState(() {
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Smart lock added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to smart home screen
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lock: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Smart Lock'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'Initializing smart lock...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Header with scan button
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            color: _isScanning ? primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isScanning
                                  ? 'Scanning for nearby locks...'
                                  : 'Tap refresh to scan',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(_isScanning ? Icons.stop : Icons.refresh),
                          label: Text(_isScanning ? 'Stop Scan' : 'Refresh'),
                          onPressed: () {
                            if (_isScanning) {
                              _stopScan();
                            } else {
                              _startScan();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Device list
                Expanded(
                  child: _nearbyLocks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isScanning
                                    ? 'Searching for locks...'
                                    : 'No locks found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Make sure the lock is nearby',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _nearbyLocks.length,
                          itemBuilder: (context, index) {
                            final lock = _nearbyLocks[index];
                            return _buildLockCard(lock);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildLockCard(TTLockScanModel lock) {
    final isAlreadyAdded = lock.isInited;
    final signalStrength = lock.rssi;
    
    // Determine signal quality
    String signalQuality;
    Color signalColor;
    if (signalStrength > -50) {
      signalQuality = 'Excellent';
      signalColor = Colors.green;
    } else if (signalStrength > -70) {
      signalQuality = 'Good';
      signalColor = Colors.orange;
    } else {
      signalQuality = 'Weak';
      signalColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isAlreadyAdded ? null : () => _showAddLockDialog(lock),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lock.lockName.isNotEmpty 
                              ? lock.lockName 
                              : 'TT Smart Lock',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Serial: ${lock.lockMac}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAlreadyAdded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Added',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 16, color: signalColor),
                  const SizedBox(width: 4),
                  Text(
                    signalQuality,
                    style: TextStyle(
                      fontSize: 12,
                      color: signalColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.battery_std, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${lock.electricQuantity}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (!isAlreadyAdded)
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: primaryColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}