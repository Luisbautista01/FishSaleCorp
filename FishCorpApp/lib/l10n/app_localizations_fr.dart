// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'FishSaleCorp App';

  @override
  String get users => 'Utilisateurs';

  @override
  String get fishermen => 'Pêcheurs';

  @override
  String get clients => 'Clients';

  @override
  String get preferences => 'Préférences';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get dark_mode => 'Mode sombre';

  @override
  String get save_changes => 'Enregistrer les modifications';

  @override
  String get profile_updated => 'Profil mis à jour avec succès';

  @override
  String get no_data => 'Aucune donnée disponible';

  @override
  String get dark_mode_description =>
      'Activer le thème sombre pour l\'application';

  @override
  String get change_password => 'Changer le mot de passe';

  @override
  String get change_password_subtitle => 'Mettez à jour votre mot de passe';

  @override
  String get about_subtitle => 'Version de l\'application et développeur';

  @override
  String get report_problem_subtitle =>
      'Envoyer un rapport à soporte@fishcorp.com';

  @override
  String get confirm_delete_title => 'Confirmer la suppression';

  @override
  String confirm_delete_message(Object name) {
    return 'Voulez-vous supprimer $name ? Cette action est irréversible.';
  }

  @override
  String get confirm_change_role_title => 'Confirmer le changement de rôle';

  @override
  String confirm_change_role_message(Object name, Object role) {
    return 'Voulez-vous changer le rôle de $name en $role ?';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get change_to_client => 'Changer en Client';

  @override
  String get change_to_fisherman => 'Changer en Pêcheur';

  @override
  String get change_to_admin => 'Changer en Admin';

  @override
  String get user_deleted => 'Utilisateur supprimé avec succès';

  @override
  String role_changed(Object role) {
    return 'Rôle changé en $role avec succès';
  }

  @override
  String get about_title => 'À propos de FishSaleCorp';

  @override
  String get report_problem => 'Signaler un problème';

  @override
  String language_changed(Object lang) {
    return 'Langue changée en $lang';
  }
}
