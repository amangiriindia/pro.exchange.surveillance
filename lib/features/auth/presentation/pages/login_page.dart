import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surveillance/core/widget/custom_input_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/auth_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widget/custom_button.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _backgroundImageError = false;
  bool _isRedirectingToMarketWatch = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    Widget formContent = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listener: _handleAuthStateChange,
              ),
            ],
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return _buildForm(context, state is AuthLoading);
              },
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: isDesktop
          ? Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: _backgroundImageError
                        ? _buildGradientBackground(context)
                        : _buildBackgroundWithImage(),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F172A), Color(0xFF0B1120)],
                      ),
                    ),
                    child: formContent,
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                Container(
                  decoration: _backgroundImageError
                      ? _buildGradientBackground(context)
                      : _buildBackgroundWithImage(),
                ),
                Container(color: Colors.black54),
                formContent,
              ],
            ),
    );
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
    if (_isRedirectingToMarketWatch || !mounted) {
      return;
    }

    _isRedirectingToMarketWatch = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed('/dashboard');
    });
  }

  void _resetPreloadFlags() {
    if (!mounted) {
      _isRedirectingToMarketWatch = false;
      return;
    }

    setState(() {
      _isRedirectingToMarketWatch = false;
    });
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: 440,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withOpacity(0.95), // dark modern card
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(context),
                const SizedBox(height: 32),
                Center(child: _buildTitleSection(context)),
                const SizedBox(height: 48),
                _buildUsernameField(context),
                const SizedBox(height: 24),
                _buildPasswordField(context),
                const SizedBox(height: 40),
                _buildLoginButton(context, isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundWithImage() {
    return BoxDecoration(
      image: DecorationImage(
        image: const AssetImage(AppImages.loginBg),
        fit: BoxFit.cover,
        onError: (_, __) {
          if (mounted) setState(() => _backgroundImageError = true);
        },
      ),
    );
  }

  BoxDecoration _buildGradientBackground(BuildContext context) {
    final isDark = AppColors.isDarkMode(context);
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [DarkThemeColors.backgroundColor, DarkThemeColors.cardBackground]
            : [
                AppColors.headerBgColor,
                AppColors.white,
                AppColors.headerBgColor,
              ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AppImages.appLogo,
                fit: BoxFit.contain,
                opacity: const AlwaysStoppedAnimation(1.0),
                errorBuilder: (_, __, ___) => _buildFallbackLogo(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Surveillance',
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context) {
    return const Icon(Icons.security, color: Colors.white, size: 32);
  }

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AuthConstants.usernameLabel,
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          hintText: 'Type here',
          controller: _usernameController,
          height: 52,
          width: double.infinity,
          fillColor: Colors.white.withOpacity(0.05),
          borderColor: Colors.white.withOpacity(0.1),
          textColor: Colors.white,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          validator: (value) =>
              value?.isEmpty ?? true ? AuthConstants.emptyUsernameError : null,
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AuthConstants.passwordLabel,
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          hintText: 'Type here',
          controller: _passwordController,
          height: 52,
          width: double.infinity,
          fillColor: Colors.white.withOpacity(0.05),
          borderColor: Colors.white.withOpacity(0.1),
          textColor: Colors.white,
          textInputAction: TextInputAction.done,
          obscureText: _obscurePassword,
          suffixIcon: _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          onSuffixIconPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          onFieldSubmitted: (_) => _handleLogin(),
          validator: (value) =>
              value?.isEmpty ?? true ? AuthConstants.emptyPasswordError : null,
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    return CustomButton(
      text: AuthConstants.loginButtonText,
      onPressed: _handleLogin,
      isLoading: isLoading,
      width: double.infinity,
      height: 52,
      backgroundColor: AppColors.secondaryColor(context),
      borderColor: AppColors.secondaryColor(context),
      textColor: Colors.white,
    );
  }
}
