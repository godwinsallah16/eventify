import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String fieldLabel;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputAction textInputAction; // Add text input action property
  final FocusNode? focusNode; // Add focus node property
  final Function(String)? onFieldSubmitted; // Add onFieldSubmitted callback
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.fieldLabel,
    this.hintText,
    this.controller,
    this.textInputAction = TextInputAction.done, // Default action is done
    this.focusNode,
    this.onFieldSubmitted,
    this.validator,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? _errorText;

  @override
  Widget build(BuildContext context) {
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
                child: TextFormField(
                  controller: widget.controller,
                  textInputAction: widget.textInputAction,
                  keyboardType: widget.keyboardType,
                  focusNode: widget.focusNode,
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
                    hintText: widget.hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.grey,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        style: BorderStyle.solid,
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'jost',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: 4.0), // Space between TextFormField and error message
              SizedBox(
                height: _errorText != null
                    ? 20.0
                    : 0, // Fixed height for error message
                child: _errorText != null
                    ? Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
