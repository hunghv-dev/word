import 'package:base_ui/base_ui.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class SharedPreferencesServices {
  @preResolve
  Future<SharedPreferences> get pref => SharedPreferences.getInstance();
}

@module
abstract class ThemeCubitServices {
  ThemeCubit theme(SharedPreferences pref) => ThemeCubit(pref);
}
