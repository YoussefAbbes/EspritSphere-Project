import 'package:flutter/material.dart';
import '../../utils/routes.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? error;
  String? success;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _fadeAnimation = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
      error = null;
      success = null;
    });

    try {
      await _authService.resetPassword(_emailController.text);
      if (mounted) {
        setState(() {
          success = 'Password reset email sent. Check your inbox.';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
        loading = false;
      });
    }
  }

  // Responsive helpers
  double _responsiveFontSize(double screenWidth, double mobile, double tablet, double desktop) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 800) return tablet;
    return mobile;
  }

  double _responsiveWidth(double screenWidth) {
    if (screenWidth >= 1200) return 500;
    if (screenWidth >= 800) return 400;
    return screenWidth * 0.9; // 90% of screen width for mobile
  }

  double _responsiveIconSize(double screenWidth, double mobile, double tablet, double desktop) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 800) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = screenWidth >= 800 ? 24.0 : 16.0;
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _AnimatedBackground(
            animation: _fadeAnimation,
            onPrimaryColor: theme.colorScheme.onPrimary,
            primaryColor: theme.colorScheme.primary,
            secondaryColor: theme.colorScheme.secondary,
            screenWidth: screenWidth,
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Form(
                    key: _formKey,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: _responsiveWidth(screenWidth)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Decorative Icon
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + _fadeAnimation.value * 0.1,
                                child: Icon(
                                  Icons.lock_reset,
                                  size: _responsiveIconSize(screenWidth, 60, 80, 100),
                                  color: theme.colorScheme.onPrimary,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: _responsiveFontSize(screenWidth, 28, 36, 48),
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'Enter your email to receive a reset link',
                            style: TextStyle(
                              fontSize: _responsiveFontSize(screenWidth, 14, 16, 18),
                              color: theme.colorScheme.onPrimary.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          TextFormField(
                            controller: _emailController,
                            decoration: _inputDecoration('Email', Icons.email, screenWidth),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) => val == null || !val.contains('@')
                                ? 'Enter a valid email'
                                : null,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          if (success != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: padding),
                              child: Text(
                                success!,
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontSize: _responsiveFontSize(screenWidth, 12, 14, 16),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (error != null)
                            Padding(
                              padding: EdgeInsets.only(bottom: padding),
                              child: Text(
                                error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: _responsiveFontSize(screenWidth, 12, 14, 16),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          loading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: _submit,
                                  child: Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontSize: _responsiveFontSize(screenWidth, 16, 18, 20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          SizedBox(height: screenHeight * 0.02),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
                            child: Text(
                              'Back to Login',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary.withOpacity(0.9),
                                fontSize: _responsiveFontSize(screenWidth, 14, 16, 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, double screenWidth) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
        fontSize: _responsiveFontSize(screenWidth, 14, 16, 18),
      ),
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
        size: _responsiveIconSize(screenWidth, 20, 24, 28),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;
  final Color onPrimaryColor;
  final Color primaryColor;
  final Color secondaryColor;
  final double screenWidth;

  const _AnimatedBackground({
    required this.animation,
    required this.onPrimaryColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 178, 42, 42).withOpacity(animation.value),
                primaryColor.withOpacity(animation.value),
                secondaryColor.withOpacity(animation.value),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundPainter(
              animationValue: animation.value,
              onPrimaryColor: onPrimaryColor,
              screenWidth: screenWidth,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color onPrimaryColor;
  final double screenWidth;

  _BackgroundPainter({
    required this.animationValue,
    required this.onPrimaryColor,
    required this.screenWidth,
  });

  double _responsiveIconSize(double mobile, double tablet, double desktop) {
    if (screenWidth >= 1200) return desktop;
    if (screenWidth >= 800) return tablet;
    return mobile;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw animated curves
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * (0.3 + 0.1 * animationValue),
      size.width * 0.8,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * (0.3 - 0.1 * animationValue),
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    paint.color = onPrimaryColor.withOpacity(0.2);
    canvas.drawPath(path, paint);

    // Draw scattered circles for decoration
    final circlePaint = Paint()
      ..color = onPrimaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        size.width * (0.2 + i * 0.15) * (1 + animationValue * 0.1),
        size.height * (0.2 + i * 0.1) * (1 - animationValue * 0.1),
      );
      canvas.drawCircle(
        offset,
        _responsiveIconSize(5, 7, 10) * (1 + animationValue * 0.2),
        circlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}