import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ttlock_flutter/ttlock.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/features/home/home_provider/home_provider.dart';

// NOTE: If your project already defines a smartDevicesProvider elsewhere, remove
// this placeholder and import the provider instead.
// This placeholder ensures ref.invalidate(smartDevicesProvider) compiles.
final smartDevicesProvider = Provider<List<dynamic>?>((ref) => null);

class AddSmartLockScreen extends ConsumerStatefulWidget {
  const AddSmartLockScreen({super.key});

  @override
  ConsumerState<AddSmartLockScreen> createState() => _AddSmartLockScreenState();
}

class _AddSmartLockScreenState extends ConsumerState<AddSmartLockScreen> {
  final List<TTLockScanModel> _nearbyLocks = [];
  bool _isScanning = false;
  bool _isInitializing = false;
  String _initializingStep = '';
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
        bool exists = _nearbyLocks.any((lock) => lock.lockMac == scanModel.lockMac);
        
        if (!exists) {
          _nearbyLocks.add(scanModel);
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
                  hintText: 'e.g., Unit 101 - Front Door',
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
      _initializingStep = 'Connecting to lock...';
    });

    _stopScan();

    try {
      Map initMap = {
        "lockMac": scanModel.lockMac,
        "lockVersion": scanModel.lockVersion,
        "isInited": scanModel.isInited,
      };

      // Step 3: SDK initialization
      TTLock.initLock(
        initMap,
        (lockData) async {
          print('Step 3 - SDK initialization successful: $lockData');
          
          setState(() {
            _initializingStep = 'Initializing to cloud...';
          });
          
          // Step 4: Initialize to TTLock cloud
          await _initializeLockToCloud(
            lockData: lockData,
            lockAlias: lockName,
            lockMac: scanModel.lockMac,
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
                duration: const Duration(seconds: 5),
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
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

// Step 4: Initialize lock to TTLock cloud
Future<void> _initializeLockToCloud({
  required String lockData,
  required String lockAlias,
  required String lockMac,
}) async {
  try {
    final apiClient = ref.read(apiClientProvider);

    print('Step 4 - Calling cloud initialization API...');
    final cloudResponse = await apiClient.post(
      '/ttlock/locks/initialize',
      data: {
        'lockData': lockData,
        'lockAlias': lockAlias,
      },
    );

    if (cloudResponse.statusCode == 200) {
      print('Step 4 - Cloud initialization successful');

      // Extract lockId from response
      final String lockId = cloudResponse.data['data']['lockId'].toString();

      setState(() {
        _initializingStep = 'Saving to backend... $lockId';
      });

      // Step 5: Save lock to our backend
      await _saveLockToServer(
        lockData: lockData,
        lockName: lockAlias,
        lockMac: lockMac,
        serialNumber: lockId,
      );
    } else {
      throw 'Cloud initialization failed with status ${cloudResponse.statusCode}';
    }
  } catch (e) {
    setState(() {
      _isInitializing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize lock to cloud: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
    rethrow;
  }
}


  // Step 5: Save lock to our backend
  Future<void> _saveLockToServer({
    required String lockData,
    required String lockName,
    required String lockMac,
    required String serialNumber,
  }) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      
      // Get tenancy info to determine unit_id or room_id
      final tenancyAsync = ref.read(homeTenancyProvider);
      final tenancy = tenancyAsync.asData?.value;
      
      if (tenancy == null) {
        throw 'Unable to get tenancy information';
      }

      print('Step 5 - Preparing backend save...');
      print('Tenantable Type: ${tenancy.tenantableType}');
      print('Tenantable ID: ${tenancy.tenantableId}');

      // Build request data based on tenantable_type
      Map<String, dynamic> requestData = {
        'name': lockName,
        'lock_data': lockData,
        'lockMac': lockMac,
        'serial_number': serialNumber,
      };

      // Determine if it's room or unit based on tenantable_type
      if (tenancy.isRoom) {
        requestData['room_id'] = tenancy.tenantableId;
        print('Using room_id: ${tenancy.tenantableId}');
      } else if (tenancy.isUnit) {
        requestData['unit_id'] = tenancy.tenantableId;
        print('Using unit_id: ${tenancy.tenantableId}');
      } else {
        throw 'Unknown tenantable type: ${tenancy.tenantableType}';
      }

      print('Step 5 - Calling backend API with data: $requestData');
      final response = await apiClient.post(
        '/locks',
        data: requestData,
      );

      print('Step 5 - Backend save successful');
      setState(() {
        _isInitializing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Smart lock added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh the smart devices list
        ref.invalidate(smartDevicesProvider);
        
        // Go back to smart home screen
        context.pop();
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
      
      print('Step 5 - Backend save failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lock to backend: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      rethrow;
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    _initializingStep,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
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
                                'Make sure the lock is nearby and powered on',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
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