import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/components/my_button.dart';
import 'package:my_app/components/my_textfield.dart';
import 'package:my_app/components/square_tile.dart';
import 'package:my_app/services/auth_service.dart';

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
  bool _isGoogleSignInLoading = false;

  void signUserUp() async {
    // Validate inputs first
    if (emailController.text.trim().isEmpty) {
      showErrorMessage('Please enter your email address');
      return;
    }

    if (passwordController.text.isEmpty) {
      showErrorMessage('Please enter a password');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showErrorMessage('Passwords don\'t match');
      return;
    }

    if (passwordController.text.length < 6) {
      showErrorMessage('Password must be at least 6 characters long');
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
      await AuthService.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on EmailAlreadyExistsException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showEmailConflictDialog(e);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage(_getFirebaseErrorMessage(e.code));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorMessage('Registration failed: ${e.toString()}');
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
                'Welcome ${userCredential.user?.displayName ?? 'User'}!',
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
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Registration failed. Please try again.';
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
              const Text('Email Already Registered'),
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
                    Icon(
                      exception.signInMethod == SignInMethod.google
                          ? Icons.login
                          : Icons.email,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exception.signInMethod == SignInMethod.google
                            ? 'Use "Continue with Google" to sign in'
                            : 'Use "Sign In" with your email and password',
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
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to sign in page
                widget.onTap?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Sign In'),
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
          content: Text(message),
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

                  const SizedBox(height: 32),

                  MyButton(
                    text: 'Create Account',
                    onTap: signUserUp,
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
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
