import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/auth_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Live candlestick that scrolls left → right across the screen
// ─────────────────────────────────────────────────────────────────────────────
class _LiveCandle {
  /// Normalised x position (0..1). Candle moves from -0.12 → 1.12.
  double x;

  /// Fixed normalised y (row centre, 0..1). Set once on spawn.
  final double yNorm;

  /// Horizontal scroll speed in normalised units per second.
  final double speed;

  final double widthPx;
  final double bodyPx;
  final double wickTopPx;
  final double wickBottomPx;
  bool isBull;
  final double baseOpacity;

  _LiveCandle({
    required this.x,
    required this.yNorm,
    required this.speed,
    required this.widthPx,
    required this.bodyPx,
    required this.wickTopPx,
    required this.wickBottomPx,
    required this.isBull,
    required this.baseOpacity,
  });

  /// Opacity with smooth fade-in (left edge) and fade-out (right edge).
  double get opacity {
    const fadeZone = 0.12;
    if (x < fadeZone) return (x / fadeZone).clamp(0.0, 1.0) * baseOpacity;
    if (x > 1.0 - fadeZone) {
      return ((1.0 - x) / fadeZone).clamp(0.0, 1.0) * baseOpacity;
    }
    return baseOpacity;
  }

  /// Reset this candle to the left edge with new random appearance.
  void respawn(math.Random rng) {
    x = -0.06 - rng.nextDouble() * 0.08; // stagger spawn timing
    isBull = rng.nextBool();
  }

