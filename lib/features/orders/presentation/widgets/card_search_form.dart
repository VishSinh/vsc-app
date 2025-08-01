import 'package:flutter/material.dart';
import 'package:vsc_app/app/app_config.dart';
import 'package:vsc_app/core/constants/ui_text_constants.dart';
import 'package:vsc_app/core/widgets/button_utils.dart';

/// Widget for searching cards by barcode
class CardSearchForm extends StatefulWidget {
  final VoidCallback onSearch;
  final bool isLoading;

  const CardSearchForm({super.key, required this.onSearch, this.isLoading = false});

  @override
  State<CardSearchForm> createState() => _CardSearchFormState();
}

class _CardSearchFormState extends State<CardSearchForm> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConfig.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: UITextConstants.barcode,
                  hintText: UITextConstants.barcodeHint,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return UITextConstants.pleaseEnterBarcode;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppConfig.defaultPadding),
              ButtonUtils.primaryButton(onPressed: widget.isLoading ? null : widget.onSearch, label: 'Search Card', icon: Icons.search),
            ],
          ),
        ),
      ),
    );
  }

  String get barcode => _barcodeController.text.trim();
  bool get isValid => _formKey.currentState?.validate() ?? false;

  void clear() {
    _barcodeController.clear();
    _formKey.currentState?.reset();
  }
}
