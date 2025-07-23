import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../components/square_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    final authController = context.read<AuthController>();
    final success = await authController.signUpWithEmail(
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _signInWithGoogle() async {
    final authController = context.read<AuthController>();
    final success = await authController.signInWithGoogle();

    if (success && mounted) {
      final user = authController.currentUser;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome ${user?.displayName ?? 'User'}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (message.contains('already registered')) ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onTap?.call(); // Switch to login page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Sign In'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Consumer<AuthController>(
                builder: (context, authController, child) {
                  // Show error dialog if there's an error
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (authController.errorMessage != null) {
                      _showErrorDialog(authController.errorMessage!);
                      authController.clearError();
                    }
                  });

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo and Brand
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 60,
                          color: Colors.green[600],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'FreshMart',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Fresh groceries delivered to your door',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Join us and start shopping fresh',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),

                      const SizedBox(height: 32),

                      MyTextfield(
                        controller: emailController,
                        hintText: 'Email Address',
                        obscureText: false,
                        prefixIcon: Icons.email_outlined,
                      ),

                      const SizedBox(height: 16),

                      MyTextfield(
                        controller: passwordController,
                        hintText: 'Password (min 6 characters)',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),

                      const SizedBox(height: 16),

                      MyTextfield(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),

                      const SizedBox(height: 24),

                      MyButton(
                        text: authController.isLoading
                            ? "Creating Account..."
                            : "Create Account",
                        onTap: authController.isLoading ? null : _signUp,
                        backgroundColor: Colors.green[600]!,
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      SquareTile(
                        imagePath: 'lib/images/google.png',
                        onTap: authController.isLoading
                            ? null
                            : _signInWithGoogle,
                        label: authController.isLoading
                            ? 'Signing in...'
                            : 'Continue with Google',
                        isLoading: authController.isLoading,
                      ),

                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
