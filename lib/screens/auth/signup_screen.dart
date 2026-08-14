import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/theme_controller.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../../state/onboarding_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/veyra_text_field.dart';
import '../onboarding/personality_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;

  bool get _canContinue =>
      _emailController.text.trim().contains('@') &&
      _passwordController.text.length >= 8 &&
      !_submitting;

  Future<void> _continue() async {
    setState(() => _submitting = true);

    try {
      final appState = context.read<AppState>();

      await appState.authApi.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      context
          .read<OnboardingController>()
          .setUserEmail(_emailController.text.trim());

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PersonalityScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final exception = ApiClient.toApiException(e);

      if (exception.code == 'EMAIL_TAKEN') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You already have an account with this email — logging you in instead.',
            ),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              initialEmail: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.message),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
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
          // BACKGROUND
          // ============================================================

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF17111E),
                    Color(0xFF0B090E),
                    Color(0xFF070709),
                  ],
                  stops: [
                    0.0,
                    0.48,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // LARGE AMBIENT GLOW
          // ============================================================

          Positioned(
            top: -190,
            right: -130,
            child: Container(
              width: 440,
              height: 440,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFB77BDD).withOpacity(0.15),
                    const Color(0xFF754B92).withOpacity(0.045),
                    Colors.transparent,
                  ],
                  stops: const [
                    0.0,
                    0.48,
                    1.0,
                  ],
                ),
              ),
            ),
          ),

          // ============================================================
          // SECONDARY GLOW
          // ============================================================

          Positioned(
            bottom: -180,
            left: -130,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD3A5F5).withOpacity(0.07),
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
                        const SizedBox(height: 32),

                        // ==================================================
                        // VEYRA BRAND
                        // ==================================================

                        Column(
                          children: [
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
                                    Colors.white.withOpacity(0.085),
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

                        const SizedBox(height: 62),

                        // ==================================================
                        // INTRODUCTION
                        // ==================================================

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CREATE YOUR SPACE',
                                style: TextStyle(
                                  color: const Color(0xFFC8A5E8)
                                      .withOpacity(0.90),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.8,
                                ),
                              ),

                              const SizedBox(height: 13),

                              const Text(
                                "Let's begin.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  height: 1.05,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -1.7,
                                ),
                              ),

                              const SizedBox(height: 14),

                              Text(
                                'Create your account and start building '
                                'your VEYRA.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.42),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ==================================================
                        // ACCOUNT CARD
                        // ==================================================

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.035),
                            borderRadius: BorderRadius.circular(28),
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
                              // ==========================================
                              // EMAIL
                              // ==========================================

                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.20),
                                  borderRadius: BorderRadius.circular(18),
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
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),

                              const SizedBox(height: 13),

                              // ==========================================
                              // PASSWORD
                              // ==========================================

                              Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.20),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.055),
                                  ),
                                ),
                                child: VeyraTextField(
                                  controller: _passwordController,
                                  hint: 'Create a password',
                                  obscureText: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // ==========================================
                              // PASSWORD REQUIREMENT
                              // ==========================================

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _passwordController
                                                    .text.length >=
                                                8
                                            ? const Color(0xFFBFA0DC)
                                            : Colors.white
                                                .withOpacity(0.18),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      'At least 8 characters',
                                      style: TextStyle(
                                        color: _passwordController
                                                    .text.length >=
                                                8
                                            ? Colors.white
                                                .withOpacity(0.55)
                                            : Colors.white
                                                .withOpacity(0.28),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // ==========================================
                              // CONTINUE
                              // ==========================================

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
                                        ? 'Creating account…'
                                        : 'Continue',
                                    enabled: _canContinue,
                                    onPressed: _continue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // NEXT STEP MESSAGE
                        // ==================================================

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.025),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.045),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFC19AE0)
                                      .withOpacity(0.10),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 14,
                                  color: Color(0xFFD0B1E9),
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Text(
                                  'Next, you’ll create your companion '
                                  'and make VEYRA yours.',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withOpacity(0.36),
                                    fontSize: 11.5,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

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
                              color: Colors.white.withOpacity(0.24),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Your space is private.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.27),
                                fontSize: 10.5,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
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