  static _LiveCandle spawn(math.Random rng, double startX, double rowY) =>
      _LiveCandle(
        x: startX,
        yNorm: rowY,
        speed: 0.028 + rng.nextDouble() * 0.014, // ~35-55 s to cross screen
        widthPx: 7.0 + rng.nextDouble() * 5.0,
        bodyPx: 10.0 + rng.nextDouble() * 20.0,
        wickTopPx: 4.0 + rng.nextDouble() * 14.0,
        wickBottomPx: 4.0 + rng.nextDouble() * 14.0,
        isBull: rng.nextBool(),
        baseOpacity: 0.22 + rng.nextDouble() * 0.18,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom painter: live-chart scrolling candles + chart line + grid + orbs
// ─────────────────────────────────────────────────────────────────────────────
class _TradingBackgroundPainter extends CustomPainter {
  final List<_LiveCandle> candles;
  final double elapsedSeconds; // monotonically increasing

  _TradingBackgroundPainter({
    required this.candles,
    required this.elapsedSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawChartLine(canvas, size);
    _drawCandles(canvas, size);
    _drawGlowOrbs(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.3)
      ..strokeWidth = 0.5;
    const cols = 14;
    const rows = 9;
    for (int i = 0; i <= cols; i++) {
      final x = size.width * i / cols;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 0; i <= rows; i++) {
      final y = size.height * i / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawChartLine(Canvas canvas, Size size) {
    final path = Path();
    const points = 100;
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final x = size.width * t;
      // Phase shifts continuously with elapsed time → no reset glitch
      final phase = elapsedSeconds * 0.6;
      final base = size.height * 0.58;
      final wave1 = math.sin(phase + t * 5.5) * size.height * 0.065;
      final wave2 = math.sin(phase * 1.4 + t * 12.0) * size.height * 0.028;
      final wave3 = math.sin(phase * 0.7 + t * 3.0) * size.height * 0.04;
      final y = base + wave1 + wave2 + wave3;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }

    // Glow blur
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00D4FF).withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Main line
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF00D4FF).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.07),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  void _drawCandles(Canvas canvas, Size size) {
    for (final c in candles) {
      final op = c.opacity.clamp(0.0, 1.0);
      if (op <= 0.01) continue;

      final cx = c.x * size.width;
      final cy = c.yNorm * size.height;

      final bullColor = Color.fromRGBO(0, 214, 110, op);
      final bearColor = Color.fromRGBO(255, 75, 75, op);
      final color = c.isBull ? bullColor : bearColor;

      // Wick
      canvas.drawLine(
        Offset(cx, cy - c.bodyPx / 2 - c.wickTopPx),
        Offset(cx, cy + c.bodyPx / 2 + c.wickBottomPx),
        Paint()
          ..color = color
          ..strokeWidth = 1.2,
      );

      // Body
      final bodyRect = Rect.fromCenter(
        center: Offset(cx, cy),
        width: c.widthPx,
        height: c.bodyPx,
      );
      // Hollow (bear) vs solid (bull) — like a real terminal
      if (c.isBull) {
        canvas.drawRect(bodyRect, Paint()..color = color);
      } else {
        canvas.drawRect(
          bodyRect,
          Paint()
            ..color = Color.fromRGBO(255, 75, 75, op * 0.25)
            ..style = PaintingStyle.fill,
        );
        canvas.drawRect(
          bodyRect,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _drawGlowOrbs(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * 0.12, size.height * 0.22),
      Offset(size.width * 0.88, size.height * 0.72),
      Offset(size.width * 0.5, size.height * 0.08),
    ];
    final colors = [
      const Color(0xFF0066FF),
      const Color(0xFF00D4FF),
      const Color(0xFF7C3AED),
    ];
    for (int i = 0; i < positions.length; i++) {
      final pulse = (math.sin(elapsedSeconds * 0.8 + i * 2.1) + 1) / 2;
      final radius = 90.0 + pulse * 45;
      canvas.drawCircle(
        positions[i],
        radius,
        Paint()
          ..color = colors[i].withOpacity(0.055 + pulse * 0.035)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70),
      );
    }
  }

  @override
  bool shouldRepaint(_TradingBackgroundPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated gradient border wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedBorderCard extends StatelessWidget {
  final Widget child;
  final double borderProgress; // 0..1

  const _AnimatedBorderCard({
    required this.child,
    required this.borderProgress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BorderPainter(progress: borderProgress),
      child: child,
    );
  }
}

class _BorderPainter extends CustomPainter {
  final double progress;
  _BorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(24),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(progress * math.pi * 2),
        colors: const [
          Color(0xFF0066FF),
          Color(0xFF00D4FF),
          Color(0xFF7C3AED),
          Color(0xFF0066FF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(_BorderPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// LoginPage
// ─────────────────────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Entry animation
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Background animation
  late final AnimationController _bgCtrl;

  // Border rotation
  late final AnimationController _borderCtrl;

  // Button shimmer
  late final AnimationController _shimmerCtrl;
  late final Animation<double> _shimmerAnim;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isRedirectingToMarketWatch = false;

  late final List<_LiveCandle> _candles;
  final _rng = math.Random();
  double _elapsedSeconds = 0.0;
  int? _lastTickMs;

  @override
  void initState() {
    super.initState();

    // Spawn candles in 6 rows, 5 per row, evenly spaced along x
    // Rows occupy the middle band of the screen (15%..85% vertically)
    const rowCount = 6;
    const candlesPerRow = 5;
    const rowSpacing = 0.14; // normalised
    const rowStart = 0.15;
    _candles = [
      for (int row = 0; row < rowCount; row++)
        for (int col = 0; col < candlesPerRow; col++)
          _LiveCandle.spawn(
            _rng,
            col / candlesPerRow + _rng.nextDouble() * 0.05, // stagger x
            rowStart + row * rowSpacing,
          ),
    ];

    // Entry fade+slide
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();

    // Continuous background (candles + chart + orbs)
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tickBackground);
    _bgCtrl.repeat();

    // Rotating border
    _borderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Shimmer on the button
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));
  }

  // Proper delta-time tick: accumulates elapsed seconds, moves candles right.
  void _tickBackground() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final dtSec = _lastTickMs != null
        ? (nowMs - _lastTickMs!).clamp(0, 50) / 1000.0
        : 1 / 60.0;
    _lastTickMs = nowMs;
    _elapsedSeconds += dtSec;

    for (final c in _candles) {
      c.x += c.speed * dtSec;
      if (c.x > 1.12) c.respawn(_rng);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    _borderCtrl.dispose();
    _shimmerCtrl.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  void _handleAuthStateChange(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _navigateToMarketWatch();
      return;
    }
    if (state is AuthError) {
      _resetPreloadFlags();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
      return;
    }
    if (state is AuthUnauthenticated && state.message != null) {
      _resetPreloadFlags();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message!)));
    }
  }

  void _navigateToMarketWatch() {
    if (_isRedirectingToMarketWatch || !mounted) return;
    _isRedirectingToMarketWatch = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    });
  }

