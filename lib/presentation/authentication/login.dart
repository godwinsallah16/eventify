import 'package:eventify/core/app_export.dart';
import 'package:eventify/domain/auth_services/essentials/forgot_password.dart';
import 'package:eventify/domain/auth_services/login_services/email_login.dart';

import '../../core/network/network_info.dart';
import '../../core/utils/validation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static Widget builder(BuildContext context) {
    return const LoginScreen();
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final ConnectivityService _connectivityService;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> resetKey = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    await _connectivityService.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF55CDF3),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blue[900],
              flexibleSpace: const FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 20.0),
                title: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: AppBackground(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomTextField(
                        fieldLabel: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!isValidEmail(value)) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      CustomPasswordField(
                        fieldLabel: "Password",
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _showForgetPasswordDialog,
                            child: const Text(
                              "Forgot Password?",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFFA20723),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ButtonPrimary(
                          onTap: _attemptLogin,
                          buttonText: 'Login',
                          isLoading: _isLoading,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  fontFamily: 'jost',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          "Continue with",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomIconButton(
                            onTap: () {
                              print("Google login tapped");
                            },
                            child: ImageConstant.googleIcon,
                          ),
                          CustomIconButton(
                            onTap: () {
                              print("GitHub login tapped");
                            },
                            child: ImageConstant.githubIcon,
                          ),
                          CustomIconButton(
                            onTap: () {
                              print("Facebook login tapped");
                            },
                            child: ImageConstant.facebookIcon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              NavigatorService.popAndPushNamed(
                                  AppRoutes.signupScreen);
                            },
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                color: Color(0xFF000C4E),
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _attemptLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (!_connectivityService.hasInternetConnection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Network disconnected. Please check your internet connection.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final EmailLoginService loginService = EmailLoginService();
    try {
      bool loginSuccessful = await loginService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (loginSuccessful) {
        NavigatorService.pushNamedAndRemoveUntil(AppRoutes.mainScreen);
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect email or password'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showForgetPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Forgot Password"),
          content: Form(
            key: resetKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter your email address to receive a reset link."),
                const SizedBox(height: 10),
                CustomTextField(
                  fieldLabel: "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!isValidEmail(value)) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
                TextButton(
                  onPressed: () {
                    // Validate email before sending reset link
                    if (resetKey.currentState!.validate()) {
                      _sendResetLink(emailController.text);
                    }
                  },
                  child: const Text("Confirm"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendResetLink(String email) async {
    if (!_connectivityService.hasInternetConnection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Network disconnected. Please check your internet connection.'),
        ),
      );
      return;
    }

    if (email.isEmpty || !isValidEmail(email)) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // Show a circular progress indicator
                SizedBox(width: 16),
                Text('Sending email...'), // Show a message indicating progress
              ],
            ),
          ),
        );
      },
    );

    ForgotPasswordService _forgotPasswordService = ForgotPasswordService();
    // Call the sendPasswordResetEmail method from ForgotPasswordService
    try {
      await _forgotPasswordService.sendPasswordResetEmail(email, context);
      Navigator.pop(context); // Close the dialog after sending the reset email
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent successfully.'),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close the dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending password reset email: $e'),
        ),
      );
      // Optionally, you can handle the error further
    }
  }
}
