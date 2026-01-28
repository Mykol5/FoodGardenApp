// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'main_layout.dart';
import 'terms_privacy_modal.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _termsAccepted = false; // Track if terms have been accepted

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    // Validate fields
    if (_isLogin) {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter email and password'),
          ),
        );
        return;
      }
    } else {
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty ||
          _phoneController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all fields'),
          ),
        );
        return;
      } else if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
          ),
        );
        return;
      }
    }

    // For SIGN UP: Show Terms & Privacy Modal
    if (!_isLogin) {
      // Check if terms have been accepted already
      if (!_termsAccepted) {
        await _showTermsModal();
        return; // Don't proceed further until terms are accepted
      }
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to main screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainLayout(),
        ),
      );
    }
  }

  Future<void> _showTermsModal() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsPrivacyModal(
        onAccept: _onTermsAccepted,
      ),
    );
    
    // Handle the result if needed
    if (result != null) {
      setState(() {
        _termsAccepted = true;
      });
    }
  }

  // Static method to handle terms acceptance
  static void _onTermsAccepted() {
    // This will be called when user accepts terms
    // You can add any logic here, like saving to preferences
    print('Terms accepted');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            width: double.infinity,
            child: Column(
              children: [
                // Hero Section
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E8E4),
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAqKALFRp3tHZbCD5q27mlvLlDWEAPxQLnnkwyBaK9kl_rcOhik8GPbKoXCa8FCV9daZBAzjUln6oGaR0W8PyMxpxm913SPbMwEMCDfrl9-X76-0HyN334ZmDMcy8J-9klcu6pVCTr7yMt5jKdYVanWXURJCgceU1i1lah9_5ptVJyOihlziOjKOI1MnaivIxwEyaa567HSJ6lM7R4xKsdFEizzOvinwBSBVJy7mxrD2LLHxT8Wynpvw9oA3NRuOKvXb0YxjSgS7YXr',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          isDarkMode 
                              ? const Color(0xFF212C28).withOpacity(0.9)
                              : const Color(0xFFF9F8F6),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Title and Description
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  transform: Matrix4.translationValues(0, -32, 0),
                  child: Column(
                    children: [
                      Text(
                        'Rooted in Community',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : const Color(0xFF101816),
                          height: 1.25,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join 5,000+ local gardeners sharing their harvest and tracking sustainability.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? const Color(0xFFA1B8B0) : const Color(0xFF5C8A7A),
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Auth Toggle
                Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFECE9E3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLoading) {
                              setState(() {
                                _isLogin = true;
                                _termsAccepted = false; // Reset terms acceptance on toggle
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _isLogin
                                  ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _isLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _isLogin
                                      ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
                                      : const Color(0xFF5C8A7A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLoading) {
                              setState(() {
                                _isLogin = false;
                              });
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: !_isLogin
                                  ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_isLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: !_isLogin
                                      ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
                                      : const Color(0xFF5C8A7A),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Fields
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // Email Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Garden Email',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : const Color(0xFF101816),
                              ),
                            ),
                          ),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                              ),
                            ),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: _emailController,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'your@garden.com',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFA1B8B0),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                  enabled: !_isLoading,
                                ),
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.local_florist,
                                    color: const Color(0xFF39AC86).withOpacity(0.6),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Phone Field (only for Sign Up)
                      if (!_isLogin) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                ),
                              ),
                            ),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '+1 (555) 123-4567',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFA1B8B0),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    ),
                                    enabled: !_isLoading,
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: Icon(
                                      Icons.phone,
                                      color: const Color(0xFF5C8A7A),
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Password Field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Secure Password',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                  ),
                                ),
                                if (_isLogin)
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            // Forgot password action
                                          },
                                    child: const Text(
                                      'Forgot?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE59866),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                              ),
                            ),
                            child: Stack(
                              children: [
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFFA1B8B0),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                  ),
                                  enabled: !_isLoading,
                                ),
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: const Color(0xFF5C8A7A),
                                      size: 24,
                                    ),
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 0, 0),
                            child: Text(
                              'Tip: Use 8+ characters with a mix of letters and symbols.',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF5C8A7A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Confirm Password Field (only for Sign Up)
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Confirm Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                ),
                              ),
                            ),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : const Color(0xFF101816),
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFA1B8B0),
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    ),
                                    enabled: !_isLoading,
                                  ),
                                  Positioned(
                                    right: 16,
                                    top: 0,
                                    bottom: 0,
                                    child: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                        color: const Color(0xFF5C8A7A),
                                        size: 24,
                                      ),
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              setState(() {
                                                _obscureConfirmPassword = !_obscureConfirmPassword;
                                              });
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // CTA Button with Loading Effect
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _isLoading ? const Color(0xFF39AC86).withOpacity(0.7) : const Color(0xFF39AC86),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: _isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(0xFF39AC86).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _isLoading ? null : _handleAuth,
                        child: _isLoading
                            ? Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin ? 'Login to Garden' : 'Join the Garden',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.eco,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFA1B8B0),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Social Auth Buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      // Google login
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const FlutterLogo(
                                      style: FlutterLogoStyle.horizontal,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      // Apple login
                                    },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Apple',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer - Terms Link
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Text.rich(
                    TextSpan(
                      text: 'By joining, you agree to our ',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF5C8A7A),
                        height: 1.5,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Show Terms & Privacy modal
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => TermsPrivacyModal(
                                  onAccept: () {
                                    // Terms accepted
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'Terms',
                              style: const TextStyle(
                                color: Color(0xFF39AC86),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              // Show Terms & Privacy modal
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => TermsPrivacyModal(
                                  onAccept: () {
                                    // Terms accepted
                                  },
                                ),
                              );
                            },
                            child: Text(
                              'Privacy Policy',
                              style: const TextStyle(
                                color: Color(0xFF39AC86),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'main_layout.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _isLogin = true;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false; // Added for loading state

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleAuth() async {
//     // Validate fields
//     if (_isLogin) {
//       if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enter email and password'),
//           ),
//         );
//         return;
//       }
//     } else {
//       if (_emailController.text.isEmpty ||
//           _passwordController.text.isEmpty ||
//           _confirmPasswordController.text.isEmpty ||
//           _phoneController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please fill all fields'),
//           ),
//         );
//         return;
//       } else if (_passwordController.text != _confirmPasswordController.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Passwords do not match'),
//           ),
//         );
//         return;
//       }
//     }

//     // Start loading
//     setState(() {
//       _isLoading = true;
//     });

//     // Simulate API call delay
//     await Future.delayed(const Duration(seconds: 2));

//     // Navigate to main screen
//     if (mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (context) => const MainLayout(),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height,
//             ),
//             width: double.infinity,
//             child: Column(
//               children: [
//                 // Hero Section
//                 Container(
//                   height: 280,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE0E8E4),
//                     image: const DecorationImage(
//                       image: NetworkImage(
//                         'https://lh3.googleusercontent.com/aida-public/AB6AXuAqKALFRp3tHZbCD5q27mlvLlDWEAPxQLnnkwyBaK9kl_rcOhik8GPbKoXCa8FCV9daZBAzjUln6oGaR0W8PyMxpxm913SPbMwEMCDfrl9-X76-0HyN334ZmDMcy8J-9klcu6pVCTr7yMt5jKdYVanWXURJCgceU1i1lah9_5ptVJyOihlziOjKOI1MnaivIxwEyaa567HSJ6lM7R4xKsdFEizzOvinwBSBVJy7mxrD2LLHxT8Wynpvw9oA3NRuOKvXb0YxjSgS7YXr',
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: [
//                           isDarkMode 
//                               ? const Color(0xFF212C28).withOpacity(0.9)
//                               : const Color(0xFFF9F8F6),
//                           Colors.transparent,
//                           Colors.transparent,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Title and Description
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
//                   transform: Matrix4.translationValues(0, -32, 0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Rooted in Community',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                           height: 1.25,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Join 5,000+ local gardeners sharing their harvest and tracking sustainability.',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDarkMode ? const Color(0xFFA1B8B0) : const Color(0xFF5C8A7A),
//                           fontWeight: FontWeight.w500,
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Auth Toggle
//                 Container(
//                   margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFECE9E3),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             if (!_isLoading) {
//                               setState(() {
//                                 _isLogin = true;
//                               });
//                             }
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: _isLogin
//                                   ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                               boxShadow: _isLogin
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 2,
//                                         offset: const Offset(0, 1),
//                                       ),
//                                     ]
//                                   : null,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Login',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: _isLogin
//                                       ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
//                                       : const Color(0xFF5C8A7A),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             if (!_isLoading) {
//                               setState(() {
//                                 _isLogin = false;
//                               });
//                             }
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               color: !_isLogin
//                                   ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(8),
//                               boxShadow: !_isLogin
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 2,
//                                         offset: const Offset(0, 1),
//                                       ),
//                                     ]
//                                   : null,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Sign Up',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: !_isLogin
//                                       ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
//                                       : const Color(0xFF5C8A7A),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Form Fields
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                   child: Column(
//                     children: [
//                       // Email Field
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: Text(
//                               'Garden Email',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                               ),
//                             ),
//                             child: Stack(
//                               children: [
//                                 TextField(
//                                   controller: _emailController,
//                                   style: TextStyle(
//                                     color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                     fontSize: 16,
//                                   ),
//                                   decoration: InputDecoration(
//                                     hintText: 'your@garden.com',
//                                     hintStyle: const TextStyle(
//                                       color: Color(0xFFA1B8B0),
//                                     ),
//                                     border: InputBorder.none,
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                   ),
//                                   enabled: !_isLoading, // Disable when loading
//                                 ),
//                                 Positioned(
//                                   right: 16,
//                                   top: 0,
//                                   bottom: 0,
//                                   child: Icon(
//                                     Icons.local_florist,
//                                     color: const Color(0xFF39AC86).withOpacity(0.6),
//                                     size: 24,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 16),

//                       // Phone Field (only for Sign Up)
//                       if (!_isLogin) ...[
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 8),
//                               child: Text(
//                                 'Phone Number',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                                 ),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   TextField(
//                                     controller: _phoneController,
//                                     keyboardType: TextInputType.phone,
//                                     style: TextStyle(
//                                       color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                       fontSize: 16,
//                                     ),
//                                     decoration: InputDecoration(
//                                       hintText: '+1 (555) 123-4567',
//                                       hintStyle: const TextStyle(
//                                         color: Color(0xFFA1B8B0),
//                                       ),
//                                       border: InputBorder.none,
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                     ),
//                                     enabled: !_isLoading, // Disable when loading
//                                   ),
//                                   Positioned(
//                                     right: 16,
//                                     top: 0,
//                                     bottom: 0,
//                                     child: Icon(
//                                       Icons.phone,
//                                       color: const Color(0xFF5C8A7A),
//                                       size: 24,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                       ],

//                       // Password Field
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Secure Password',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                   ),
//                                 ),
//                                 if (_isLogin)
//                                   TextButton(
//                                     onPressed: _isLoading
//                                         ? null
//                                         : () {
//                                             // Forgot password action
//                                           },
//                                     child: const Text(
//                                       'Forgot?',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFFE59866),
//                                         letterSpacing: 1,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                               ),
//                             ),
//                             child: Stack(
//                               children: [
//                                 TextField(
//                                   controller: _passwordController,
//                                   obscureText: _obscurePassword,
//                                   style: TextStyle(
//                                     color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                     fontSize: 16,
//                                   ),
//                                   decoration: InputDecoration(
//                                     hintText: '••••••••',
//                                     hintStyle: const TextStyle(
//                                       color: Color(0xFFA1B8B0),
//                                     ),
//                                     border: InputBorder.none,
//                                     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                   ),
//                                   enabled: !_isLoading, // Disable when loading
//                                 ),
//                                 Positioned(
//                                   right: 16,
//                                   top: 0,
//                                   bottom: 0,
//                                   child: IconButton(
//                                     icon: Icon(
//                                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                                       color: const Color(0xFF5C8A7A),
//                                       size: 24,
//                                     ),
//                                     onPressed: _isLoading
//                                         ? null
//                                         : () {
//                                             setState(() {
//                                               _obscurePassword = !_obscurePassword;
//                                             });
//                                           },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(4, 8, 0, 0),
//                             child: Text(
//                               'Tip: Use 8+ characters with a mix of letters and symbols.',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: const Color(0xFF5C8A7A),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Confirm Password Field (only for Sign Up)
//                       if (!_isLogin) ...[
//                         const SizedBox(height: 16),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(bottom: 8),
//                               child: Text(
//                                 'Confirm Password',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                                 ),
//                               ),
//                               child: Stack(
//                                 children: [
//                                   TextField(
//                                     controller: _confirmPasswordController,
//                                     obscureText: _obscureConfirmPassword,
//                                     style: TextStyle(
//                                       color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                       fontSize: 16,
//                                     ),
//                                     decoration: InputDecoration(
//                                       hintText: '••••••••',
//                                       hintStyle: const TextStyle(
//                                         color: Color(0xFFA1B8B0),
//                                       ),
//                                       border: InputBorder.none,
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                     ),
//                                     enabled: !_isLoading, // Disable when loading
//                                   ),
//                                   Positioned(
//                                     right: 16,
//                                     top: 0,
//                                     bottom: 0,
//                                     child: IconButton(
//                                       icon: Icon(
//                                         _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
//                                         color: const Color(0xFF5C8A7A),
//                                         size: 24,
//                                       ),
//                                       onPressed: _isLoading
//                                           ? null
//                                           : () {
//                                               setState(() {
//                                                 _obscureConfirmPassword = !_obscureConfirmPassword;
//                                               });
//                                             },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // CTA Button with Loading Effect
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                   child: Container(
//                     width: double.infinity,
//                     height: 56,
//                     decoration: BoxDecoration(
//                       color: _isLoading ? const Color(0xFF39AC86).withOpacity(0.7) : const Color(0xFF39AC86),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: _isLoading
//                           ? null
//                           : [
//                               BoxShadow(
//                                 color: const Color(0xFF39AC86).withOpacity(0.2),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(12),
//                         onTap: _isLoading ? null : _handleAuth,
//                         child: _isLoading
//                             ? Center(
//                                 child: SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white.withOpacity(0.9),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     _isLogin ? 'Login to Garden' : 'Join the Garden',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   const Icon(
//                                     Icons.eco,
//                                     color: Colors.white,
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Divider
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Divider(
//                           color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                           thickness: 1,
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           'Or continue with',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFFA1B8B0),
//                             letterSpacing: 2,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(
//                           color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                           thickness: 1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Social Auth Buttons
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                             ),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(12),
//                               onTap: _isLoading
//                                   ? null
//                                   : () {
//                                       // Google login
//                                     },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   // Using FlutterLogo as Google logo (closest built-in)
//                                   Container(
//                                     width: 20,
//                                     height: 20,
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(2),
//                                     ),
//                                     child: const FlutterLogo(
//                                       style: FlutterLogoStyle.horizontal,
//                                       size: 20,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Google',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: isDarkMode ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                             ),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(12),
//                               onTap: _isLoading
//                                   ? null
//                                   : () {
//                                       // Apple login
//                                     },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.apple,
//                                     color: isDarkMode ? Colors.white : Colors.black,
//                                     size: 24,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Apple',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w600,
//                                       color: isDarkMode ? Colors.white : Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Footer
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
//                   child: Text.rich(
//                     TextSpan(
//                       text: 'By joining, you agree to our ',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: const Color(0xFF5C8A7A),
//                         height: 1.5,
//                       ),
//                       children: [
//                         TextSpan(
//                           text: 'Terms',
//                           style: const TextStyle(
//                             color: Color(0xFF39AC86),
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                         const TextSpan(text: ' and '),
//                         TextSpan(
//                           text: 'Privacy Policy',
//                           style: const TextStyle(
//                             color: Color(0xFF39AC86),
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                         const TextSpan(text: '.'),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }











// // lib/screens/login_screen.dart
// import 'package:flutter/material.dart';
// import 'main_layout.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool _isLogin = true;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDarkMode ? const Color(0xFF212C28) : const Color(0xFFF9F8F6),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Container(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height,
//             ),
//             width: double.infinity,
//             child: Column(
//               children: [
//                 // Hero Section with Image
//                 Container(
//                   height: 280,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFE0E8E4),
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(20),
//                       bottomRight: Radius.circular(20),
//                     ),
//                     image: const DecorationImage(
//                       image: NetworkImage(
//                         'https://images.unsplash.com/photo-1592417817098-8fd3d9eb14a5?q=80&w=2087&auto=format&fit=crop',
//                       ),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                         colors: [
//                           isDarkMode 
//                               ? const Color(0xFF212C28).withOpacity(0.9)
//                               : const Color(0xFFF9F8F6).withOpacity(0.9),
//                           Colors.transparent,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Title and Description
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Rooted in Community',
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Join 5,000+ local gardeners sharing their harvest and tracking sustainability.',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDarkMode ? const Color(0xFFA1B8B0) : const Color(0xFF5C8A7A),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Login/Signup Toggle
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 24),
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFECE9E3),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _isLogin = true;
//                             });
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: _isLogin
//                                   ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: _isLogin
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 2,
//                                         offset: const Offset(0, 1),
//                                       ),
//                                     ]
//                                   : null,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Login',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: _isLogin
//                                       ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
//                                       : const Color(0xFF5C8A7A),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _isLogin = false;
//                             });
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: !_isLogin
//                                   ? (isDarkMode ? const Color(0xFF39AC86) : Colors.white)
//                                   : Colors.transparent,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: !_isLogin
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 2,
//                                         offset: const Offset(0, 1),
//                                       ),
//                                     ]
//                                   : null,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Sign Up',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: !_isLogin
//                                       ? (isDarkMode ? Colors.white : const Color(0xFF39AC86))
//                                       : const Color(0xFF5C8A7A),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Form Fields
//                 Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       // Email Field
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Garden Email',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: _emailController,
//                               decoration: InputDecoration(
//                                 hintText: 'your@garden.com',
//                                 hintStyle: TextStyle(
//                                   color: const Color(0xFFA1B8B0),
//                                 ),
//                                 border: InputBorder.none,
//                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                 suffixIcon: Padding(
//                                   padding: const EdgeInsets.only(right: 8),
//                                   child: Icon(
//                                     Icons.local_florist,
//                                     color: const Color(0xFF39AC86).withOpacity(0.6),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 20),

//                       // Phone Field (only for Sign Up)
//                       if (!_isLogin) ...[
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Phone Number',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                                 ),
//                               ),
//                               child: TextField(
//                                 controller: _phoneController,
//                                 keyboardType: TextInputType.phone,
//                                 decoration: InputDecoration(
//                                   hintText: '+1 (555) 123-4567',
//                                   hintStyle: TextStyle(
//                                     color: const Color(0xFFA1B8B0),
//                                   ),
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                   suffixIcon: Padding(
//                                     padding: const EdgeInsets.only(right: 8),
//                                     child: Icon(
//                                       Icons.phone,
//                                       color: const Color(0xFF5C8A7A),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                       ],

//                       // Password Field
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Secure Password',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                                 ),
//                               ),
//                               if (_isLogin)
//                                 TextButton(
//                                   onPressed: () {
//                                     // Forgot password action
//                                   },
//                                   child: Text(
//                                     'Forgot?',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                       color: const Color(0xFFE59866),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             height: 56,
//                             decoration: BoxDecoration(
//                               color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: _passwordController,
//                               obscureText: _obscurePassword,
//                               decoration: InputDecoration(
//                                 hintText: '••••••••',
//                                 hintStyle: TextStyle(
//                                   color: const Color(0xFFA1B8B0),
//                                 ),
//                                 border: InputBorder.none,
//                                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                 suffixIcon: Padding(
//                                   padding: const EdgeInsets.only(right: 8),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       _obscurePassword ? Icons.visibility : Icons.visibility_off,
//                                       color: const Color(0xFF5C8A7A),
//                                     ),
//                                     onPressed: () {
//                                       setState(() {
//                                         _obscurePassword = !_obscurePassword;
//                                       });
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Tip: Use 8+ characters with a mix of letters and symbols.',
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: const Color(0xFF5C8A7A),
//                             ),
//                           ),
//                         ],
//                       ),

//                       // Confirm Password Field (only for Sign Up)
//                       if (!_isLogin) ...[
//                         const SizedBox(height: 20),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Confirm Password',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: isDarkMode ? Colors.white : const Color(0xFF101816),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Container(
//                               height: 56,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2D3A35) : const Color(0xFFFDFBF7),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                                 ),
//                               ),
//                               child: TextField(
//                                 controller: _confirmPasswordController,
//                                 obscureText: _obscureConfirmPassword,
//                                 decoration: InputDecoration(
//                                   hintText: '••••••••',
//                                   hintStyle: TextStyle(
//                                     color: const Color(0xFFA1B8B0),
//                                   ),
//                                   border: InputBorder.none,
//                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
//                                   suffixIcon: Padding(
//                                     padding: const EdgeInsets.only(right: 8),
//                                     child: IconButton(
//                                       icon: Icon(
//                                         _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
//                                         color: const Color(0xFF5C8A7A),
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],

//                       const SizedBox(height: 24),

//                       // Login/Signup Button
//                       Container(
//                         width: double.infinity,
//                         height: 56,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF39AC86),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFF39AC86).withOpacity(0.3),
//                               blurRadius: 10,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Material(
//                           color: Colors.transparent,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(12),
//                             onTap: () {
//                               // Validate and handle login/signup
//                               if (_isLogin) {
//                                 if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Please enter email and password'),
//                                     ),
//                                   );
//                                 } else {
//                                   Navigator.of(context).pushReplacement(
//                                     MaterialPageRoute(
//                                       builder: (context) => const MainLayout(),
//                                     ),
//                                   );
//                                 }
//                               } else {
//                                 // Sign up validation
//                                 if (_emailController.text.isEmpty ||
//                                     _passwordController.text.isEmpty ||
//                                     _confirmPasswordController.text.isEmpty ||
//                                     _phoneController.text.isEmpty) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Please fill all fields'),
//                                     ),
//                                   );
//                                 } else if (_passwordController.text != _confirmPasswordController.text) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Passwords do not match'),
//                                     ),
//                                   );
//                                 } else {
//                                   Navigator.of(context).pushReplacement(
//                                     MaterialPageRoute(
//                                       builder: (context) => const MainLayout(),
//                                     ),
//                                   );
//                                 }
//                               }
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   _isLogin ? 'Login to Garden' : 'Join the Garden',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 const Icon(
//                                   Icons.eco,
//                                   color: Colors.white,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // Divider
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Divider(
//                               color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                               thickness: 1,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             child: Text(
//                               'Or continue with',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFFA1B8B0),
//                                 letterSpacing: 2,
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             child: Divider(
//                               color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                               thickness: 1,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 24),

//                       // Social Login Buttons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                                 ),
//                               ),
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(12),
//                                   onTap: () {
//                                     // Google login
//                                   },
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         width: 24,
//                                         height: 24,
//                                         decoration: BoxDecoration(
//                                           borderRadius: BorderRadius.circular(2),
//                                         ),
//                                         child: const FlutterLogo(
//                                           size: 20,
//                                           style: FlutterLogoStyle.horizontal,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'Google',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                           color: isDarkMode ? Colors.white : Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Container(
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: isDarkMode ? const Color(0xFF2D3A35) : Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: isDarkMode ? const Color(0xFF3D4D47) : const Color(0xFFD4E2DE),
//                                 ),
//                               ),
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: InkWell(
//                                   borderRadius: BorderRadius.circular(12),
//                                   onTap: () {
//                                     // Apple login
//                                   },
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.apple,
//                                         color: isDarkMode ? Colors.white : Colors.black,
//                                         size: 24,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         'Apple',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w600,
//                                           color: isDarkMode ? Colors.white : Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Footer
//                 Container(
//                   padding: const EdgeInsets.all(24),
//                   child: Text.rich(
//                     TextSpan(
//                       text: 'By joining, you agree to our ',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: const Color(0xFF5C8A7A),
//                       ),
//                       children: [
//                         TextSpan(
//                           text: 'Terms',
//                           style: const TextStyle(
//                             color: Color(0xFF39AC86),
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                         const TextSpan(text: ' and '),
//                         TextSpan(
//                           text: 'Privacy Policy',
//                           style: const TextStyle(
//                             color: Color(0xFF39AC86),
//                             fontWeight: FontWeight.bold,
//                             decoration: TextDecoration.underline,
//                           ),
//                         ),
//                         const TextSpan(text: '.'),
//                       ],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
