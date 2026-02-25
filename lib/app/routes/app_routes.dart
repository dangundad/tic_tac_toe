// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const HOME = _Paths.HOME;
  static const PREMIUM = _Paths.PREMIUM;
  static const GAME = _Paths.GAME;
  static const SETTINGS = _Paths.SETTINGS;
  static const HISTORY = _Paths.HISTORY;
  static const STATS = _Paths.STATS;
}

abstract class _Paths {
  static const HOME = '/home';
  static const PREMIUM = '/premium';
  static const GAME = '/game';
  static const SETTINGS = '/settings';
  static const HISTORY = '/history';
  static const STATS = '/stats';
}






