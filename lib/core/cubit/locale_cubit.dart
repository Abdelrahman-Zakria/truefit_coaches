import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'persisted_locale';
  final SharedPreferences _prefs;

  LocaleCubit(this._prefs) : super(const Locale('en')) {
    _loadLocale();
  }

  void _loadLocale() {
    final String? languageCode = _prefs.getString(_localeKey);
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  void setLocale(String languageCode) {
    _prefs.setString(_localeKey, languageCode);
    emit(Locale(languageCode));
  }

  void toggleLocale() {
    final String newCode = state.languageCode == 'en' ? 'ar' : 'en';
    setLocale(newCode);
  }
}
