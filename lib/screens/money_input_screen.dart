import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoneyInputScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(double, String)? onConfirm;

  const MoneyInputScreen({super.key, this.onBack, this.onConfirm});

  @override
  State<MoneyInputScreen> createState() => _MoneyInputScreenState();
}

class _MoneyInputScreenState extends State<MoneyInputScreen> {
  final TextEditingController moneyController = TextEditingController();
  final FocusNode moneyFocusNode = FocusNode();
  String selectedCurrency = 'EUR';
  bool _isSaving = false;

  bool get isFormValid => moneyController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    moneyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    moneyController.dispose();
    moneyFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    // Skloni tastaturu
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).unfocus();

    if (!isFormValid || widget.onConfirm == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final amountText = moneyController.text.replaceAll(',', '.');
      final amount = double.tryParse(amountText);

      if (amount == null) {
        throw FormatException('Invalid money format');
      }

      debugPrint('💰 Confirm pressed: $amount $selectedCurrency');
      await widget.onConfirm!(amount, selectedCurrency);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving amount: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final maxContentWidth = screenWidth * 0.87;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          moneyFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                // Nazad
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: screenWidth * 0.067, top: 20),
                  child: GestureDetector(
                    onTap: widget.onBack,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Naslov
                Container(
                  width: maxContentWidth,
                  margin: EdgeInsets.only(top: mediaQuery.size.height * 0.08),
                  child: const Text(
                    'Vaša konzumacija nikotina',
                    style: TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      height: 1.3,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Podnaslov
                Container(
                  width: maxContentWidth,
                  margin: EdgeInsets.only(top: mediaQuery.size.height * 0.08),
                  child: const Text(
                    'Koliko novca dnevno ste trošili na nikotin?',
                    style: TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.3,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Pare input
                Container(
                  width: maxContentWidth,
                  height: 44,
                  margin: const EdgeInsets.only(top: 33),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: moneyFocusNode.hasFocus
                          ? const Color(0xFF9A6CD6)
                          : const Color(0xFF949494),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: moneyController,
                    focusNode: moneyFocusNode,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.3,
                      color: Color(0xFF676767),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '5.80',
                      hintStyle: const TextStyle(
                        fontFamily: 'Rethink Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.3,
                        color: Color(0xFFA8A8A8),
                      ),
                    ),
                  ),
                ),

                // Selekcija
                const Padding(
                  padding: EdgeInsets.only(top: 33, bottom: 12),
                  child: Text(
                    'Vaša valuta:',
                    style: TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.3,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Valuta
                SizedBox(
                  width: maxContentWidth,
                  child: Row(
                    children: [
                      _buildCurrencyButton('EUR'),
                      const SizedBox(width: 12),
                      _buildCurrencyButton('BAM'),
                      const SizedBox(width: 12),
                      _buildCurrencyButton('RSD'),
                    ],
                  ),
                ),

                const Spacer(),

                // Potvrda
                Container(
                  width: maxContentWidth,
                  height: 50,
                  margin: EdgeInsets.only(
                    bottom: mediaQuery.size.height * 0.08,
                  ),
                  child: TextButton(
                    onPressed: (_isSaving || !isFormValid)
                        ? null
                        : _handleConfirm,
                    style: TextButton.styleFrom(
                      backgroundColor: (_isSaving || !isFormValid)
                          ? const Color(0xFF949494)
                          : const Color(0xFF9A6CD6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Potvrdi',
                            style: TextStyle(
                              fontFamily: 'Rethink Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyButton(String currency) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedCurrency = currency),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedCurrency == currency
                  ? const Color(0xFF9A6CD6)
                  : const Color(0xFF949494),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              currency,
              style: const TextStyle(
                fontFamily: 'Rethink Sans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
