abstract class AppRoutes {
  //1 priv constructor to avoid instantiation which is redundant
  AppRoutes._();

  //var

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/notes';
  static const String editNote = '/edit-note';

  //first screen of app
  static const String initial = splash;
}
