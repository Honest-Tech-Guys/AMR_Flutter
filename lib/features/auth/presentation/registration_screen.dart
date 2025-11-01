import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- 1. UPDATED STATE FOR THE DROPDOWN ---
  String? _selectedRole;
  // This is your list
  final List<String> _roles = [
    "Agency",
    "Agent",
    "Tenant",
    "Owner",
  ];
  // ------------------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, call the register method
      await ref.read(registrationControllerProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            role: _selectedRole!, // <-- 2. PASS THE ROLE STRING
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final regState = ref.watch(registrationControllerProvider);
    final bool isLoading = regState.isLoading;
    const Color primaryColor = Color(0xFF076633);
    const Color backgroundColor = Color.fromARGB(255, 255, 255, 255);

    // Listen for success or error states
    ref.listen(registrationControllerProvider, (previous, next) {
      // If the new state is an error, show snackbar
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      // --- THIS IS THE FIX ---
      // Only show success if the new state is data AND the value is true
      if (next is AsyncData && next.value == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop back to the login screen
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo.png',
                  width: 250,
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: Text(
                              "Create an account",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text(
                              "Let's create an account to get started",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- 3. UPDATED DROPDOWN WIDGET ---
                          _buildLabel("Select Role"),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            hint: const Text('Select your role'),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_search_outlined),
                              border: OutlineInputBorder(),
                            ),
                            // Create items from the list of strings
                            items: _roles.map((String role) {
                              return DropdownMenuItem<String>(
                                value: role, // The value is the string itself
                                child: Text(role), // The text is also the string
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Please select a role' : null,
                          ),
                          const SizedBox(height: 16),
                          // -------------------------------

                          _buildLabel("Full Name"),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) =>
                                val!.isEmpty ? 'Please enter your name' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel("Email Address"),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) =>
                                !(val?.contains('@') ?? false)
                                    ? 'Please enter a valid email'
                                    : null,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel("Phone Number"),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your phone number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (val) =>
                                val!.isEmpty ? 'Please enter your phone' : null,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel("Password"),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) => val!.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          _buildLabel("Confirm Password"),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Confirm your password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: _submit,
                                  child: const Text('Create an account'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pop();
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}