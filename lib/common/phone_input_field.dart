import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:rolo_digi_card/utils/color.dart';

/// Phone input with country picker (default US) and validation by country.
/// India 10 digits, US 10 digits, etc.
class PhoneInputField extends StatelessWidget {
  final String title;
  final bool isImportant;
  final String? countryCode;
  final ValueChanged<CountryCode> onCountryChanged;
  final TextEditingController numberController;
  final TextEditingController? extController;
  final String numberHint;
  final String extHint;

  const PhoneInputField({
    Key? key,
    required this.title,
    this.isImportant = false,
    this.countryCode = 'US',
    required this.onCountryChanged,
    required this.numberController,
    this.extController,
    this.numberHint = '5551234567',
    this.extHint = '5555',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD1D5DC),
              ),
            ),
            if (isImportant)
              Text(
                '*',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFD1D5DC),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.gradientStart,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: CountryCodePicker(
                onChanged: onCountryChanged,
                initialSelection: countryCode ?? 'US',
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                favorite: ['+1', 'US', '+91', 'IN'],
                showFlag: true,
                showFlagMain: true,
                showFlagDialog: true,
                alignLeft: false,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.gradientStart,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: numberHint,
                    hintStyle: const TextStyle(
                      color: AppColors.qrText,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                  ),
                ),
              ),
            ),
            if (extController != null) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 70,
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: TextFormField(
                    controller: extController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: extHint,
                      hintStyle: const TextStyle(
                        color: AppColors.qrText,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Validates phone number using phone_numbers_parser.
String? validatePhoneNumber(String number, String countryCode) {
  if (number.trim().isEmpty) return null;
  try {
    final isoCode = IsoCode.values.firstWhere(
      (e) => e.name == countryCode,
      orElse: () => IsoCode.US,
    );
    final phone = PhoneNumber.parse(
      number.trim(),
      destinationCountry: isoCode,
    );
    if (!phone.isValid()) {
      return 'Enter a valid phone number for ${isoCode.name}';
    }
  } catch (e) {
    return 'Enter a valid phone number';
  }
  return null;
}
