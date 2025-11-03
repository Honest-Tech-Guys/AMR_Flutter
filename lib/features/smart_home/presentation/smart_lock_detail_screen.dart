import 'package:flutter/material.dart';
import 'package:rms_tenant_app/shared/models/smart_devices_model.dart';
import 'package:ttlock_flutter/ttlock.dart';

class SmartLockDetailScreen extends StatefulWidget {
  const SmartLockDetailScreen({required this.lock, super.key});

  final SmartLock lock;

  @override
  State<SmartLockDetailScreen> createState() => _SmartLockDetailScreenState();
}

class _SmartLockDetailScreenState extends State<SmartLockDetailScreen> {
  bool _isLocked = true;
  bool _isUnlocking = false;
  bool _isProcessing = false;
  String? _errorMessage;
  
  // Bluetooth state
  TTBluetoothState _bluetoothState = TTBluetoothState.unknown;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  // Check if Bluetooth is enabled
  void _checkBluetoothState() {
    TTLock.getBluetoothState((state) {
      setState(() {
        _bluetoothState = state;
      });
      
      if (state != TTBluetoothState.turnOn) {
        setState(() {
          _errorMessage = 'Please enable Bluetooth to control the lock';
        });
      }
    });
  }

  // Check if lock data is available
  bool get _hasLockData => widget.lock.lockData != null && widget.lock.lockData!.isNotEmpty;

  // Unlock the door using TTLock SDK
  void _unlockDoor() {
    if (!_hasLockData) {
      _showError('Lock data not available. Please contact support.');
      return;
    }

    if (_bluetoothState != TTBluetoothState.turnOn) {
      _showError('Bluetooth is not enabled. Please turn on Bluetooth.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    TTLock.controlLock(
      widget.lock.lockData!,
      TTControlAction.unlock,
      (lockTime, electricQuantity, uniqueId, lockData) {
        // Success callback
        if (mounted) {
          setState(() {
            _isLocked = false;
            _isProcessing = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔓 Door unlocked successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      (error, message) {
        // Error callback
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          _showError('Failed to unlock: ${_getErrorMessage(error, message)}');
        }
      },
    );
  }

  // Lock the door using TTLock SDK
  void _lockDoor() {
    if (!_hasLockData) {
      _showError('Lock data not available. Please contact support.');
      return;
    }

    if (_bluetoothState != TTBluetoothState.turnOn) {
      _showError('Bluetooth is not enabled. Please turn on Bluetooth.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    TTLock.controlLock(
      widget.lock.lockData!,
      TTControlAction.lock,
      (lockTime, electricQuantity, uniqueId, lockData) {
        // Success callback
        if (mounted) {
          setState(() {
            _isLocked = true;
            _isProcessing = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔒 Door locked successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      (error, message) {
        // Error callback
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
          
          _showError('Failed to lock: ${_getErrorMessage(error, message)}');
        }
      },
    );
  }

  // Show error message
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // Convert TTLock error to user-friendly message
  String _getErrorMessage(TTLockError error, String originalMessage) {
    switch (error) {
      case TTLockError.bluetoothOff:
        return 'Bluetooth is turned off';
      case TTLockError.bluetoothConnectTimeout:
        return 'Could not connect to lock. Please try again.';
      case TTLockError.bluetoothDisconnection:
        return 'Lost connection to lock';
      case TTLockError.lockIsBusy:
        return 'Lock is busy. Please wait and try again.';
      case TTLockError.noPower:
        return 'Lock battery is too low';
      case TTLockError.noPermission:
        return 'You do not have permission to control this lock';
      default:
        return originalMessage.isNotEmpty ? originalMessage : 'An error occurred';
    }
  }

  // Handle long press to unlock
  void _startUnlock() async {
    setState(() {
      _isUnlocking = true;
    });
    
    // Simulate hold for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (_isUnlocking && mounted) {
      _unlockDoor();
    }
    
    setState(() {
      _isUnlocking = false;
    });
  }

  void _cancelUnlock() {
    setState(() {
      _isUnlocking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lock.lockName ?? 'Smart Lock'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Lock Info
              Text(
                widget.lock.lockName ?? widget.lock.serialNumber,
                style: const TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Serial: ${widget.lock.serialNumber}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              
              // Battery indicator (if available)
              if (widget.lock.electricQuantity != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.battery_std,
                      size: 20,
                      color: widget.lock.electricQuantity! > 20 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.lock.electricQuantity}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Bluetooth status warning
              if (_bluetoothState != TTBluetoothState.turnOn) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth_disabled, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bluetooth is ${_bluetoothState == TTBluetoothState.turnOff ? "off" : "unavailable"}',
                          style: const TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Lock data warning
              if (!_hasLockData) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lock not initialized. Please contact support.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Lock Status Circle
              _buildLockStatusCircle(primaryColor),
              
              const SizedBox(height: 24),

              // Instruction Text
              Text(
                _isProcessing
                    ? 'Communicating with lock...'
                    : _isUnlocking 
                        ? 'Hold to unlock...' 
                        : _isLocked
                            ? 'Long press to unlock\nTap to lock'
                            : 'Tap to lock the door',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              
              const SizedBox(height: 40),

              // Quick Access Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quick Access Buttons
              _buildQuickAccessGrid(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockStatusCircle(Color primaryColor) {
    final bool isDisabled = !_hasLockData || 
                            _bluetoothState != TTBluetoothState.turnOn || 
                            _isProcessing;

    return GestureDetector(
      onLongPressStart: (_) {
        if (!isDisabled && _isLocked) {
          _startUnlock();
        }
      },
      onLongPressEnd: (_) {
        if (_isUnlocking) {
          _cancelUnlock();
        }
      },
      onTap: () {
        if (!isDisabled && !_isLocked) {
          _lockDoor();
        }
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? Colors.grey[400]! : Colors.grey[300]!,
            width: 8,
          ),
        ),
        child: Stack(
          children: [
            // Progress indicator
            if (_isUnlocking || _isProcessing)
              Positioned.fill(
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDisabled ? Colors.grey : primaryColor,
                  ),
                ),
              ),
            
            // Lock Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDisabled ? Colors.grey : primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isLocked ? Icons.lock : Icons.lock_open,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(Color primaryColor) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildQuickAccessCard('Smart Key', Icons.key, primaryColor),
        _buildQuickAccessCard('Passcode', Icons.dialpad, primaryColor),
        _buildQuickAccessCard('Fingerprint', Icons.fingerprint, primaryColor),
        _buildQuickAccessCard('Setting', Icons.settings, primaryColor),
      ],
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color primaryColor) {
    final double cardWidth = (MediaQuery.of(context).size.width - 72) / 2;
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title feature coming soon!')),
        );
      },
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[100]!,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryColor, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}