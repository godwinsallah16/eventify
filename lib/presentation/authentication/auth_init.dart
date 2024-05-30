import 'package:eventify/core/app_export.dart';

class AuthInit extends StatelessWidget {
  const AuthInit({super.key});

  static Widget builder(BuildContext context) {
    return const AuthInit();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          const AppBackground(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome",
                      style: TextStyle(
                          fontSize: 70,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontFamily: 'jost'),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Text(
                      "To Eventify",
                      style: TextStyle(
                          fontSize: 34,
                          color: Colors.black,
                          fontFamily: 'jost',
                          decoration: TextDecoration.none),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonPrimary(
                      buttonText: " Login ",
                      onTap: () {
                        NavigatorService.pushNamed(AppRoutes.loginScreen);
                      },
                    ),
                    ButtonSecondary(
                        buttonText: "Sign up",
                        onTap: () {
                          NavigatorService.pushNamed(AppRoutes.signupScreen);
                        }),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
