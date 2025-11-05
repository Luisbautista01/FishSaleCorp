// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FishSaleCorp App';

  @override
  String get users => 'Users';

  @override
  String get fishermen => 'Fishermen';

  @override
  String get clients => 'Clients';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get dark_mode => 'Dark mode';

  @override
  String get save_changes => 'Save changes';

  @override
  String get profile_updated => 'Profile updated successfully';

  @override
  String get no_data => 'No data available';

  @override
  String get dark_mode_description => 'Enable dark theme for the app';

  @override
  String get change_password => 'Change password';

  @override
  String get change_password_subtitle => 'Update your access password';

  @override
  String get about_subtitle => 'App version and developer';

  @override
  String get report_problem_subtitle => 'Send report to soporte@fishcorp.com';

  @override
  String get confirm_delete_title => 'Confirm deletion';

  @override
  String confirm_delete_message(Object name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String get confirm_change_role_title => 'Confirm role change';

  @override
  String confirm_change_role_message(Object name, Object role) {
    return 'Do you want to change the role of $name to $role?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get change_to_client => 'Change to Client';

  @override
  String get change_to_fisherman => 'Change to Fisherman';

  @override
  String get change_to_admin => 'Change to Admin';

  @override
  String get user_deleted => 'User deleted successfully';

  @override
  String role_changed(Object role) {
    return 'Role changed to $role successfully';
  }

  @override
  String get about_title => 'About FishSaleCorp';

  @override
  String get report_problem => 'Report a problem';

  @override
  String language_changed(Object lang) {
    return 'Language changed to $lang';
  }
}
