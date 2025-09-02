import 'package:flutter/material.dart';
import '../../services/SignUpPage/Api_Service.dart';
import '../../utils/auth_utils.dart';
import '../../utils/custom_alerts.dart';
import '../../models/user.dart';
import '../../validations/auth_validations.dart';
import '../Dashbord/dashbord_screen.dart';

class LoginTab extends StatefulWidget {
  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  // Store user data locally in this widget
  User? currentUser;
  bool isAuthenticated = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Test secure data fetch before login (should fail)
      try {
        final secureRes = await ApiService.fetchSecureData();
        print("🔐 Pre-login secure data response: ${secureRes.statusCode}");
      } catch (e) {
        print("🔐 Pre-login secure data failed (expected): $e");
      }

      final sanitizedUserId = AuthValidators.sanitizeLoginInput(_userIdController.text);

      final result = await ApiService.authenticateUser(
        sanitizedUserId,
        _passwordController.text,
      );

      if (result['success']) {
        // Store user data locally
        currentUser = result['user'];

        // Debug: Check token storage
        await AuthUtils.debugPrintAllPrefs();
        final storedToken = await AuthUtils.getCurrentToken();
        print('🪙 Token after login: $storedToken');

        // Use ApiService's isAuthenticated method for consistency
        final isAuth = await ApiService.isAuthenticated();
        print('✅ Is user authenticated: $isAuth');

        if (isAuth) {
          // Test secure data fetch after login (should succeed)
          try {
            final secureRes = await ApiService.fetchSecureData();
            print("🔐 Post-login secure data response: ${secureRes.statusCode}");
            print("🔐 Post-login secure data body: ${secureRes.body}");
          } catch (e) {
            print("🔐 Post-login secure data failed: $e");
          }

          CustomAlerts.toastSuccess(context, 'Welcome ${result['user'].name}');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(),
              ),
            );
          }
        } else {
          CustomAlerts.toastError(context, 'Authentication failed. Please log in again.');
        }
      } else {
        // Login failed
        CustomAlerts.toastError(context, result['message'] ?? 'Login failed');
      }

    } catch (error) {
      print('❌ Login error: $error');
      CustomAlerts.toastError(
        context,
        'Error logging in. Please try again after sometime.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User ID Field
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'e.g., CA01, CS123, CL999',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: AuthValidators.validateUserId,
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              validator: AuthValidators.validatePassword,
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: 24),

            // Login Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF1A1A1A),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text(
                'LOGIN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}