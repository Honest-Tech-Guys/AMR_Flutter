import 'package:flutter/material.dart';
import 'package:rms_tenant_app/shared/models/smart_devices_model.dart';

class SmartLockDetailScreen extends StatefulWidget {
  const SmartLockDetailScreen({required this.lock, super.key});

  final SmartLock lock;

  @override
  State<SmartLockDetailScreen> createState() => _SmartLockDetailScreenState();
}

class _SmartLockDetailScreenState extends State<SmartLockDetailScreen> {
  bool _isLocked = true;
  bool _isUnlocking = false;

  void _startUnlock() async {
    setState(() {
      _isUnlocking = true;
    });
    
    // Simulate hold for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLocked = false;
      _isUnlocking = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Door unlocked'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _cancelUnlock() {
    setState(() {
      _isUnlocking = false;
    });
  }

  void _lockDoor() {
    setState(() {
      _isLocked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Door locked'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Lock'),
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
              // Device Name and Serial Number
              Text(
                widget.lock.serialNumber,
                style: TextStyle(
                  fontSize: 18,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Serial Number: ${widget.lock.serialNumber ?? "123S102323"}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // Lock Status Circle
              _buildLockStatusCircle(primaryColor),
              
              const SizedBox(height: 24),

              // Instruction Text
              Text(
                _isUnlocking 
                    ? 'Hold to unlock...' 
                    : 'You need to on hold for a\nseconds to unlock the door',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              
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
    return GestureDetector(
      onLongPressStart: (_) {
        if (_isLocked) {
          _startUnlock();
        }
      },
      onLongPressEnd: (_) {
        if (_isUnlocking) {
          _cancelUnlock();
        }
      },
      onTap: () {
        if (!_isLocked) {
          _lockDoor();
        }
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 8,
          ),
        ),
        child: Stack(
          children: [
            // Progress indicator for unlocking
            if (_isUnlocking)
              Positioned.fill(
                child: CircularProgressIndicator(
                  strokeWidth: 8,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            
            // Lock Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryColor,
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
    // Calculate width for 2 columns with spacing
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
            Icon(
              icon,
              color: primaryColor,
              size: 32,
            ),
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