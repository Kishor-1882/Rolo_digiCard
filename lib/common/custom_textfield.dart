import 'package:flutter/material.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/utils/url_input_formatter.dart';

class CustomFormTextField extends StatefulWidget {
  final String title;
  final String hintText;
  final bool isPassword;
  final bool isImportant;
  final TextEditingController? controller;
  final String? initialValue;
  final TextInputType keyboardType;
  final String? urlPlatform;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onUnfocus;

  const CustomFormTextField({
    Key? key,
    required this.title,
    required this.hintText,
    this.isPassword = false,
    this.isImportant = false,
    this.controller,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.urlPlatform,
    this.onEditingComplete,
    this.onUnfocus,
  }) : super(key: key);

  @override
  State<CustomFormTextField> createState() => _CustomFormTextFieldState();
}

class _CustomFormTextFieldState extends State<CustomFormTextField> {
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    if (widget.onUnfocus != null) {
      _focusNode = FocusNode()..addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode != null && !_focusNode!.hasFocus) {
      widget.onUnfocus?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFD1D5DC))),
            SizedBox(width: 5),
            if (widget.isImportant)
              Text("*", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFD1D5DC))),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.gradientStart,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            focusNode: _focusNode,
            obscureText: widget.isPassword,
            onEditingComplete: widget.onEditingComplete,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.urlPlatform != null
                ? [UrlPrefixInputFormatter(prefix: urlPrefixForPlatform(widget.urlPlatform))]
                : null,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: AppColors.qrText,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }
}