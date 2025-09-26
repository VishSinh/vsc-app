import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vsc_app/core/constants/app_config.dart';
import 'package:vsc_app/core/constants/route_constants.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/utils/responsive_utils.dart';
import 'package:vsc_app/core/utils/responsive_text.dart';
import 'package:vsc_app/features/home/presentation/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _bgController;
  // Removed custom focus styling; keep simple fields

  // replaced with mesh gradient

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat(reverse: true);
    // simple fields; no custom focus nodes
    // Initialize the login form in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().initializeLoginForm();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    // nothing extra to dispose
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    // Update the form with current values
    authProvider.updateLoginForm(phone: _phoneController.text.trim(), password: _passwordController.text);

    final success = await authProvider.login();

    if (success && mounted) {
      // Navigate to dashboard
      context.go(RouteConstants.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(child: _AnimatedMeshGradient(animation: _bgController)),
        Center(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveUtils.getFormWidth(context)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConfig.borderRadiusLarge),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppConfig.borderRadiusLarge),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.2),
                    ),
                    child: Padding(
                      padding: ResponsiveUtils.getResponsivePadding(context),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: AppConfig.defaultPadding),
                            _AnimatedFunkyTitle(text: 'Vijay Shaadi Card'),
                            SizedBox(height: AppConfig.smallPadding),
                            Text(
                              UITextConstants.signInTitle,
                              style: ResponsiveText.getSubtitle(context).copyWith(color: AppConfig.grey600),
                            ).animate().fadeIn(duration: 350.ms, delay: 180.ms).moveY(begin: 8, end: 0, duration: 350.ms),
                            SizedBox(height: AppConfig.largePadding),

                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: UITextConstants.phoneNumber,
                                prefixIcon: const Icon(Icons.phone),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                  borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.6),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return UITextConstants.pleaseEnterPhone;
                                }
                                if (value.length < 10) {
                                  return UITextConstants.pleaseEnterValidPhone;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                context.read<AuthProvider>().updateLoginForm(phone: value);
                              },
                            ).animate().fadeIn(duration: 400.ms, delay: 240.ms).moveY(begin: 10, end: 0, duration: 400.ms),
                            SizedBox(height: AppConfig.defaultPadding),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: UITextConstants.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                  borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.6),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return UITextConstants.pleaseEnterPassword;
                                }
                                if (value.length < 3) {
                                  return UITextConstants.passwordTooShort;
                                }
                                return null;
                              },
                              onChanged: (value) {
                                context.read<AuthProvider>().updateLoginForm(password: value);
                              },
                            ).animate().fadeIn(duration: 400.ms, delay: 320.ms).moveY(begin: 10, end: 0, duration: 400.ms),
                            SizedBox(height: AppConfig.largePadding),

                            SizedBox(height: AppConfig.defaultPadding),

                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                if (authProvider.errorMessage != null) {
                                  return Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(AppConfig.smallPadding),
                                    margin: EdgeInsets.only(bottom: AppConfig.defaultPadding),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppConfig.borderRadiusSmall),
                                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: TextStyle(color: Colors.red[700]),
                                      textAlign: TextAlign.center,
                                    ),
                                  ).animate().fadeIn(duration: 250.ms).moveY(begin: -6, end: 0, duration: 250.ms);
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) => SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)]),
                                    borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(vertical: AppConfig.spacingMedium),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.borderRadiusMedium)),
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text(
                                            UITextConstants.signIn,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                                          ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 450.ms, delay: 360.ms).moveY(begin: 12, end: 0, duration: 450.ms),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).moveY(begin: 12, end: 0, duration: 400.ms),
            ),
          ),
        ),
      ],
    ),
  );
}

class _AnimatedFunkyTitle extends StatelessWidget {
  const _AnimatedFunkyTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final handwriting = GoogleFonts.pacifico(
      textStyle: ResponsiveText.getHeadlineStyle(context).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.0, color: Colors.white),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
              shaderCallback: (bounds) =>
                  const LinearGradient(colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)]).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              blendMode: BlendMode.srcIn,
              child: Text(text, style: handwriting.copyWith(fontSize: handwriting.fontSize != null ? handwriting.fontSize! + 4 : null)),
            )
            // One-time entrance
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic)
            // Continuous shimmer loop
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1800.ms),
        const SizedBox(height: 4),
        Container(
          height: 3,
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)]),
          ),
        ).animate().scaleX(begin: 0.0, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),
      ],
    );
  }
}

class _AnimatedMeshGradient extends StatelessWidget {
  const _AnimatedMeshGradient({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => CustomPaint(painter: _MeshPainter(progress: animation.value)),
    );
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF0D47A1), // deep blue
      const Color(0xFF1976D2), // primary
      const Color(0xFF64B5F6), // light blue
      const Color(0xFF2F80ED), // royal sky end
    ];

    final positions = [
      Offset(size.width * (0.2 + 0.05 * math.sin(progress * math.pi * 2)), size.height * 0.25),
      Offset(size.width * 0.8, size.height * (0.2 + 0.05 * math.cos(progress * math.pi * 2))),
      Offset(size.width * (0.3 + 0.05 * math.cos(progress * math.pi * 2)), size.height * 0.8),
      Offset(size.width * 0.75, size.height * (0.75 + 0.05 * math.sin(progress * math.pi * 2))),
    ];

    final radii = [size.shortestSide * 0.6, size.shortestSide * 0.5, size.shortestSide * 0.55, size.shortestSide * 0.45];

    final paint = Paint()..blendMode = BlendMode.srcOver;

    for (var i = 0; i < colors.length; i++) {
      final shader = RadialGradient(
        colors: [colors[i].withOpacity(0.50), colors[i].withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: positions[i], radius: radii[i]));
      paint.shader = shader;
      canvas.drawCircle(positions[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => oldDelegate.progress != progress;
}
