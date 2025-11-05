// ignore_for_file: use_build_context_synchronously, unnecessary_brace_in_string_interps, annotate_overrides, avoid_print, unnecessary_to_list_in_spreads

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestor_tareas_app/asistente_personal/fishbot_overlay.dart';
import 'package:gestor_tareas_app/carrito/carrito_page.dart';
import 'package:gestor_tareas_app/catalog_order/catalogo_admin_pescador.dart';
import 'package:gestor_tareas_app/catalog_order/catalogo_cliente.dart';
import 'package:gestor_tareas_app/pay_wompi/dashboard_admin_page.dart';
import 'package:gestor_tareas_app/pay_wompi/mis_pagos_page.dart';
import 'package:gestor_tareas_app/pedidos/historial_pedidos_page.dart';
import 'package:gestor_tareas_app/pedidos/pedidos_pescador.dart';
import 'package:gestor_tareas_app/report/admin_problemas_page.dart';
import 'package:gestor_tareas_app/report/mis_reportes_page.dart';
import 'package:gestor_tareas_app/report/report_problem_page.dart';
import 'package:gestor_tareas_app/admin/admin_users_page.dart';
import 'package:gestor_tareas_app/admin/config_user_page.dart';
import 'package:gestor_tareas_app/pay_wompi/ventas_pescador_page.dart';
import 'package:gestor_tareas_app/home/home_main_screen.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/eventos_service.dart';
import 'package:gestor_tareas_app/admin/user.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:gestor_tareas_app/services/guide_service.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final User user;

  const HomePage({required this.authService, required this.user, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Timer _clockTimer;
  String _currentDateTime = "";
  Map<DateTime, List<String>> _eventos = {};

  final EventosService _eventosService = EventosService(
    baseUrl: ApiConfig.baseUrl,
  );

  final Map<String, List<Widget>> roleScreens = {};
  final Map<String, List<BottomNavigationBarItem>> roleNavItems = {};

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _catalogKey = GlobalKey();
  final GlobalKey _pagosKey = GlobalKey();
  final GlobalKey _carritoKey = GlobalKey();
  final GlobalKey _configKey = GlobalKey();
  final GlobalKey _userKey = GlobalKey();
  final GlobalKey _pedidosKey = GlobalKey();
  final GlobalKey _ventasKey = GlobalKey();
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _reportesKey = GlobalKey();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initRoleScreens();
    _updateDateTime();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDateTime(),
    );
    _cargarEventos();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId =
          widget.user.clienteId ??
          widget.user.pescadorId ??
          widget.user.administradorId ??
          0;
      await GuideService.showOnFirstSignIn(
        context: context,
        userId: userId,
        keys: [
          _homeKey,
          _catalogKey,
          _pagosKey,
          _carritoKey,
          _configKey,
          _userKey,
          _pedidosKey,
          _ventasKey,
          _dashboardKey,
          _reportesKey,
        ],
      );

      _mostrarEventosDelDia(DateTime.now());
      FishBotOverlay.toggle(context, widget.user.nombre, widget.user.rol);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    FishBotOverlay.removeOverlay();
    super.dispose();
  }

  Future<void> _cargarEventos() async {
    try {
      final token = await widget.authService.getToken();
      if (token == null) throw Exception("No se encontró el token");

      final eventos = await _eventosService.obtenerEventos(
        rol: widget.user.rol,
        clienteId: widget.user.clienteId,
        pescadorId: widget.user.pescadorId ?? 0,
        token: token,
      );

      if (!mounted) return;
      setState(() => _eventos = eventos);

      _mostrarEventosDelDia(DateTime.now());
    } catch (e) {
      print("Error cargando eventos: $e");
    }
  }

  void _mostrarEventosDelDia(DateTime selectedDay) {
    final eventosDia =
        _eventos[DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        )] ??
        [];

    if (widget.user.rol.toUpperCase() == "CLIENTE") {
      eventosDia.retainWhere((e) => e.contains("💰") || e.contains("📦"));
    }

    if (eventosDia.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Eventos del ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              ...eventosDia.map((evento) {
                final isPago = evento.contains("💰");
                final isPedido = evento.contains("📦");

                return ListTile(
                  leading: Icon(
                    isPago
                        ? Icons.payment
                        : isPedido
                        ? Icons.shopping_cart
                        : Icons.event,
                    color: isPago
                        ? Colors.green
                        : isPedido
                        ? Colors.blueAccent
                        : Colors.grey,
                  ),
                  title: Text(evento),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);

                    if (isPago) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MisPagosPage(
                            authService: widget.authService,
                            rol: widget.user.rol.toUpperCase(),
                            clienteId: widget.user.clienteId,
                          ),
                        ),
                      );
                    } else if (isPedido) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistorialPedidosPage(
                            authService: widget.authService,
                            esAdmin: false,
                            clienteId: widget.user.clienteId,
                            pescadorId: widget.user.pescadorId,
                          ),
                        ),
                      );
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _updateDateTime() {
    if (!mounted) return;
    final now = DateTime.now();
    final dias = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado",
      "Domingo",
    ];
    final diaNombre = dias[now.weekday - 1];
    setState(() {
      _currentDateTime =
          "$diaNombre - ${DateFormat("dd/MM/yyyy \nHH:mm:ss").format(now)}";
    });
  }

  void _initRoleScreens() {
    final rol = widget.user.rol.toUpperCase();

    roleScreens["CLIENTE"] = [
      HomeMainScreen(
        user: widget.user,
        rol: rol,
        authService: widget.authService,
      ),
      CatalogoCliente(authService: widget.authService),
      const CarritoPage(),
      MisPagosPage(
        authService: widget.authService,
        rol: rol,
        clienteId: widget.user.clienteId,
      ),
      HistorialPedidosPage(
        authService: widget.authService,
        clienteId: widget.user.clienteId,
        esAdmin: false,
      ),
      MisReportesPage(authService: widget.authService),
    ];
    roleNavItems["CLIENTE"] = [
      BottomNavigationBarItem(
        icon: Showcase(
          key: _homeKey,
          description:
              "🏠 Aquí puedes consultar tus eventos, noticias y recordatorios importantes.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.home),
        ),
        label: "Inicio",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _catalogKey,
          description:
              "🛍️ Explora el catálogo completo de productos disponibles para ti.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.storefront_outlined),
        ),
        label: "Catálogo",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _carritoKey,
          description: "Aquí podrás ver los pedidos de tu carrito",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.shopping_cart),
        ),
        label: "Carrito",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _configKey,
          description: "En esta sección puedes ver tus pagos",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.payment),
        ),
        label: "Mis Pagos",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _pedidosKey,
          description: "📦 Revisa tus pedidos realizados",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.receipt_long),
        ),
        label: "Mis Pedidos",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _reportesKey,
          description: "Revisa el estado de tus problemas",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.report_problem_outlined),
        ),
        label: "Mis reportes",
      ),
    ];

    roleScreens["ADMIN"] = [
      HomeMainScreen(
        user: widget.user,
        rol: rol,
        authService: widget.authService,
      ),
      CatalogoAdminPescador(authService: widget.authService),
      HistorialPedidosPage(
        authService: widget.authService,
        esAdmin: true,
        clienteId: widget.user.clienteId,
        pescadorId: widget.user.pescadorId,
      ),
      const AdminUsersPage(),
      DashboardAdminPage(authService: widget.authService),
    ];
    roleNavItems["ADMIN"] = [
      BottomNavigationBarItem(
        icon: Showcase(
          key: _homeKey,
          description:
              "🏠 Panel principal con tus novedades y recordatorios del sistema.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.home),
        ),
        label: "Inicio",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _catalogKey,
          description:
              "🛍️ Aquí puedes administrar los productos disponibles en la plataforma.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.store_outlined),
        ),
        label: "Catálogo",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _pedidosKey,
          description:
              "📦 Aquí puedes ver y gestionar los pedidos realizados por los clientes.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.receipt_long),
        ),
        label: "Pedidos",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _userKey,
          description:
              "👥 Administra los usuarios, cambia roles y revisa su actividad.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const FaIcon(FontAwesomeIcons.userGear),
        ),
        label: "Usuarios",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _dashboardKey,
          description:
              "📈 Visualiza estadísticas y métricas clave del sistema en tiempo real.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.dashboard),
        ),
        label: "Dashboard",
      ),
    ];

    roleScreens["PESCADOR"] = [
      HomeMainScreen(
        user: widget.user,
        rol: rol,
        authService: widget.authService,
      ),
      CatalogoAdminPescador(authService: widget.authService),
      PedidosPescador(authService: widget.authService),
      VentasPescadorPage(
        authService: widget.authService,
        pescadorId: widget.user.pescadorId,
        pescadorNombre: widget.user.nombre,
      ),
    ];
    roleNavItems["PESCADOR"] = [
      BottomNavigationBarItem(
        icon: Showcase(
          key: _homeKey,
          description:
              "🏠 Panel principal donde podrás ver tus notificaciones y recordatorios.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.home),
        ),
        label: "Inicio",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _catalogKey,
          description:
              "🐟 Administra los productos y artículos disponibles en tu catálogo.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const FaIcon(FontAwesomeIcons.fish),
        ),
        label: "Productos",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _pedidosKey,
          description: "📦 Revisa los pedidos realizados por tus clientes.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.receipt_long),
        ),
        label: "Pedidos",
      ),
      BottomNavigationBarItem(
        icon: Showcase(
          key: _ventasKey,
          description:
              "💰 Aquí podrás consultar tus ventas y ganancias totales.",
          targetShapeBorder: const CircleBorder(),
          tooltipBackgroundColor: AppColors.primaryBlue,
          descTextStyle: const TextStyle(color: Colors.white),
          child: const Icon(Icons.attach_money),
        ),
        label: "Mis Ventas",
      ),
    ];
  }

  void _logout() async {
    await widget.authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.user.nombre;
    final rol = widget.user.rol.toUpperCase();
    final screens =
        roleScreens[rol] ?? [const Center(child: Text("Rol no reconocido"))];
    final navItems =
        roleNavItems[rol] ??
        [
          const BottomNavigationBarItem(
            icon: Icon(Icons.error),
            label: "Error",
          ),
        ];

    return Scaffold(
      body: ShowCaseWidget(
        builder: (context) => Row(
          children: [
            Flexible(
              child: Scaffold(
                backgroundColor: AppColors.lightBlue,
                drawer: _buildDrawer(nombre, rol),
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/logo.png',
                              height: 45,
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "FishSaleCorp",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "Ventas de peces en linea",
                                  style: TextStyle(
                                    color: Color.fromARGB(221, 104, 102, 102),
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.end,
                              spacing: 12,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _currentDateTime,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    return GestureDetector(
                                      onTapDown: (details) {
                                        _openProfileDrawer(
                                          context,
                                          details.globalPosition,
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          nombre.isNotEmpty
                                              ? nombre[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                body: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.lightBlue, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: screens[_currentIndex],
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                    if (rol == "CLIENTE")
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FloatingActionButton(
                            backgroundColor: AppColors.primaryBlue,
                            tooltip: "Acciones rápidas",
                            child: const Icon(Icons.flash_on),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                builder: (_) => Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Wrap(
                                    spacing: 20,
                                    runSpacing: 12,
                                    children: [
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Carrito",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const CarritoPage(),
                                          ),
                                        ),
                                      ),
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.payment,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Mis Pagos",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.orange,
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MisPagosPage(
                                              authService: widget.authService,
                                              rol: rol,
                                              clienteId: widget.user.clienteId,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.report_problem,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Reportar Problema",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReportProblemPage(
                                              authService: widget.authService,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ActionChip(
                                        avatar: const Icon(
                                          Icons.report,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "Mis reportes",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MisReportesPage(
                                              authService: widget.authService,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),

                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.white,
                  selectedItemColor: AppColors.primaryBlue,
                  unselectedItemColor: AppColors.greyText,
                  onTap: (index) => setState(() => _currentIndex = index),
                  items: navItems,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProfileDrawer(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      // <- define tipo String aquí
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        // <- define tipo String aquí
        PopupMenuItem<String>(
          value: "configuracion",
          child: Row(
            children: const [
              Icon(Icons.settings),
              SizedBox(width: 10),
              Text("Configuración"),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "acerca",
          child: Row(
            children: const [
              Icon(Icons.info_outline),
              SizedBox(width: 10),
              Text("Acerca de"),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: "logout",
          child: Row(
            children: const [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text("Cerrar sesión"),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == "configuracion") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfigUserPage(
              nombre: widget.user.nombre,
              rol: widget.user.rol,
            ),
          ),
        );
      } else if (value == "acerca") {
        showAboutDialog(
          context: context,
          applicationName: "FishSaleCorp",
          applicationVersion: "1.0.0",
          applicationIcon: FaIcon(
            FontAwesomeIcons.fish,
            size: 40,
            color: AppColors.primaryBlue,
          ),
          children: const [
            Text("Aplicación para gestión de ventas de peces en línea."),
          ],
        );
      } else if (value == "logout") {
        _logout();
      }
    });
  }

  Drawer _buildDrawer(String nombre, String rol) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: AppColors.primaryBlue,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primaryBlue,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            rol,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TableCalendar(
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _mostrarEventosOverlay(selectedDay);
                        },
                        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2030),
                        calendarFormat: CalendarFormat.month,
                        eventLoader: (day) {
                          final eventos =
                              _eventos[DateTime(
                                day.year,
                                day.month,
                                day.day,
                              )] ??
                              [];
                          if (rol.toUpperCase() == "CLIENTE") {
                            return eventos
                                .where(
                                  (e) => e.contains("💰") || e.contains("📦"),
                                )
                                .toList();
                          }
                          return eventos;
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          markersMaxCount: 3,
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      const Text(
                        "Eventos del día",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Builder(
                        builder: (_) {
                          final eventosDelDia =
                              _eventos[DateTime(
                                _selectedDay.year,
                                _selectedDay.month,
                                _selectedDay.day,
                              )] ??
                              [];

                          if (eventosDelDia.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "No hay eventos para este día",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return Column(
                            children: eventosDelDia.map((evento) {
                              final isPago = evento.contains("💰");
                              final isPedido = evento.contains("📦");

                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    backgroundColor: isPago
                                        ? Colors.green.shade100
                                        : isPedido
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade300,
                                    child: Icon(
                                      isPago
                                          ? Icons.attach_money
                                          : isPedido
                                          ? Icons.shopping_bag
                                          : Icons.event,
                                      color: isPago
                                          ? Colors.green.shade800
                                          : isPedido
                                          ? Colors.blue.shade800
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  title: Text(
                                    evento,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    if (isPago) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MisPagosPage(
                                            authService: widget.authService,
                                            rol: rol,
                                            clienteId: widget.user.clienteId,
                                          ),
                                        ),
                                      );
                                    } else if (isPedido) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HistorialPedidosPage(
                                            authService: widget.authService,
                                            esAdmin: true,
                                            clienteId: widget.user.clienteId,
                                            pescadorId: widget.user.pescadorId,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 12),
                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text("Configuración"),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ConfigUserPage(nombre: nombre, rol: rol),
                          ),
                        ),
                      ),

                      if (rol == "CLIENTE" || rol == "ADMIN")
                        ListTile(
                          leading: const Icon(Icons.payment),
                          title: const Text("Ver pagos"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MisPagosPage(
                                authService: widget.authService,
                                rol: rol,
                                clienteId: rol == 'CLIENTE'
                                    ? widget.user.clienteId
                                    : null,
                              ),
                            ),
                          ),
                        ),

                      if (rol == "CLIENTE" || rol == "PESCADOR")
                        ListTile(
                          leading: const Icon(Icons.report_problem),
                          title: const Text("Reportar Problema"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ReportProblemPage(authService: AuthService()),
                            ),
                          ),
                        ),

                      if (rol == "ADMIN")
                        ListTile(
                          leading: const Icon(Icons.report_problem_outlined),
                          title: const Text("Ver Reportes"),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminProblemasPage(
                                authService: widget.authService,
                              ),
                            ),
                          ),
                        ),

                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text("Cerrar sesión"),
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarEventosOverlay(DateTime selectedDay) {
    final eventosDia =
        _eventos[DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        )] ??
        [];

    if (eventosDia.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height * 0.2,
        left: 16,
        right: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Eventos del ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                ...eventosDia.map((evento) {
                  final isPago = evento.contains("💰");
                  final isPedido = evento.contains("📦");

                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isPago
                          ? Icons.attach_money
                          : isPedido
                          ? Icons.shopping_bag
                          : Icons.event,
                      color: isPago
                          ? Colors.green
                          : isPedido
                          ? Colors.blueAccent
                          : Colors.grey,
                    ),
                    title: Text(evento),
                    onTap: () {
                      overlayEntry.remove();
                      if (isPago) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MisPagosPage(
                              authService: widget.authService,
                              rol: widget.user.rol,
                              clienteId: widget.user.clienteId,
                            ),
                          ),
                        );
                      } else if (isPedido) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistorialPedidosPage(
                              authService: widget.authService,
                              esAdmin: true,
                              clienteId: widget.user.clienteId,
                              pescadorId: widget.user.pescadorId,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => overlayEntry.remove(),
                    child: const Text("Cerrar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}
