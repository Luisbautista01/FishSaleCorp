// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FishSaleCorp App';

  @override
  String get users => 'Usuarios';

  @override
  String get fishermen => 'Pescadores';

  @override
  String get clients => 'Clientes';

  @override
  String get preferences => 'Preferencias';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get dark_mode => 'Modo oscuro';

  @override
  String get save_changes => 'Guardar cambios';

  @override
  String get profile_updated => 'Perfil actualizado correctamente';

  @override
  String get no_data => 'No hay datos disponibles';

  @override
  String get dark_mode_description =>
      'Activa el tema oscuro en toda la aplicación';

  @override
  String get change_password => 'Cambiar contraseña';

  @override
  String get change_password_subtitle => 'Actualiza tu contraseña de acceso';

  @override
  String get about_subtitle => 'Versión de la app y desarrollador';

  @override
  String get report_problem_subtitle => 'Enviar reporte a soporte@fishcorp.com';

  @override
  String get confirm_delete_title => 'Confirmar eliminación';

  @override
  String confirm_delete_message(Object name) {
    return '¿Estás seguro de eliminar a $name? Esta acción no se puede deshacer.';
  }

  @override
  String get confirm_change_role_title => 'Confirmar cambio de rol';

  @override
  String confirm_change_role_message(Object name, Object role) {
    return '¿Deseas cambiar el rol de $name a $role?';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get delete => 'Eliminar';

  @override
  String get change_to_client => 'Cambiar a Cliente';

  @override
  String get change_to_fisherman => 'Cambiar a Pescador';

  @override
  String get change_to_admin => 'Cambiar a Admin';

  @override
  String get user_deleted => 'Usuario eliminado con éxito';

  @override
  String role_changed(Object role) {
    return 'Rol cambiado a $role con éxito';
  }

  @override
  String get about_title => 'Acerca de FishSaleCorp';

  @override
  String get report_problem => 'Reportar un problema';

  @override
  String language_changed(Object lang) {
    return 'Idioma cambiado a $lang';
  }
}
