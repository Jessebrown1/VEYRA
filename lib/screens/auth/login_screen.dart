import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/veyra_text_field.dart';
import '../home/home_shell.dart';
import '../onboarding/personality_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;

  const LoginScreen({
    super.key,
    this.initialEmail,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _emailController =
      TextEditingController(text: widget.initialEmail ?? '');

  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _errorMessage;

  bool get _canContinue =>
      _emailController.text.trim().contains('@') &&
      _passwordController.text.isNotEmpty &&
      !_submitting;

  Future<void> _continue() async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final appState = context.read<AppState>();

      await appState.authApi.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await appState.loadFromSession();

      if (!mounted) return;

      if (appState.status == AppLaunchStatus.ready) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const HomeShell(),
          ),
          (route) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PersonalityScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _errorMessage = ApiClient.toApiException(e).message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _notAvailable(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider sign-in isn\'t available in this build yet.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      extendBodyBehindAppBar: true,

      // ================================================================
      // APP BAR
      // ================================================================

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.white70,
        ),
      ),

      // ================================================================
      // BODY
      // ================================================================

      body: Stack(
        children: [
          // ============================================================
          // MAIN BACKGROUND
          // ============================================================

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF14101B),
                    Color(0xFF0A090D),
                    Color(0xFF070709),
                  ],
                  stops: [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // TOP AMBIENT GLOW
          // ============================================================

          Positioned(
            top: -180,
            left: -100,
            child: Container(
              width: 430,
              height: 430,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF9D6DCE).withOpacity(0.16),
                    const Color(0xFF6B4A91).withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [
                    0.0,
                    0.45,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // SECONDARY AMBIENT GLOW
          // ============================================================

          Positioned(
            top: 240,
            right: -140,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD1A7FF).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // CONTENT
          // ============================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

                    child: Column(
                      children: [
                        const SizedBox(height: 36),

                        // ==================================================
                        // VEYRA BRAND
                        // ==================================================

                        Column(
                          children: [
                            // ------------------------------------------------
                            // V MARK
                            // ------------------------------------------------

                            Container(
                              width: 52,
                              height: 52,

                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                border: Border.all(
                                  color: Colors.white.withOpacity(0.10),
                                  width: 1,
                                ),

                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.09),
                                    Colors.white.withOpacity(0.015),
                                  ],
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB77BEA)
                                        .withOpacity(0.10),
                                    blurRadius: 35,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),

                              child: const Center(
                                child: Text(
                                  'V',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            // ------------------------------------------------
                            // VEYRA TEXT
                            // ------------------------------------------------

                            const Text(
                              'VEYRA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 6,
                              ),
                            ),

                            const SizedBox(height: 9),

                            Text(
                              'A space that feels like yours.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.38),
                                fontSize: 12,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 70),

                        // ==================================================
                        // WELCOME HEADER
                        // ==================================================

                        Align(
                          alignment: Alignment.centerLeft,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ----------------------------------------------
                              // EYEBROW
                              // ----------------------------------------------

                              Text(
                                'WELCOME BACK',
                                style: TextStyle(
                                  color: const Color(0xFFC7A4E7)
                                      .withOpacity(0.90),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.8,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ----------------------------------------------
                              // TITLE
                              // ----------------------------------------------

                              const Text(
                                'Good to see you.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  height: 1.05,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -1.7,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ----------------------------------------------
                              // SUBTITLE
                              // ----------------------------------------------

                              Text(
                                'Continue where you left off.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.42),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // LOGIN CARD
                        // ==================================================

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),

                            color: Colors.white.withOpacity(0.035),

                            border: Border.all(
                              color: Colors.white.withOpacity(0.065),
                              width: 1,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              // ============================================
                              // EMAIL FIELD
                              // ============================================

                              Container(
                                height: 60,

                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.20),

                                  borderRadius:
                                      BorderRadius.circular(18),

                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.055),
                                  ),
                                ),

                                child: VeyraTextField(
                                  controller: _emailController,
                                  hint: 'Email address',
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  onChanged: (_) => setState(() => _errorMessage = null),
                                ),
                              ),

                              const SizedBox(height: 13),

                              // ============================================
                              // PASSWORD FIELD
                              // ============================================

                              Container(
                                height: 60,

                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.20),

                                  borderRadius:
                                      BorderRadius.circular(18),

                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.055),
                                  ),
                                ),

                                child: VeyraTextField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  obscureText: true,
                                  onChanged: (_) => setState(() => _errorMessage = null),
                                ),
                              ),

                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.danger.withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: AppColors.danger,
                                            fontSize: 12.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 7),

                              // ============================================
                              // FORGOT PASSWORD
                              // ============================================

                              Align(
                                alignment: Alignment.centerRight,

                                child: SecondaryButton(
                                  label: 'Forgot password?',
                                  onPressed: () {},
                                ),
                              ),

                              const SizedBox(height: 13),

                              // ============================================
                              // CONTINUE BUTTON
                              // ============================================

                              SizedBox(
                                width: double.infinity,
                                height: 58,

                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(18),

                                    gradient: _canContinue
                                        ? const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFD6B5F4),
                                              Color(0xFF9C6FC0),
                                            ],
                                          )
                                        : null,

                                    color: _canContinue
                                        ? null
                                        : Colors.white.withOpacity(0.07),

                                    boxShadow: _canContinue
                                        ? [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFB17AD6,
                                              ).withOpacity(0.18),

                                              blurRadius: 25,

                                              offset:
                                                  const Offset(0, 10),
                                            ),
                                          ]
                                        : null,
                                  ),

                                  child: PrimaryButton(
                                    label: _submitting
                                        ? 'Signing in…'
                                        : 'Continue',

                                    enabled: _canContinue,

                                    onPressed: _continue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // OR DIVIDER
                        // ==================================================

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),

                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.25),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // APPLE LOGIN
                        // ==================================================

                        _SocialButton(
                          icon: Icons.apple,
                          label: 'Continue with Apple',
                          onPressed: () => _notAvailable('Apple'),
                        ),

                        const SizedBox(height: 11),

                        // ==================================================
                        // GOOGLE LOGIN
                        // ==================================================

                        _SocialButton(
                          icon: Icons.g_mobiledata,
                          iconSize: 28,
                          label: 'Continue with Google',
                          onPressed: () => _notAvailable('Google'),
                        ),

                        const SizedBox(height: 32),

                        // ==================================================
                        // PRIVACY
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 12,
                              color:
                                  Colors.white.withOpacity(0.24),
                            ),

                            const SizedBox(width: 7),

                            Text(
                              'Your space is private.',
                              style: TextStyle(
                                color:
                                    Colors.white.withOpacity(0.27),
                                fontSize: 10.5,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// SOCIAL LOGIN BUTTON
// ======================================================================

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final double iconSize;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.iconSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,

      child: OutlinedButton(
        onPressed: onPressed,

        style: OutlinedButton.styleFrom(
          backgroundColor:
              Colors.white.withOpacity(0.025),

          foregroundColor: Colors.white,

          side: BorderSide(
            color: Colors.white.withOpacity(0.075),
            width: 1,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
        ),

        child: Stack(
          alignment: Alignment.center,

          children: [
            // ------------------------------------------------------------
            // ICON
            // ------------------------------------------------------------

            Align(
              alignment: Alignment.centerLeft,

              child: Icon(
                icon,
                size: iconSize,
                color: Colors.white.withOpacity(0.88),
              ),
            ),

            // ------------------------------------------------------------
            // LABEL
            // ------------------------------------------------------------

            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.82),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}