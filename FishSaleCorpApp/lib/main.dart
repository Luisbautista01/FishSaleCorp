// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/carrito/carrito_page.dart';
import 'package:gestor_tareas_app/carrito/carrito_provider.dart';
import 'package:gestor_tareas_app/catalog_order/catalogo_admin_pescador.dart';
import 'package:gestor_tareas_app/screen/forgot_password_page.dart';
import 'package:gestor_tareas_app/pay_wompi/dashboard_admin_page.dart';
import 'package:gestor_tareas_app/pay_wompi/mis_pagos_page.dart';
import 'package:gestor_tareas_app/pedidos/historial_pedidos_page.dart';
import 'package:gestor_tareas_app/admin/admin_users_page.dart';
import 'package:gestor_tareas_app/screen/login_page.dart';
import 'package:gestor_tareas_app/screen/register_page.dart';
import 'package:gestor_tareas_app/screen/welcome_page.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/admin/usuarios_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_tareas_app/services/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestor_tareas_app/l10n/app_localizations.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode;
  ThemeProvider(this._isDarkMode);

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modo_oscuro', value);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('modo_oscuro') ?? false;

  final authService = AuthService();

  final savedLocale = await LocaleProvider.loadSavedLocale();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuariosProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(darkMode)),
        ChangeNotifierProvider(create: (_) => LocaleProvider(savedLocale)),
        Provider<AuthService>.value(value: authService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FishSaleCorp App',
      locale: localeProvider.locale,
      supportedLocales: const [Locale('es'), Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.cyanAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Poppins',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const WelcomePage(),

      routes: {
        '/login': (context) => LoginPage(authService: authService),
        '/register': (context) => RegisterPage(authService: authService),
        '/forgot': (context) => ForgotPasswordPage(authService: authService),
        '/pedidos': (_) =>
            HistorialPedidosPage(authService: authService, esAdmin: true),
        '/entregados': (_) =>
            MisPagosPage(authService: authService, rol: 'ADMIN'),
        '/ganancias': (_) => DashboardAdminPage(authService: authService),
        '/usuarios': (_) => AdminUsersPage(),
        '/carrito': (_) => CarritoPage(),
        '/catalogo': (_) => CatalogoAdminPescador(authService: authService),
      },
    );
  }
}
