// ignore_for_file: use_build_context_synchronously, empty_catches, unnecessary_brace_in_string_interps, prefer_adjacent_string_concatenation, unnecessary_string_interpolations

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class GuideService {
  static const _prefix = 'guia_vista_';
  static const _masterPrefix = 'guia_vista_master_';
  static const _appMasterKey = 'guia_vista_master_app';

  static Future<void> showOnce({
    required BuildContext context,
    required int userId,
    required String screenId,
    required List<GlobalKey> keys,
    Duration delay = const Duration(milliseconds: 600),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveKey = (userId > 0)
        ? '$_prefix${userId}_$screenId'
        : '$_prefix' + 'app_$screenId';
    final yaVisto = prefs.getBool(effectiveKey) ?? false;

    if (yaVisto) return;

    await Future.delayed(delay);

    try {
      if (keys.isNotEmpty) ShowCaseWidget.of(context).startShowCase(keys);
      await prefs.setBool(effectiveKey, true);
    } catch (e) {}
  }

  static Future<void> showOnFirstSignIn({
    required BuildContext context,
    required int userId,
    required List<GlobalKey> keys,
    Duration delay = const Duration(milliseconds: 600),
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String masterKey = (userId > 0)
        ? '$_masterPrefix${userId}'
        : _appMasterKey;
    final yaVistoMaster = prefs.getBool(masterKey) ?? false;

    if (yaVistoMaster) return;

    await Future.delayed(delay);

    try {
      if (keys.isNotEmpty) ShowCaseWidget.of(context).startShowCase(keys);
      await prefs.setBool(masterKey, true);
    } catch (e) {}
  }

  static Future<void> resetForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    if (userId > 0) {
      await prefs.remove('$_masterPrefix${userId}');

      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('$_prefix${userId}_'))
          .toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
    } else {
      await prefs.remove(_appMasterKey);
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith('$_prefix' + 'app_'))
          .toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
    }
  }

  static Future<bool> isMasterShown(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId > 0) return prefs.getBool('$_masterPrefix${userId}') ?? false;
    return prefs.getBool(_appMasterKey) ?? false;
  }
}
