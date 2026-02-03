import 'package:flutter/material.dart';
import 'package:rolo_digi_card/utils/color.dart';

class CustomFormTextField extends StatelessWidget {
  final String title;
  final String hintText;
  final bool isPassword;
  final bool isImportant;
  final TextEditingController? controller;
  final String? initialValue;

  const CustomFormTextField({
    Key? key,
    required this.title,
    required this.hintText,
    this.isPassword = false,
    this.isImportant = false,
    this.controller,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Color(0xFFD1D5DC)),),
            SizedBox(width:5),
            if(isImportant)
              Text("*",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600,color: Color(0xFFD1D5DC)),)
          ],
        ),
        SizedBox(height:10),
        Container(
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.gradientStart,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: Colors.white.withOpacity(0.10)
              )
          ),
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            obscureText: isPassword,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              isDense: true, // reduces vertical padding
              hintText: hintText,
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
