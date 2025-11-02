import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  String _email = "your-email@loading...";

  @override
  void initState() {
    super.initState();
    _getEmail();
  }

  // Get the unverified email from secure storage
  void _getEmail() async {
    final email = await ref.read(authRepositoryProvider).getUnverifiedEmail();
    if (email != null && mounted) {
      setState(() {
        _email = email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF076633);
    
    // Watch the resend provider for loading/errors
    final resendState = ref.watch(resendEmailProvider);

    // Listen for success/error snackbars
    ref.listen(resendEmailProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Show success only if it was just loading
      if (prev is AsyncLoading && next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification link sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // We add an automatic back button, so no need for a manual logout here
        // unless you specifically want it. I'll remove it for a cleaner look.
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_unread_outlined,
                size: 100,
                color: primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'A verification link has been sent to your email address:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                _email, // Display the fetched email
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // --- "Resend Link" Button ---
              resendState.isLoading
                  ? const CircularProgressIndicator(color: primaryColor)
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Call the resend method
                        ref.read(resendEmailProvider.notifier).resend();
                      },
                      child: const Text('Resend Link'),
                    ),
              
              const SizedBox(height: 16),

              // --- "Contact Support" Button (NEW) ---
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  // TODO: Implement contact support logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact support feature coming soon!'),
                    ),
                  );
                },
                child: const Text('Contact Support'),
              ),

              const SizedBox(height: 24),

              // --- "Back to Login" Button (NEW) ---
              TextButton(
                onPressed: () {
                  // This logs the user out, and the router
                  // will automatically redirect to the login screen.
                  ref.read(authControllerProvider.notifier).logout();
                },
                child: const Text(
                  '« Back to Login',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}