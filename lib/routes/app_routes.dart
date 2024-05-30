import 'package:eventify/core/app_export.dart';
import 'package:eventify/presentation/post_event.dart';
import 'package:eventify/presentation/splash_screen.dart';

class AppRoutes {
  static const String authInitScreen = '/authInitScreen';
  static const String eventForm = '/eventForm';
  static const String initialRoute = '/initialRoute';
  static const String loginScreen = '/loginScreen';
  static const String mainScreen = '/mainScreen';
  static const String otpVerificationScreen = '/otp_verification';
  static const String signupScreen = '/signupScreen';

  static Map<String, WidgetBuilder> get routes => {
        authInitScreen: (context) => const AuthInit(),
        eventForm: (context) => const EventForm(),
        initialRoute: (context) => const SplashScreen(),
        loginScreen: (context) => const LoginScreen(),
        mainScreen: (context) => const MainScreen(),
        signupScreen: (context) => const SignUpScreen(),
      };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case otpVerificationScreen:
        final List arguments = settings.arguments as List<dynamic>;
        return MaterialPageRoute(
          builder: (_) => OTPVerification(
            email: arguments[0],
            password: arguments[1],
            userInfo: arguments[2],
          ),
        );
      default:
        return null;
    }
  }
}
