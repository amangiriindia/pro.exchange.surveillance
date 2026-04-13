import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surveillance/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'core/routes/navigator_key.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:window_manager/window_manager.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'injection_container.dart' as di;
import 'core/observers/dialog_navigator_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = kIsWeb || Platform.isMacOS;

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    final screenSize = await windowManager.getSize();
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final initialWidth = (screenWidth * 0.7).clamp(1280.0, 1920.0);
    final initialHeight = (screenHeight * 0.7).clamp(720.0, 1080.0);
    final WindowOptions windowOptions = WindowOptions(
      size: Size(initialWidth, initialHeight),
      minimumSize: const Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'BAZAAR Pro',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final windowWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : 1920.0;
        final windowHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : 1080.0;
        return ScreenUtilInit(
          designSize: Size(windowWidth, windowHeight),
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => di.sl<AuthBloc>()),
              ],
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthAuthenticated) {
                    return;
                  }

                  if (state is AuthUnauthenticated) {
                  }
                },
                  child: MaterialApp(
                    navigatorKey: globalNavigatorKey,
                    title: 'Bazaar Pro Feeder - Real-Time Market Insights',
                    debugShowCheckedModeBanner: false,
                    themeMode: ThemeMode.system,
                    navigatorObservers: [DialogNavigatorObserver()],
                    initialRoute: AppRoutes.login,
                    routes: AppRoutes.getRoutes(),
                  ),
              ),
            );
          },
        );
      },
    );
  }
}
