import 'package:eventify/core/app_export.dart';

import '../../core/network/network_info.dart';

export 'package:eventify/domain/cloud_services/cloud_storage.dart';
export 'package:eventify/models/userName.dart';

class OTPVerification extends StatefulWidget {
  final String email;
  final String password;
  final UserName userInfo; // Add this line

  const OTPVerification({
    super.key,
    required this.email,
    required this.password,
    required this.userInfo, // Add this line
  });

  static WidgetBuilder builder(BuildContext context) {
    return (context) {
      final List arguments =
          ModalRoute.of(context)?.settings.arguments as List<dynamic>;
      return OTPVerification(
        email: arguments[0],
        password: arguments[1],
        userInfo: arguments[2],
      );
    };
  }

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  TextEditingController? emailController;
  TextEditingController? passwordController;
  String maskedEmail = '';

  List<TextEditingController?> otpControllers = [];
  bool clearField = false;

  Timer? _timer;
  int _remainingTime = 60; // initial countdown time in seconds
  bool _canResend = false;
  bool _isResending = false; // New variable to manage loading state
  late final ConnectivityService _connectivityService;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController(text: widget.password);
    maskedEmail = MaskMail(widget.email).maskEmail(); // Masking the email
    _connectivityService = ConnectivityService();

    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _remainingTime = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  Future<void> resendOtp() async {
    setState(() {
      _isResending = true;
    });
    EmailOtpRegistrationService service = EmailOtpRegistrationService();
    bool isSent = await service.sendOtpEmail(widget.email);
    setState(() {
      _isResending = false;
    });
    startTimer();
    if (isSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new OTP has been sent to your email.'),
        ),
      );
      startTimer(); // Restart the timer
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to resend OTP. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController?.dispose();
    passwordController?.dispose();
    _timer?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            const AppBackground(),
            CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 200,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                    title: Text(
                      'OTP Verification',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Please enter the OTP sent to ',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Jost',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              maskedEmail, // Displaying masked email
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        OtpTextField(
                          handleControllers: (controllers) {
                            otpControllers = controllers;
                          },
                          numberOfFields: 6,
                          borderColor: const Color(0xFF512DA8),
                          showFieldAsBox: true,
                          clearText: clearField,
                          onSubmit: (String verificationCode) {
                            // Call _signup method with the entered OTP value
                            _signup(verificationCode);
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          verticalDirection: VerticalDirection.down,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _canResend
                                  ? 'Request new OTP.'
                                  : 'Request new OTP in $_remainingTime ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'Jost',
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _canResend && !_isResending
                                  ? resendOtp
                                  : null,
                              child: _isResending
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Resend'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signup(String otp) async {
    if (!_connectivityService.hasInternetConnection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Network disconnected. Please check your internet connection.'),
        ),
      );
      setState(() {
        _isResending = false;
      });
      return;
    }
    EmailOtpRegistrationService verify = EmailOtpRegistrationService();
    bool isVerified = await verify.verifyOtpCode(
      widget.email,
      otp,
      widget.password,
    );
    if (isVerified) {
      // Use widget.registrationDetails to access the member variable
      CloudStorageService().saveModelToDataBase(
        model: widget.userInfo,
        collectionPath: 'public/users/userInfo',
      );

      NavigatorService.pushNamedAndRemoveUntil(AppRoutes.mainScreen);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect OTP. Please try again.'),
        ),
      );
      setState(
        () {
          clearField = true;
          for (var controller in otpControllers) {
            controller?.clear();
          }
        },
      );
    }
  }
}
