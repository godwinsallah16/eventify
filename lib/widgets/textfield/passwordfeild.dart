import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final String fieldLabel;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final String? passwordStrength;

  const CustomPasswordField({
    super.key,
    required this.fieldLabel,
    this.controller,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.onChanged,
    this.passwordStrength,
    this.suffixIcon,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (widget.passwordStrength) {
      case 'empty':
        borderColor = Colors.grey; // Default color
        break;
      case 'bad':
        borderColor = Colors.red; // Bad (less than 8 characters) color
        break;
      case 'weak':
        borderColor = Colors.orange; // Weak (missing criteria) color
        break;
      case 'strong':
        borderColor = Colors.green; // Strong (meets criteria) color
        break;
      default:
        borderColor = Colors.grey; // Default color
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 21),
        Text(
          widget.fieldLabel,
          style: const TextStyle(fontSize: 21),
        ),
        const SizedBox(height: 2),
        SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 45,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextFormField(
                      controller: widget.controller,
                      obscureText: _obscureText,
                      textInputAction: widget.textInputAction,
                      focusNode: widget.focusNode,
                      onChanged: (value) {
                        setState(() {
                          _obscureText = value.isNotEmpty;
                        });
                        widget.onChanged?.call(value);
                      },
                      onFieldSubmitted: widget.onFieldSubmitted,
                      validator: (value) {
                        setState(() {
                          _errorText = widget.validator?.call(value);
                        });
                        return null; // Always return null to prevent duplicate messages
                      },
                      style: const TextStyle(fontFamily: 'jost'),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: borderColor,
                            width: 2.0,
                          ),
                        ),
                        hintStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'jost',
                        ),
                        suffixIcon: widget.suffixIcon,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 4.0,
              ), // Space between TextFormField and error message
              Column(
                children: [
                  if (_errorText != null)
                    Text(
                      _errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
