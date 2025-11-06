// ignore_for_file: use_build_context_synchronously, unused_local_variable
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestor_tareas_app/main.dart';
import 'package:gestor_tareas_app/screen/reset_password_page.dart';
import 'package:gestor_tareas_app/l10n/app_localizations.dart';
import 'package:gestor_tareas_app/report/report_problem_page.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:gestor_tareas_app/services/auth_service.dart';
import 'package:gestor_tareas_app/admin/usuarios_provider.dart';
import 'package:gestor_tareas_app/services/guide_service.dart';
import 'package:gestor_tareas_app/services/locale_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigUserPage extends StatefulWidget {
  final String rol;
  final String nombre;
  const ConfigUserPage({super.key, required this.nombre, required this.rol});

  @override
  State<ConfigUserPage> createState() => _ConfigUserPageState();
}

class _ConfigUserPageState extends State<ConfigUserPage> {
  bool _darkMode = false;
  bool _notificaciones = true;
  String _idioma = 'Español';
  File? _imagenPerfil;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombreCtrl.text = widget.nombre;
    _correoCtrl.text = '';
    _telefonoCtrl.text = '';
    _loadPreferences();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagenPerfil = File(image.path));
    }
  }

  Future<void> _guardarCambiosPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<UsuariosProvider>();
      final usuarios = provider.clientes + provider.pescadores;

      final usuario = usuarios.firstWhere(
        (u) => u['email'] == _correoCtrl.text,
        orElse: () => {},
      );

      if (usuario.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Usuario no encontrado")));
        return;
      }

      final usuarioId = usuario['id'];
      await provider.actualizarPerfil({
        "id": usuarioId,
        "nombre": _nombreCtrl.text,
        "email": _correoCtrl.text,
        "telefono": _telefonoCtrl.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil actualizado correctamente")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar cambios: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('modo_oscuro') ?? false;
      _idioma = prefs.getString('idioma') ?? 'Español';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final gradientBg = isDarkMode
        ? const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
        : const [Color(0xFFB3E5FC), Color(0xFFE1F5FE)];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientBg,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: _seleccionarImagen,
                                      child: CircleAvatar(
                                        radius: 55,
                                        backgroundColor: Colors.blueAccent,
                                        backgroundImage: _imagenPerfil != null
                                            ? FileImage(_imagenPerfil!)
                                            : null,
                                        child: _imagenPerfil == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 65,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      widget.nombre,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Rol: ${widget.rol}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      _nombreCtrl,
                                      "Nombre completo",
                                      Icons.person_outline,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                      _correoCtrl,
                                      "Correo electrónico",
                                      Icons.email_outlined,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildTextField(
                                      _telefonoCtrl,
                                      "Teléfono",
                                      Icons.phone_outlined,
                                    ),
                                    const SizedBox(height: 20),
                                    _isSaving
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton.icon(
                                            onPressed: _guardarCambiosPerfil,
                                            icon: const Icon(Icons.save),
                                            label: const Text(
                                              "Guardar cambios",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                    horizontal: 24,
                                                  ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 25 : 0,
                          height: isWide ? 0 : 25,
                        ),

                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle("Preferencias"),
                              _buildCard(
                                child: Column(
                                  children: [
                                    SwitchListTile(
                                      title: Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.dark_mode ??
                                            'Modo oscuro',
                                      ),
                                      subtitle: Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.dark_mode_description ??
                                            'Activa el tema oscuro en toda la aplicación',
                                      ),
                                      value: _darkMode,
                                      onChanged: (value) async {
                                        setState(() => _darkMode = value);

                                        final themeProvider =
                                            Provider.of<ThemeProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await themeProvider.toggleTheme(value);

                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setBool(
                                          'modo_oscuro',
                                          value,
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              value
                                                  ? "Modo oscuro activado"
                                                  : "Modo claro activado",
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SwitchListTile(
                                      title: const Text("Notificaciones"),
                                      subtitle: const Text(
                                        "Recibir alertas y avisos importantes",
                                      ),
                                      value: _notificaciones,
                                      onChanged: (v) =>
                                          setState(() => _notificaciones = v),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSectionTitle(
                                AppLocalizations.of(context)?.language ??
                                    'Idioma',
                              ),
                              _buildCard(
                                child: DropdownButtonFormField<String>(
                                  value: _idioma,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Español',
                                      child: Text('Español 🇨🇴'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Inglés',
                                      child: Text('English 🇺🇸'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Francés',
                                      child: Text('Français 🇫🇷'),
                                    ),
                                  ],
                                  onChanged: (v) async {
                                    setState(() => _idioma = v!);
                                    final localeCode = v == 'Español'
                                        ? 'es'
                                        : v == 'Inglés'
                                        ? 'en'
                                        : 'fr';

                                    final localeProvider =
                                        Provider.of<LocaleProvider>(
                                          context,
                                          listen: false,
                                        );
                                    await localeProvider.setLocale(
                                      Locale(localeCode),
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Idioma cambiado a $v"),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildSectionTitle("Herramientas"),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isWide = constraints.maxWidth > 700;
                                  return GridView.count(
                                    crossAxisCount: isWide ? 2 : 1,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      _buildToolCard(
                                        icon: Icons.lock_outline,
                                        title: 'Cambiar contraseña',
                                        description:
                                            'Actualiza tu contraseña de acceso de forma segura',
                                        color1: AppColors.primaryBlue,
                                        color2: AppColors.accent,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ResetPasswordPage(
                                                email: _correoCtrl.text,
                                                authService: AuthService(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildToolCard(
                                        icon: Icons.info_outline,
                                        title: 'Acerca de FishSaleCorp',
                                        description:
                                            'Información de la aplicación, desarrollador y versión',
                                        color1: AppColors.secondaryBlue,
                                        color2: AppColors.primaryBlue,
                                        action: () => _mostrarDialogo(
                                          context,
                                          titulo: "FishSaleCorp App v1.0.0",
                                          descripcion:
                                              "Desarrollado por Luis Bautista\n\nFishSaleCorp es una aplicación diseñada para la gestión eficiente de pedidos y ventas de productos del mar, brindando transparencia y facilidad tanto para clientes como para pescadores.\n\nVersión: 1.0\nCorreo soporte: soporte@fishSalecorp.com",
                                        ),
                                      ),
                                      _buildToolCard(
                                        icon: Icons.book_outlined,
                                        title: 'Licencias de software',
                                        description:
                                            'Ver las licencias de las dependencias utilizadas en la app',
                                        color1: AppColors.primaryBlue,
                                        color2: AppColors.secondaryBlue,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => Theme(
                                                data: ThemeData(
                                                  primaryColor:
                                                      AppColors.primaryBlue,
                                                  colorScheme:
                                                      ColorScheme.fromSwatch()
                                                          .copyWith(
                                                            secondary: AppColors
                                                                .accent,
                                                          ),
                                                  textTheme: Theme.of(context)
                                                      .textTheme
                                                      .apply(
                                                        bodyColor:
                                                            AppColors.darkText,
                                                        displayColor:
                                                            AppColors.darkText,
                                                      ),
                                                ),
                                                child: const LicensePage(
                                                  applicationName:
                                                      "FishSaleCorp",
                                                  applicationVersion: "1.0.0",
                                                  applicationIcon: FaIcon(
                                                    FontAwesomeIcons.fish,
                                                    size: 40,
                                                    color:
                                                        AppColors.primaryBlue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      _buildToolCard(
                                        icon: Icons.policy_outlined,
                                        title: 'Política de Privacidad',
                                        description:
                                            'Lee cómo protegemos tus datos y garantizamos tu privacidad',
                                        color1: AppColors.primaryBlue,
                                        color2: AppColors.secondaryBlue,
                                        action: () => _mostrarDialogo(
                                          context,
                                          titulo: "Política de Privacidad",
                                          descripcion:
                                              "Tus datos personales son utilizados únicamente con fines de registro y uso interno. No compartimos información con terceros sin tu consentimiento.\n\nPara más detalles, consulta nuestra política completa en: www.fishsalecorp.com/privacidad",
                                        ),
                                      ),
                                      _buildToolCard(
                                        icon: Icons.gavel_outlined,
                                        title: 'Términos y Condiciones',
                                        description:
                                            'Consulta las normas de uso y responsabilidades del servicio',
                                        color1: AppColors.primaryBlue,
                                        color2: AppColors.secondaryBlue,
                                        action: () => _mostrarDialogo(
                                          context,
                                          titulo: "📜 Términos y Condiciones",
                                          descripcion:
                                              "Al utilizar FishSaleCorp, aceptas nuestros términos de uso. Nos reservamos el derecho de actualizar condiciones para mejorar el servicio. Consulta la versión completa en: www.fishsalecorp.com/terminos",
                                        ),
                                      ),
                                      _buildToolCard(
                                        icon: Icons.replay_outlined,
                                        title: 'Reiniciar guías',
                                        description:
                                            'Restablece los tutoriales interactivos para mostrarlos nuevamente',
                                        color1: AppColors.primaryBlue,
                                        color2: AppColors.secondaryBlue,
                                        action: () async {
                                          final auth = AuthService();
                                          final clienteId = await auth
                                              .getUserId();
                                          final pescadorId = await auth
                                              .getUserId();
                                          final adminId = await auth
                                              .getUserId();
                                          final userId =
                                              clienteId ??
                                              pescadorId ??
                                              adminId ??
                                              0;

                                          await GuideService.resetForUser(
                                            userId,
                                          );

                                          if (!mounted) return;
                                          _mostrarDialogo(
                                            context,
                                            titulo: "Guías reiniciadas",
                                            descripcion:
                                                "Las guías se han restablecido correctamente. Navega a las pantallas correspondientes para verlas nuevamente.",
                                          );
                                        },
                                      ),
                                      _buildToolCard(
                                        icon: Icons.support_agent_outlined,
                                        title: 'Centro de Ayuda',
                                        description:
                                            'Obtén soporte, contacta asistencia o revisa preguntas frecuentes',
                                        color1: AppColors.primaryBlue,
                                        color2: AppColors.secondaryBlue,
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ReportProblemPage(
                                                authService: AuthService(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }

  Widget _buildSectionTitle(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.tealAccent : Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback action,
    Color color1 = Colors.blueAccent,
    Color color2 = Colors.lightBlueAccent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? [color1.withOpacity(0.6), color2.withOpacity(0.3)]
        : [color1, color2];
    final textColor = isDark ? Colors.white : Colors.white;
    final subtitleColor = isDark ? Colors.white70 : Colors.white70;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: action,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color1.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: subtitleColor, fontSize: 14),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: action,
              child: const Text("Acceder"),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogo(
    BuildContext context, {
    required String titulo,
    required String descripcion,
    String? rutaDestino,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(descripcion),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cerrar"),
                  ),
                ),
                if (rutaDestino != null)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, rutaDestino);
                      },
                      child: const Text("Ir"),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
