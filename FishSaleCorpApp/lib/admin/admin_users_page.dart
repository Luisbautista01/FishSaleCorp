// ignore_for_file: use_build_context_synchronously
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gestor_tareas_app/services/app_colors.dart';
import 'package:gestor_tareas_app/services/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:gestor_tareas_app/admin/editar_usuario_page.dart';
import 'package:gestor_tareas_app/admin/usuarios_provider.dart';
import 'package:gestor_tareas_app/l10n/app_localizations.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) return;
      final rol = _tabController.index == 0 ? "pescadores" : "clientes";
      await context.read<UsuariosProvider>().loadUsuarios(rol);
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsuariosProvider>().loadUsuarios("pescadores");
    });
  }

  Widget _buildUserGrid(
    List<dynamic> usuarios,
    String rol,
    bool isLoading,
    String? errorMessage,
  ) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorMessage != null) {
      return Center(child: Text("Error: $errorMessage"));
    }

    if (usuarios.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)?.no_data ?? 'No hay datos disponibles',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600 && constraints.maxWidth <= 900) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(14),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final usuario = usuarios[index];

            return Card(
              color: AppColors.white,
              elevation: 3,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.lightBlue.withOpacity(0.2),
                      AppColors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.primaryBlue.withOpacity(
                          0.15,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: rol == "pescadores"
                              ? AppColors.secondaryBlue
                              : AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        usuario['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.darkBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        usuario['email'] ?? 'Sin correo',
                        style: const TextStyle(
                          color: AppColors.greyText,
                          fontSize: 12.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Chip(
                        label: Text(usuario['rol'] ?? ''),
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.secondaryBlue,
                            ),
                            onPressed: () async {
                              final actualizado = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditarUsuarioPage(
                                    usuario: usuario,
                                    rolActual: rol,
                                  ),
                                ),
                              );
                              if (actualizado == true) {
                                mostrarExitoDialog(
                                  context,
                                  'Usuario actualizado correctamente.',
                                );
                                await context
                                    .read<UsuariosProvider>()
                                    .loadUsuarios(rol);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () async {
                              final confirmado = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: const Text(
                                    'Eliminar usuario',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    '¿Seguro que desea eliminar este usuario?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmado == true) {
                                try {
                                  await context
                                      .read<UsuariosProvider>()
                                      .eliminarUsuario(usuario['id'], rol);

                                  mostrarExitoDialog(
                                    context,
                                    'Usuario eliminado correctamente.',
                                  );
                                  await context
                                      .read<UsuariosProvider>()
                                      .loadUsuarios(rol);
                                  if (mounted) setState(() {});
                                } catch (e) {
                                  mostrarErrorDialog(context, e.toString());
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsuariosProvider>(
      builder: (context, provider, child) {
        final totalPescadores = provider.pescadores.length;
        final totalClientes = provider.clientes.length;
        final totalUsuarios = totalPescadores + totalClientes;

        return Scaffold(
          backgroundColor: AppColors.lightBlue,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            title: Text(
              AppLocalizations.of(context)?.users ?? 'Usuarios',
              style: const TextStyle(color: AppColors.darkBlue),
              textAlign: TextAlign.center,
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryBlue,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: "Pescadores"),
                Tab(text: "Clientes"),
              ],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text(
                          "Distribución de Usuarios",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (totalUsuarios == 0)
                          const Text("No hay datos disponibles")
                        else
                          SizedBox(
                            height: 140,
                            child: PieChart(
                              PieChartData(
                                centerSpaceRadius: 30,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                                sections: [
                                  PieChartSectionData(
                                    color: AppColors.secondaryBlue,
                                    value: totalPescadores.toDouble(),
                                    radius: 45,
                                    title: totalUsuarios > 0
                                        ? "Pesc.\n${((totalPescadores / totalUsuarios) * 100).toStringAsFixed(1)}%"
                                        : "0%",
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orangeAccent,
                                    value: totalClientes.toDouble(),
                                    radius: 45,
                                    title: totalUsuarios > 0
                                        ? "Cli.\n${((totalClientes / totalUsuarios) * 100).toStringAsFixed(1)}%"
                                        : "0%",
                                    titleStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final creado = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const EditarUsuarioPage(rolActual: 'CLIENTE'),
                      ),
                    );
                    if (creado == true) {
                      await context.read<UsuariosProvider>().loadUsuarios(
                        "clientes",
                      );
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    "Registrar nuevo cliente",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUserGrid(
                      provider.pescadores,
                      "pescadores",
                      provider.isLoading,
                      provider.errorMessage,
                    ),
                    _buildUserGrid(
                      provider.clientes,
                      "clientes",
                      provider.isLoading,
                      provider.errorMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.accent,
            onPressed: () async {
              final creado = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditarUsuarioPage(rolActual: 'CLIENTE'),
                ),
              );
              if (creado == true) {
                final rol = _tabController.index == 0
                    ? "pescadores"
                    : "clientes";
                await context.read<UsuariosProvider>().loadUsuarios(rol);
                setState(() {});
              }
            },
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        );
      },
    );
  }
}
