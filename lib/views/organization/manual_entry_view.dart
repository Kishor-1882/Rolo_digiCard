import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:rolo_digi_card/utils/color.dart';

/// Manual entry view: user enters card ID to save/view the card.
class ManualEntryView extends StatefulWidget {
  const ManualEntryView({super.key});

  @override
  State<ManualEntryView> createState() => _ManualEntryViewState();
}

class _ManualEntryViewState extends State<ManualEntryView> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  String? _extractCardId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.length >= 2 && uri.pathSegments[uri.pathSegments.length - 2] == 'c') {
      return uri.pathSegments.last;
    }
    return trimmed;
  }

  Future<void> _saveCard() async {
    final cardId = _extractCardId(_controller.text);
    if (cardId == null || cardId.length < 3) {
      CommonSnackbar.error('Please enter a valid card ID or URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await dioClient.post(ApiEndpoints.saveCard(cardId));
      if (response.statusCode == 200 || response.statusCode == 201) {
        CommonSnackbar.success('Card saved successfully!');
        Get.offAllNamed('/sidebar');
      } else {
        CommonSnackbar.error('Failed to save card');
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('own') || msg.contains('already') || msg.contains('409')) {
        CommonSnackbar.error('This is your own card or it is already saved');
      } else {
        CommonSnackbar.error('Failed to save card');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Manual Entry',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Enter card ID or URL',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: !_isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. 08YLRtN93 or https://digi.roloscan.com/c/08YLRtN93',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF1E1E2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.5)),
                        onPressed: () => _controller.clear(),
                      )
                    : null,
              ),
              onChanged: (_) {},
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E8E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
