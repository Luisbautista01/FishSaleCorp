// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, avoid_print, unnecessary_to_list_in_spreads, curly_braces_in_flow_control_structures, unused_local_variable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestor_tareas_app/pay_wompi/mis_pagos_page.dart';
import 'package:gestor_tareas_app/pedidos/historial_pedidos_page.dart';
import 'package:gestor_tareas_app/services/api_config.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:gestor_tareas_app/services/eventos_service.dart';
import 'package:gestor_tareas_app/admin/user.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeMainScreen extends StatefulWidget {
  final User user;
  final String rol;
  final AuthService authService;

  const HomeMainScreen({
    required this.user,
    required this.rol,
    required this.authService,
    super.key,
  });

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final PageController _pageController = PageController();
  int _currentBanner = 0;
  late Timer _timer;

  final EventosService _eventosService = EventosService(
    baseUrl: ApiConfig.baseUrl,
  );

  final List<Map<String, String>> _banners = [
    {
      "titulo": "💳 Bienvenido a tu Panel",
      "subtitulo": "Administra tus finanzas y pedidos con estilo",
    },
    {
      "titulo": "📊 Seguimiento en tiempo real",
      "subtitulo": "Controla tus ventas y transacciones fácilmente",
    },
    {
      "titulo": "🔒 Plataforma segura",
      "subtitulo": "Tus datos y operaciones están protegidos",
    },
  ];

  Map<DateTime, List<String>> _eventos = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _filtroTipo = 'Todos';
  String _filtroOrden = 'Más recientes';
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _startAutoScroll();
    _cargarEventos();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_pageController.hasClients) {
        _currentBanner = (_currentBanner + 1) % _banners.length;
        _pageController.animateToPage(
          _currentBanner,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _cargarEventos() async {
    final token = await widget.authService.getToken();
    if (token == null || token.isEmpty) return;

    final eventos = await _eventosService.obtenerEventos(
      rol: widget.rol,
      clienteId: widget.user.clienteId,
      pescadorId: widget.user.pescadorId,
      token: token,
    );

    setState(() {
      _eventos = eventos;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  Widget _buildCalendario() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) =>
                _eventos[DateTime(day.year, day.month, day.day)] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
              markerDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildBarraFiltros(),
        const SizedBox(height: 8),
        _buildListaEventosFiltrada(),
      ],
    );
  }

  List<String> _filtrarEventos(List<String> eventos) {
    List<String> filtrados = eventos;

    if (_filtroTipo == 'Pagos') {
      filtrados = filtrados.where((e) => e.contains('💰')).toList();
    } else if (_filtroTipo == 'Pedidos') {
      filtrados = filtrados.where((e) => e.contains('📦')).toList();
    }

    if (_busqueda.isNotEmpty) {
      filtrados = filtrados
          .where((e) => e.toLowerCase().contains(_busqueda.toLowerCase()))
          .toList();
    }

    if (_filtroOrden == 'Más recientes') {
      filtrados = filtrados.reversed.toList();
    }

    return filtrados;
  }

  Widget _buildListaEventosFiltrada() {
    final eventosDia = _filtrarEventos(
      _eventos[DateTime(
            _selectedDay?.year ?? _focusedDay.year,
            _selectedDay?.month ?? _focusedDay.month,
            _selectedDay?.day ?? _focusedDay.day,
          )] ??
          [],
    );

    return Material(
      key: ValueKey(eventosDia.length),
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.white, blurRadius: 6, offset: Offset(1, 1)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Eventos del ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
                fontSize: 14,
              ),
            ),
            const Divider(),
            ...eventosDia.map((evento) {
              final isPago = evento.contains("💰");
              final isPedido = evento.contains("📦");
              return ListTile(
                dense: true,
                minLeadingWidth: 20,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isPago ? Icons.payment : Icons.shopping_cart,
                  color: isPago ? Colors.green : Colors.orangeAccent,
                  size: 20,
                ),
                title: Text(evento, style: const TextStyle(fontSize: 12)),
                trailing: TextButton(
                  onPressed: () {
                    if (isPago) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MisPagosPage(
                            authService: widget.authService,
                            rol: widget.rol,
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
                  child: Text(
                    isPago ? 'Ver pago' : 'Ver pedido',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraFiltros() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'Pagos', child: Text('Pagos')),
                    DropdownMenuItem(value: 'Pedidos', child: Text('Pedidos')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroTipo = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroOrden,
                  decoration: const InputDecoration(
                    labelText: 'Orden',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Más recientes',
                      child: Text('Más recientes'),
                    ),
                    DropdownMenuItem(
                      value: 'Más antiguos',
                      child: Text('Más antiguos'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filtroOrden = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar evento...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600 && width < 1024;
    final isDesktop = width >= 1024;

    final eventosDia =
        _eventos[DateTime(
          _selectedDay?.year ?? _focusedDay.year,
          _selectedDay?.month ?? _focusedDay.month,
          _selectedDay?.day ?? _focusedDay.day,
        )] ??
        [];

    return Portal(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildBannerSection(isTablet || isDesktop),
              const SizedBox(height: 40),
              _buildSectionTitle("Panel de Información"),
              const SizedBox(height: 20),
              _buildInfoCards(isTablet || isDesktop, width),
              const SizedBox(height: 40),
              _buildSectionTitle("Resumen Financiero"),
              const SizedBox(height: 20),
              _buildResumenFinanciero(isTablet || isDesktop),
              const SizedBox(height: 40),
              _buildSectionTitle("Calendario de Pagos y Pedidos"),
              const SizedBox(height: 10),
              _buildCalendario(),
              _buildHistorialEventos(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildBannerSection(bool isLarge) {
    return Container(
      height: isLarge ? 160 : 130,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _banners.length,
          onPageChanged: (index) => setState(() => _currentBanner = index),
          itemBuilder: (context, index) {
            final banner = _banners[index];
            return Container(
              padding: EdgeInsets.symmetric(horizontal: isLarge ? 24 : 16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner["titulo"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLarge ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      banner["subtitulo"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: isLarge ? 15 : 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistorialEventos() {
    if (_eventos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: Text("No hay registros de pagos o pedidos aún."),
      );
    }

    final fechas = _eventos.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Historial de Pagos y Pedidos",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 10),
        ...fechas.map((fecha) {
          final eventosDelDia = _filtrarEventos(_eventos[fecha] ?? []);
          if (eventosDelDia.isEmpty) return const SizedBox.shrink();

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${fecha.day}/${fecha.month}/${fecha.year}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const Divider(),
                  ...eventosDelDia.map((evento) {
                    final isPago = evento.contains("💰");
                    final isPedido = evento.contains("📦");
                    return ListTile(
                      leading: Icon(
                        isPago ? Icons.payment : Icons.shopping_cart,
                        color: isPago ? Colors.green : Colors.orangeAccent,
                      ),
                      title: Text(evento),
                      trailing: TextButton(
                        onPressed: () {
                          if (isPago) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MisPagosPage(
                                  authService: widget.authService,
                                  rol: widget.rol,
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
                        child: Text(
                          isPago ? "Ver pago" : "Ver pedido",
                          style: const TextStyle(color: AppColors.primaryBlue),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInfoCards(bool isLarge, double width) {
    final cards = [
      {
        "icon": Icons.shopping_basket,
        "title": "Pedidos activos",
        "value": "12",
        "detail": "Pedidos que están en curso.",
      },
      {
        "icon": Icons.check_circle,
        "title": "Entregados",
        "value": "24",
        "detail": "Pedidos completados con éxito.",
      },
      {
        "icon": Icons.attach_money,
        "title": "Ganancias",
        "value": "\$350k",
        "detail": "Total de ganancias del mes.",
      },
      {
        "icon": Icons.people_alt,
        "title": "Usuarios",
        "value": "58",
        "detail": "Usuarios registrados en la plataforma.",
      },
      {
        "icon": FontAwesomeIcons.fish,
        "title": "Productos",
        "value": "120",
        "detail": "Productos disponibles actualmente.",
      },
    ];

    int crossCount = 2;
    if (width >= 600 && width < 1024) crossCount = 3;
    if (width >= 1024) crossCount = 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _AnimatedInfoCardFlip(
          icon: card["icon"] as IconData,
          title: card["title"]?.toString() ?? "Sin título",
          value: card["value"]?.toString() ?? "0",
          detail: card["detail"]?.toString() ?? "Sin detalles",
          isLarge: isLarge,
        );
      },
    );
  }

  Widget _buildResumenFinanciero(bool isLarge) {
    final resumenItems = [
      {
        "label": "Ingresos",
        "value": "\$1.200k",
        "detail": "Detalle de ingresos: Ventas del mes, facturas, etc.",
      },
      {
        "label": "Egresos",
        "value": "\$450k",
        "detail": "Detalle de egresos: Compras, pagos a proveedores, etc.",
      },
      {
        "label": "Balance",
        "value": "\$750k",
        "detail": "Balance neto: ingresos - egresos = \$750k",
      },
    ];

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;
            return isWide
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: resumenItems.map((item) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: _ResumenItemFlip(
                            label: item["label"]!,
                            value: item["value"]!,
                            detail: item["detail"]!,
                            icon: item["label"] == "Ingresos"
                                ? Icons.arrow_upward
                                : item["label"] == "Egresos"
                                ? Icons.arrow_downward
                                : Icons.balance,
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : Column(
                    children: resumenItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _ResumenItemFlip(
                          label: item["label"]!,
                          value: item["value"]!,
                          detail: item["detail"]!,
                          icon: item["label"] == "Ingresos"
                              ? Icons.arrow_upward
                              : item["label"] == "Egresos"
                              ? Icons.arrow_downward
                              : Icons.balance,
                        ),
                      );
                    }).toList(),
                  );
          },
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}

class _AnimatedInfoCardFlip extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final bool isLarge;

  const _AnimatedInfoCardFlip({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.isLarge,
  });

  @override
  State<_AnimatedInfoCardFlip> createState() => _AnimatedInfoCardFlipState();
}

class _AnimatedInfoCardFlipState extends State<_AnimatedInfoCardFlip>
    with SingleTickerProviderStateMixin {
  bool _flipped = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _toggleFlip() {
    if (_flipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _flipped = !_flipped;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isFront = _controller.value < 0.5;
          final display = isFront ? _front() : _back();
          final rotationY = isFront
              ? _controller.value * 3.1416
              : (_controller.value - 1) * 3.1416;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(rotationY),
            child: display,
          );
        },
      ),
    );
  }

  Widget _front() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightBlue, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: AppColors.primaryBlue,
            size: widget.isLarge ? 36 : 28,
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.greyText,
              fontSize: widget.isLarge ? 15 : 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: widget.isLarge ? 20 : 17,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _back() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class _ResumenItemFlip extends StatefulWidget {
  final String label;
  final String value;
  final String detail;
  final IconData icon;

  const _ResumenItemFlip({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
  });

  @override
  State<_ResumenItemFlip> createState() => _ResumenItemFlipState();
}

class _ResumenItemFlipState extends State<_ResumenItemFlip>
    with SingleTickerProviderStateMixin {
  bool _flipped = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _toggleFlip() {
    if (_flipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _flipped = !_flipped;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final isFront = _controller.value < 0.5;
          final display = isFront ? _front() : _back();
          final rotationY = isFront
              ? _controller.value * 3.1416
              : (_controller.value - 1) * 3.1416;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(rotationY),
            child: display,
          );
        },
      ),
    );
  }

  Widget _front() {
    return Container(
      width: 140,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: const TextStyle(color: AppColors.greyText, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            widget.value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _back() {
    return Container(
      width: 140,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
