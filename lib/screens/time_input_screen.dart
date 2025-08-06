import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Function(TimeOfDay)? onContinue;

  const TimeInputScreen({super.key, this.onBack, this.onContinue});

  @override
  State<TimeInputScreen> createState() => _TimeInputScreenState();
}

class _TimeInputScreenState extends State<TimeInputScreen> {
  final TextEditingController hourController = TextEditingController();
  final TextEditingController minuteController = TextEditingController();
  final FocusNode hourFocusNode = FocusNode();
  final FocusNode minuteFocusNode = FocusNode();

  bool get isFormValid {
    if (hourController.text.isEmpty || minuteController.text.isEmpty) {
      return false;
    }
    int? hour = int.tryParse(hourController.text);
    int? minute = int.tryParse(minuteController.text);
    return hour != null &&
        minute != null &&
        hour >= 0 &&
        hour <= 23 &&
        minute >= 0 &&
        minute <= 59;
  }

  @override
  void initState() {
    super.initState();
    hourController.addListener(() => setState(() {}));
    minuteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    hourController.dispose();
    minuteController.dispose();
    hourFocusNode.dispose();
    minuteFocusNode.dispose();
    super.dispose();
  }

  void _onHourChanged(String value) {
    if (value.length == 2) minuteFocusNode.requestFocus();
  }

  void _handleContinue() async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 300));

    if (widget.onContinue != null) {
      widget.onContinue!(
        TimeOfDay(
          hour: int.parse(hourController.text),
          minute: int.parse(minuteController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxContentWidth = screenSize.width * 0.87;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          key: const ValueKey('timeInput'),
          width: screenSize.width,
          height: screenSize.height,
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: screenSize.width * 0.067,
                    top: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: widget.onBack,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: maxContentWidth,
                  margin: EdgeInsets.only(top: screenSize.height * 0.125),
                  child: const Text(
                    'U koliko sati ste završili sa posljednjom dozom nikotina?',
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
                Container(
                  margin: EdgeInsets.only(top: screenSize.height * 0.094),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: hourFocusNode.hasFocus
                                ? const Color(0xFF9A6CD6)
                                : const Color(0xFF949494),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: TextField(
                            controller: hourController,
                            focusNode: hourFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            onChanged: _onHourChanged,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                if (newValue.text.isEmpty) return newValue;
                                int? value = int.tryParse(newValue.text);
                                return (value != null &&
                                        value >= 0 &&
                                        value <= 23)
                                    ? newValue
                                    : oldValue;
                              }),
                            ],
                            style: const TextStyle(
                              fontFamily: 'Rethink Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              height: 1.3,
                              color: Color(0xFF676767),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              hintText: '20',
                              hintStyle: const TextStyle(
                                fontFamily: 'Rethink Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1.3,
                                color: Color(
                                  0xFFA8A8A8,
                                ), // Replaced withOpacity with a lighter color
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: const Text(
                          ':',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: minuteFocusNode.hasFocus
                                ? const Color(0xFF9A6CD6)
                                : const Color(0xFF949494),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: TextField(
                            controller: minuteController,
                            focusNode: minuteFocusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                if (newValue.text.isEmpty) return newValue;
                                int? value = int.tryParse(newValue.text);
                                return (value != null &&
                                        value >= 0 &&
                                        value <= 59)
                                    ? newValue
                                    : oldValue;
                              }),
                            ],
                            style: const TextStyle(
                              fontFamily: 'Rethink Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              height: 1.3,
                              color: Color(0xFF676767),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              hintText: '18',
                              hintStyle: const TextStyle(
                                fontFamily: 'Rethink Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                height: 1.3,
                                color: Color(0xFFA8A8A8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: maxContentWidth,
                  margin: EdgeInsets.only(bottom: screenSize.height * 0.08),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: isFormValid ? _handleContinue : null,
                          style: TextButton.styleFrom(
                            backgroundColor: isFormValid
                                ? const Color(0xFF9A6CD6)
                                : const Color(0xFF949494),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Nastavi',
                            style: TextStyle(
                              fontFamily: 'Rethink Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1.3,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