  void _resetPreloadFlags() {
    if (!mounted) {
      _isRedirectingToMarketWatch = false;
      return;
    }
    setState(() => _isRedirectingToMarketWatch = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1A),
      body: Stack(
        children: [
          // ── Animated trading background ──────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                painter: _TradingBackgroundPainter(
                  candles: _candles,
                  elapsedSeconds: _elapsedSeconds,
                ),
              ),
            ),
          ),

          // ── Dark overlay gradient ────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.6, 0),
                  radius: 1.4,
                  colors: [Color(0x00060D1A), Color(0xCC060D1A)],
                ),
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: MultiBlocListener(
                  listeners: [
                    BlocListener<AuthBloc, AuthState>(
                      listener: _handleAuthStateChange,
                    ),
                  ],
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) =>
                        _buildCard(context, state is AuthLoading, isDesktop),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isLoading, bool isDesktop) {
    final cardWidth = isDesktop ? 460.0 : double.infinity;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: AnimatedBuilder(
          animation: _borderCtrl,
          builder: (_, child) => _AnimatedBorderCard(
            borderProgress: _borderCtrl.value,
            child: child!,
          ),
          child: Container(
            width: cardWidth,
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 44),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066FF).withOpacity(0.12),
                  blurRadius: 60,
                  spreadRadius: -5,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 28),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const SizedBox(height: 36),
                  _buildLabel(AuthConstants.usernameLabel),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _usernameController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    action: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    validator: (v) => v?.isEmpty ?? true
                        ? AuthConstants.emptyUsernameError
                        : null,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel(AuthConstants.passwordLabel),
                  const SizedBox(height: 8),
                  _buildPasswordInputField(context),
                  const SizedBox(height: 36),
                  _buildLoginButton(isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF0066FF), Color(0xFF00D4FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              AppImages.appLogo,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.security, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFF00D4FF)],
          ).createShader(bounds),
          child: Text(
            'Surveillance',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      'Welcome back',
      style: GoogleFonts.rajdhani(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Sign in to your trading surveillance dashboard',
      style: GoogleFonts.openSans(
        fontSize: 13,
        color: const Color(0xFF8B96A7),
        height: 1.4,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF60A5FA),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffixWidget,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: GoogleFonts.openSans(
        fontSize: 14,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.openSans(
          fontSize: 13,
          color: const Color(0xFF4A5568),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF4A6FA5), size: 18),
        suffixIcon: suffixWidget,
        filled: true,
        fillColor: const Color(0xFF0F1F35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
        errorStyle: GoogleFonts.openSans(
          fontSize: 11,
          color: const Color(0xFFFF5252),
        ),
      ),
    );
  }

  Widget _buildPasswordInputField(BuildContext context) {
    return _buildInputField(
      controller: _passwordController,
      hint: 'Enter your password',
      icon: Icons.lock_outline,
      obscure: _obscurePassword,
      action: TextInputAction.done,
      onSubmitted: (_) => _handleLogin(),
      validator: (v) =>
          v?.isEmpty ?? true ? AuthConstants.emptyPasswordError : null,
      suffixWidget: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: const Color(0xFF4A6FA5),
          size: 18,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, __) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: isLoading
              ? Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0044CC), Color(0xFF0066FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Signing in...',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: _handleLogin,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0044CC), Color(0xFF0088FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Shimmer sweep
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(
                                _shimmerAnim.value *
                                    460, // sweep across card width
                                0,
                              ),
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.0),
                                      Colors.white.withOpacity(0.15),
                                      Colors.white.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AuthConstants.loginButtonText,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
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
      },
    );
  }
}
