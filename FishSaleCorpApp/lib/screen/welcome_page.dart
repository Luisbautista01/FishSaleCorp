// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestor_tareas_app/main.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final List<Map<String, String>> features = [
    {
      "title": "Catálogo de Peces",
      "subtitle": "Explora especies frescas directamente del mar.",
      "image": "assets/peces_catalogo.png",
      "color": "#1abc9c",
    },
    {
      "title": "Pedidos y Entregas",
      "subtitle": "Recibe tus productos a tiempo y con frescura garantizada.",
      "image": "assets/envios_entregados.png",
      "color": "#f39c12",
    },
    {
      "title": "Red de Pescadores",
      "subtitle": "Conecta con proveedores confiables y certificados.",
      "image": "assets/pescadores.png",
      "color": "#3498db",
    },
  ];

  final List<Map<String, String>> extraSections = [
    {
      "title": "Promociones Especiales",
      "subtitle": "Descubre las mejores ofertas semanales.",
      "image": "assets/promo.png",
      "color": "#e74c3c",
    },
    {
      "title": "Noticias y Actualizaciones",
      "subtitle": "Mantente informado sobre novedades del sector.",
      "image": "assets/news.png",
      "color": "#9b59b6",
    },
    {
      "title": "Nuevas Alianzas",
      "subtitle": "Conecta con empresas y distribuidores locales.",
      "image": "assets/alliances.png",
      "color": "#2980b9",
    },
  ];

  late final AnimationController _barAnimationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _barAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _barAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: _buildEndDrawer(context),
      body: Stack(
        children: [
          _buildBackground(),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildHeaderText(),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.78),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildHomePage(context),
                          _buildSectionsPage(context),
                          _buildContactPage(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: _openWhatsApp,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/whatsapp.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue.withOpacity(0.9),
              AppColors.secondaryBlue.withOpacity(0.85),
              Colors.tealAccent.withOpacity(0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.05),
              centerTitle: true,
              titleSpacing: 0,
              leadingWidth: 90,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    tooltip: 'Menú',
                  ),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 800),
                    scale: 1.05,
                    curve: Curves.easeInOutBack,
                    child: Image.asset(
                      'assets/logo.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "FishSaleCorp",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      letterSpacing: 1.2,
                      fontFamily: 'Poppins',
                      shadows: [
                        Shadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      final isDark = themeProvider.isDarkMode;
                      return GestureDetector(
                        onTap: () => themeProvider.toggleTheme(!isDark),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              key: ValueKey<bool>(isDark),
                              isDark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              color: isDark
                                  ? Colors.amberAccent
                                  : Colors.tealAccent.shade200,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.tealAccent.shade200,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.anchor_rounded), text: "Inicio"),
                      Tab(
                        icon: FaIcon(FontAwesomeIcons.fish),
                        text: "Secciones",
                      ),
                      Tab(icon: Icon(Icons.phone_rounded), text: "Contacto"),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() => AnimatedContainer(
    duration: const Duration(seconds: 3),
    curve: Curves.easeInOut,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryBlue.withOpacity(0.5),
          Colors.blue.shade200.withOpacity(0.4),
          Colors.teal.shade100.withOpacity(0.15),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );

  Widget _buildHeaderText() => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      children: [
        Text(
          "Frescura marina, tecnología y confianza en cada venta",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue.withOpacity(0.9),
            letterSpacing: 0.3,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Container(
          width: 90,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, Colors.tealAccent.shade400],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildEndDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryBlue),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 800),
                  scale: 1.05,
                  curve: Curves.easeInOutBack,
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  "FishSaleCorp",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.home, "Inicio", 0),
          _drawerItem(Icons.star, "Secciones", 1),
          _drawerItem(Icons.contact_mail, "Contacto", 2),
          const Divider(),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primaryBlue.withOpacity(0.8),
                ),
                title: const Text('Modo Oscuro/Claro'),
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(val),
              );
            },
          ),
          const Divider(),
          _drawerItem(Icons.login, "Iniciar Sesión", null, route: '/login'),
          _drawerItem(
            Icons.app_registration,
            "Registrarse",
            null,
            route: '/register',
          ),
          ListTile(
            leading: Icon(
              Icons.contact_phone,
              color: AppColors.primaryBlue.withOpacity(0.8),
            ),
            title: const Text('Contacto Soporte'),
            onTap: _openWhatsApp,
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(
    IconData icon,
    String text,
    int? index, {
    String? route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue.withOpacity(0.8)),
      title: Text(text),
      onTap: () {
        Navigator.pop(context);
        if (index != null) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _tabController.animateTo(index);
          });
        }
        if (route != null) Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width > 1000
        ? 3
        : width > 600
        ? 2
        : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Bienvenido a FishSaleCorp",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: width > 800 ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "La plataforma ideal para comprar y vender pescado fresco, directo del mar a tu mesa.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: width > 800 ? 18 : 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              _mainButton(
                Icons.login,
                "Iniciar Sesión",
                '/login',
                AppColors.primaryBlue,
              ),
              _mainButton(
                Icons.app_registration,
                "Registrarse",
                '/register',
                AppColors.lightBlue,
              ),
            ],
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimationLimiter(
                child: GridView.builder(
                  itemCount: features.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: width < 600 ? 2.5 : 1.1,
                  ),
                  itemBuilder: (context, i) {
                    final f = features[i];
                    return AnimationConfiguration.staggeredGrid(
                      position: i,
                      columnCount: crossCount,
                      child: SlideAnimation(
                        horizontalOffset: 50.0,
                        duration: const Duration(milliseconds: 600),
                        child: FadeInAnimation(
                          child: _proCard(
                            f['title']!,
                            f['subtitle']!,
                            f['image']!,
                            hexToColor(f['color']!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            "¿Por qué elegir FishSaleCorp?",
            style: TextStyle(
              fontSize: width > 800 ? 26 : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: const [
              _FeatureTile(
                icon: Icons.security,
                color: Colors.green,
                title: "Transacciones seguras",
                subtitle:
                    "Tus datos y operaciones están protegidos con encriptación avanzada.",
              ),
              _FeatureTile(
                icon: Icons.speed,
                color: Colors.orange,
                title: "Gestión rápida y eficiente",
                subtitle: "Organiza pedidos, clientes y productos en segundos.",
              ),
              _FeatureTile(
                icon: Icons.group,
                color: Colors.blue,
                title: "Comunidad de confianza",
                subtitle: "Conecta con pescadores y clientes verificados.",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsPage(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossCount = width > 1000
        ? 3
        : width > 600
        ? 2
        : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Explora las Secciones Más Destacadas",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Accede a todas las herramientas que impulsan tu negocio pesquero.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          _sectionTitle(
            icon: Icons.bar_chart_rounded,
            title: "Estadísticas Generales",
            subtitle:
                "Visualiza tus métricas clave con datos en tiempo real. Analiza ventas, clientes y entregas fácilmente.",
          ),
          _buildSectionGrid(
            context,
            title: "",
            subtitle: "",
            data: [
              {
                "title": "Ventas Mensuales",
                "subtitle": "Tus ingresos actualizados al instante.",
                "image": "assets/ventas.png",
                "color": "#2ecc71",
              },
              {
                "title": "Nuevos Clientes",
                "subtitle": "Personas que confían en tu negocio.",
                "image": "assets/clientes.png",
                "color": "#f39c12",
              },
              {
                "title": "Pedidos Entregados",
                "subtitle": "Cumple tus objetivos con precisión.",
                "image": "assets/envios_entregados.png",
                "color": "#3498db",
              },
            ],
            crossCount: crossCount,
            width: width,
          ),
          const Divider(thickness: 1.5),

          _sectionTitle(
            icon: Icons.build_rounded,
            title: "Herramientas Profesionales",
            subtitle:
                "Optimiza tus procesos diarios con funciones avanzadas y automatizaciones inteligentes.",
          ),
          _buildSectionGrid(
            context,
            title: "",
            subtitle: "",
            data: [
              {
                "title": "Reportes Detallados",
                "subtitle": "Analiza tu progreso día a día.",
                "image": "assets/reportes.png",
                "color": "#9b59b6",
              },
              {
                "title": "Gestión de Inventario",
                "subtitle": "Controla el stock en tiempo real.",
                "image": "assets/inventario.png",
                "color": "#1abc9c",
              },
              {
                "title": "Certificación de Calidad",
                "subtitle": "Garantía de frescura en cada venta.",
                "image": "assets/cert.png",
                "color": "#27ae60",
              },
            ],
            crossCount: crossCount,
            width: width,
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1.5),

          _sectionTitle(
            icon: Icons.star_rounded,
            title: "Beneficios Exclusivos",
            subtitle:
                "Descubre las ventajas únicas que te ofrece FishSaleCorp y lleva tu negocio al siguiente nivel.",
          ),
          const SizedBox(height: 20),

          AnimationLimiter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                final itemWidth = isWide
                    ? (constraints.maxWidth - 80) / 3
                    : (constraints.maxWidth - 40) / 1;
                final features = [
                  {
                    "icon": Icons.eco_rounded,
                    "color": Colors.green,
                    "title": "Sostenibilidad garantizada",
                    "subtitle":
                        "Apoyamos la pesca responsable y el cuidado marino.",
                  },
                  {
                    "icon": Icons.local_shipping_rounded,
                    "color": Colors.orange,
                    "title": "Logística eficiente",
                    "subtitle": "Envíos rápidos con trazabilidad completa.",
                  },
                  {
                    "icon": Icons.support_agent_rounded,
                    "color": Colors.blueAccent,
                    "title": "Atención personalizada",
                    "subtitle": "Soporte disponible 24/7 para ayudarte.",
                  },
                ];

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: List.generate(features.length, (index) {
                    final feature = features[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      columnCount: 3,
                      child: SlideAnimation(
                        horizontalOffset: 60.0,
                        child: FadeInAnimation(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: itemWidth,
                              minWidth: 260,
                            ),
                            child: _FeatureTile(
                              icon: feature["icon"] as IconData,
                              color: feature["color"] as Color,
                              title: feature["title"] as String,
                              subtitle: feature["subtitle"] as String,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 26),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, Colors.tealAccent.shade400],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSectionGrid(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<Map<String, String>> data,
    required int crossCount,
    required double width,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 10),
        AnimationLimiter(
          child: GridView.builder(
            itemCount: data.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width < 600 ? 2.5 : 1.2,
            ),
            itemBuilder: (context, i) {
              final item = data[i];
              return AnimationConfiguration.staggeredGrid(
                position: i,
                columnCount: crossCount,
                child: SlideAnimation(
                  duration: const Duration(milliseconds: 600),
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _proCard(
                      item['title']!,
                      item['subtitle']!,
                      item['image']!,
                      hexToColor(item['color']!),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactPage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey[300]! : Colors.black54;

    final contacts = [
      {
        "img": 'assets/gmail.png',
        "title": "Correo",
        "subtitle": "soporte@fishSalecorp.com",
        "action": _sendEmail,
      },
      {
        "img": 'assets/whatsapp.png',
        "title": "WhatsApp",
        "subtitle": "+57 3004569567",
        "action": _openWhatsApp,
      },
      {
        "img": 'assets/ubicacion.png',
        "title": "Ubicación",
        "subtitle": "Calle 45 #23-11, Córdoba",
        "action": null,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.support_agent,
                size: 80,
                color: Colors.tealAccent.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                "Contáctanos",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Nuestro equipo de soporte está disponible para atenderte por correo, WhatsApp o ubicación física.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: subtitleColor),
              ),
              const SizedBox(height: 30),
              AnimationLimiter(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: List.generate(contacts.length, (i) {
                    final contact = contacts[i];
                    return AnimationConfiguration.staggeredGrid(
                      position: i,
                      columnCount: contacts.length,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 60,
                        child: FadeInAnimation(
                          child: _contactTile(
                            context,
                            contact['img']?.toString() ?? "Sin imagen",
                            contact['title']?.toString() ?? "Sin contacto",
                            contact['subtitle']?.toString() ?? "Sin subtitulo",
                            contact['action'] as VoidCallback?,
                            cardColor,
                            textColor,
                            subtitleColor,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 30),
              Divider(thickness: 1.2, color: subtitleColor),
              const SizedBox(height: 20),
              Text(
                "Sobre Nosotros",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent.shade400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "En FishSaleCorp conectamos pescadores artesanales, distribuidores y clientes finales mediante una plataforma digital confiable y sostenible. Garantizamos la frescura del producto y promovemos la pesca responsable.",
                style: TextStyle(color: textColor, fontSize: 15),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),
              _buildAnimatedButton(
                assetPath: 'assets/whatsapp.png',
                label: "Chatea con nosotros",
                color: Colors.green,
                onPressed: _openWhatsApp,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTile(
    BuildContext context,
    String img,
    String title,
    String subtitle,
    VoidCallback? onTap,
    Color cardColor,
    Color textColor,
    Color subtitleColor,
  ) {
    return Card(
      elevation: 8,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        splashColor: Colors.tealAccent.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [cardColor, cardColor.withOpacity(0.95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(img, width: 50, height: 50),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: subtitleColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainButton(IconData icon, String label, String route, Color color) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required String assetPath,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(assetPath, width: 26, height: 26),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 8,
      ),
    );
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Widget _proCard(String title, String subtitle, String image, Color color) {
    return SlideAnimation(
      verticalOffset: 80.0,
      duration: const Duration(milliseconds: 600),
      child: FadeInAnimation(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.lightBlue,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2),
                BlendMode.darken,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue.withOpacity(0.85),
                  AppColors.secondaryBlue.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.analytics, color: Colors.white, size: 40),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bautistaluiantonio24@gmail.com',
      query: 'subject=Soporte FishSaleCorp&body=Hola, necesito ayuda con...',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openWhatsApp() async {
    const phone = '+573004569567';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phone?text=Hola,%20necesito%20soporte%20FishSaleCorp',
    );
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 200,
        maxWidth: 360,
        minHeight: 150,
      ),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black38,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(icon, color: color, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
