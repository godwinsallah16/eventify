import 'package:eventify/core/utils/validation.dart';

import '../../core/app_export.dart';
import '../../core/network/network_info.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  static Widget builder(BuildContext context) {
    return const SignUpScreen();
  }

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final ConnectivityService _connectivityService;
  bool _isLoading = false;
  String? _passwordStrength;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  String passwordStrengthMessage = '';

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
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF55CDF3),
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.blueAccent,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.symmetric(horizontal: 20.0),
                title: Text(
                  'Sign up',
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
                        fieldLabel: "Username",
                        controller: _userNameController,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      CustomTextField(
                        fieldLabel: "Email",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: _emailFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!isValidEmail(value)) {
                            return "Invalid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      CustomPasswordField(
                        fieldLabel: "Password",
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            // Update the password strength color indicator
                            _passwordStrength = getPasswordStrength(value);
                          });
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_confirmPasswordFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (getPasswordStrength(value) == "bad") {
                            return 'Password must be at least 8 characters long!';
                          }
                          return null;
                        },
                        // Pass the password strength color indicator to the CustomPasswordField
                        passwordStrength: _passwordStrength,
                      ),
                      const SizedBox(height: 4),
                      CustomPasswordField(
                        fieldLabel: "Confirm Password",
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm password is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ButtonSecondary(
                                onTap: _startVerification,
                                buttonText: "Sign up",
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
                          "Sign up with",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomIconButton(
                            onTap: () {
                              NavigatorService.popAndPushNamed(
                                  AppRoutes.loginScreen);
                            },
                            child: ImageConstant.googleIcon,
                          ),
                          CustomIconButton(
                            onTap: () {
                              NavigatorService.popAndPushNamed(
                                  AppRoutes.loginScreen);
                            },
                            child: ImageConstant.githubIcon,
                          ),
                          CustomIconButton(
                            onTap: () {
                              NavigatorService.popAndPushNamed(
                                  AppRoutes.loginScreen);
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
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              NavigatorService.popAndPushNamed(
                                  AppRoutes.loginScreen);
                            },
                            child: const Text(
                              "Login here",
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

  void _startVerification() async {
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

    if (_userNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the fields.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Email.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_passwordStrength == "bad") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password must be at least 8 characters long.'),
              Text('Include at an uppercase or a number.'),
            ],
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    UserName registrationDetails = UserName(
      userName: _userNameController.text,
    );

    try {
      bool otpSent = await EmailOtpRegistrationService()
          .sendOtpEmail(_emailController.text);

      if (!otpSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again later.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      NavigatorService.pushNamed(
        AppRoutes.otpVerificationScreen,
        arguments: [
          _emailController.text,
          _passwordController.text,
          registrationDetails,
        ],
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
