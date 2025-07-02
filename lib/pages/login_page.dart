import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/my_button.dart';
import 'package:my_app/components/my_textfield.dart';
import 'package:my_app/components/square_tile.dart';
import 'package:my_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isGoogleSignInLoading = false;

  void signUserIn() async {
    if (emailController.text.trim().isEmpty) {
      showErrorMessage('Please enter your email address');
      return;
    }

    if (passwordController.text.isEmpty) {
      showErrorMessage('Please enter your password');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage(_getFirebaseErrorMessage(e.code));
      }
    } catch (e) {
      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage('Login failed: ${e.toString()}');
      }
    }
  }

  void signInWithGoogle() async {
    setState(() {
      _isGoogleSignInLoading = true;
    });

    try {
      final isAvailable = await AuthService.isGooglePlayServicesAvailable();
      if (!isAvailable) {
        throw Exception('Google Play Services is not available on this device');
      }

      final userCredential = await AuthService.signInWithGoogle();

      if (userCredential != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back ${userCredential.user?.displayName ?? 'User'}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on EmailAlreadyExistsException catch (e) {
      if (mounted) {
        showEmailConflictDialog(e);
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSignInLoading = false;
        });
      }
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  void showEmailConflictDialog(EmailAlreadyExistsException exception) {
    if (!mounted) return; // Add this check

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[600]),
              const SizedBox(width: 8),
              const Text('Account Conflict'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(exception.message),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please sign in with your email and password above',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showErrorMessage(String message) {
    if (!mounted) return; // Add this check

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600]),
              const SizedBox(width: 8),
              const Text('Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (message.contains('configuration')) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Troubleshooting:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Check your internet connection\n'
                        '• Verify Google Sign-In is configured\n'
                        '• Try signing in with email instead',
                        style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
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
              child: Column(
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
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue shopping',
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
                    hintText: 'Password',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  MyButton(
                    text: "Sign In",
                    onTap: signUserIn,
                    backgroundColor: Colors.green[600]!,
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SquareTile(
                    imagePath: 'lib/images/google.png',
                    onTap: _isGoogleSignInLoading ? null : signInWithGoogle,
                    label: _isGoogleSignInLoading
                        ? 'Signing in...'
                        : 'Continue with Google',
                    isLoading: _isGoogleSignInLoading,
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Sign Up',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
