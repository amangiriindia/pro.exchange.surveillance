import re

with open('lib/features/auth/presentation/pages/login_page.dart', 'r') as f:
    content = f.read()

# 1. State changes
state_start = 'class _LoginPageState extends State<LoginPage> {'
state_replace = '''class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;'''
content = content.replace(state_start, state_replace)

# 2. Add initState
init_state = '''
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
'''
content = content.replace('''  @override
  void dispose() {''', init_state + '''
  @override
  void dispose() {
    _animationController.dispose();''')

# 3. scaffold background changes
bg_old = '''                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: formContent,
                  ),
                ),'''
bg_new = '''                Expanded(
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
                ),'''
content = content.replace(bg_old, bg_new)

# 4. _buildForm
form_old = '''  Widget _buildForm(BuildContext context, bool isLoading) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLogo(context),
            const SizedBox(height: AppDimensions.marginXL),
            Center(child: _buildTitleSection(context)),
            const SizedBox(height: AppDimensions.paddingL * 2),
            _buildUsernameField(context),
            const SizedBox(height: AppDimensions.paddingM),
            _buildPasswordField(context),
            const SizedBox(height: AppDimensions.paddingXL),
            _buildLoginButton(context, isLoading),
          ],
        ),
      ),
    );
  }'''
form_new = '''  Widget _buildForm(BuildContext context, bool isLoading) {
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
  }'''
content = content.replace(form_old, form_new)

# 5. _buildLogo
logo_old = '''          Text(
            'Surveillance',
            style: GoogleFonts.openSans(
              color: AppColors.primaryColor(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),'''
logo_new = '''          Text(
            'Surveillance',
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),'''
content = content.replace(logo_old, logo_new)

# 6._buildTitleSection
title_old = '''        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1.0,
            letterSpacing: -0.5,
            color: AppColors.primaryColor(context),
          ),
        ),'''
title_new = '''        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.5,
            color: Colors.white,
          ),
        ),'''
content = content.replace(title_old, title_new)

# 7. Username Field
u_old = '''  Widget _buildUsernameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AuthConstants.usernameLabel,
          style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor(context),
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          hintText: 'Type here',
          controller: _usernameController,
          onFieldSubmitted: (_) => _handleLogin(),
          validator: (value) =>
              value?.isEmpty ?? true ? AuthConstants.emptyUsernameError : null,
        ),
      ],
    );
  }'''
u_new = '''  Widget _buildUsernameField(BuildContext context) {
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
          onFieldSubmitted: (_) => _handleLogin(),
          validator: (value) =>
              value?.isEmpty ?? true ? AuthConstants.emptyUsernameError : null,
        ),
      ],
    );
  }'''
content = content.replace(u_old, u_new)

# 8. Password Field
p_old = '''  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AuthConstants.passwordLabel,
          style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor(context),
          ),
        ),
        const SizedBox(height: 8),
        CustomInputField(
          hintText: 'Type here',
          controller: _passwordController,
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
  }'''
p_new = '''  Widget _buildPasswordField(BuildContext context) {
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
  }'''
content = content.replace(p_old, p_new)

# 9. Login button
btn_old = '''  Widget _buildLoginButton(BuildContext context, bool isLoading) {
    return CustomButton(
      text: AuthConstants.loginButtonText,
      onPressed: _handleLogin,
      isLoading: isLoading,
      backgroundColor: AppColors.primaryColor(context),
      borderColor: AppColors.primaryColor(context),
    );
  }'''
btn_new = '''  Widget _buildLoginButton(BuildContext context, bool isLoading) {
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
  }'''
content = content.replace(btn_old, btn_new)

with open('lib/features/auth/presentation/pages/login_page.dart', 'w') as f:
    f.write(content)
