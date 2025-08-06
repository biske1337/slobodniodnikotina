import 'package:flutter/material.dart';
import 'screens/storage_service.dart';
import 'screens/date_selection_screen.dart';
import 'screens/time_input_screen.dart';
import 'screens/money_input_screen.dart';
import 'screens/progress_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AppContainer(), debugShowCheckedModeBanner: false);
  }
}

class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  int currentScreen = 0;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  double? dailyAmount;
  String? selectedCurrency = 'EUR';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 4));
    final savedData = await StorageService.loadUserData();

    if (savedData != null) {
      setState(() {
        selectedDate = savedData['quitDate'];
        selectedTime = savedData['quitTime'];
        dailyAmount = savedData['dailyAmount'];
        selectedCurrency = savedData['currency'];
        currentScreen = 5;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        currentScreen = 1;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && currentScreen == 1) {
          setState(() => currentScreen = 2);
        }
      });
    }
  }

  void _goBack() {
    if (currentScreen > 0 && currentScreen != 5) {
      setState(() => currentScreen--);
    }
  }

  Future<void> _saveAndContinue(double amount, String currency) async {
    if (selectedDate == null || selectedTime == null) return;

    await StorageService.saveUserData(
      quitDate: selectedDate!,
      quitTime: selectedTime!,
      dailyAmount: amount,
      currency: currency,
    );

    setState(() {
      dailyAmount = amount;
      selectedCurrency = currency;
      currentScreen = 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isLoading ? const LoadingScreen() : _getCurrentScreen(),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (currentScreen) {
      case 0:
        return const LoadingScreen();
      case 1:
        return const CongratsScreen();
      case 2:
        return DateSelectionScreen(
          onDateSelected: (date) => setState(() {
            selectedDate = date;
            currentScreen = 3;
          }),
        );
      case 3:
        return TimeInputScreen(
          onBack: _goBack,
          onContinue: (time) => setState(() {
            selectedTime = time;
            currentScreen = 4;
          }),
        );
      case 4:
        return MoneyInputScreen(onBack: _goBack, onConfirm: _saveAndContinue);
      case 5:
        return _buildProgressScreen();
      default:
        return const LoadingScreen();
    }
  }

  Widget _buildProgressScreen() {
    if (selectedDate == null || selectedTime == null || dailyAmount == null) {
      Future.microtask(() => setState(() => currentScreen = 1));
      return const LoadingScreen();
    }

    return ProgressScreen(
      quitDate: selectedDate!,
      quitTime: selectedTime!,
      dailyAmount: dailyAmount!,
      currency: selectedCurrency!,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('loading'),
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF9A6CD6),
      child: Center(
        child: Image.asset(
          'slike/pticica.png',
          width: 91,
          height: 109,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50,
            );
          },
        ),
      ),
    );
  }
}

class CongratsScreen extends StatelessWidget {
  const CongratsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxContentWidth = screenSize.width * 0.87;

    return Container(
      key: const ValueKey('congrats'),
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFFFFFFF),
      child: Center(
        child: SizedBox(
          width: maxContentWidth,
          height: 29,
          child: const Text(
            'Čestitam na prestanku pušenja!',
            style: TextStyle(
              fontFamily: 'Rethink Sans',
              fontWeight: FontWeight.w600,
              fontSize: 22,
              height: 1.3,
              color: Color(0xFF000000),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
