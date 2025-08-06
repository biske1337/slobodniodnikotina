import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  final DateTime quitDate;
  final TimeOfDay quitTime;
  final double dailyAmount;
  final String currency;

  const ProgressScreen({
    super.key,
    required this.quitDate,
    required this.quitTime,
    required this.dailyAmount,
    required this.currency,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Duration _timeSinceQuit;
  late double _moneySaved;
  late DateTime _quitDateTime;
  late Timer _timer;
  bool _showTerms = false;

  final List<String> bosnianMonths = [
    'Januar',
    'Februar',
    'Mart',
    'April',
    'Maj',
    'Juni',
    'Juli',
    'Avgust',
    'Septembar',
    'Oktobar',
    'Novembar',
    'Decembar',
  ];

  @override
  void initState() {
    super.initState();
    _quitDateTime = DateTime(
      widget.quitDate.year,
      widget.quitDate.month,
      widget.quitDate.day,
      widget.quitTime.hour,
      widget.quitTime.minute,
    );
    _updateValues();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateValues(),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateValues() {
    final now = DateTime.now();
    setState(() {
      _timeSinceQuit = now.difference(_quitDateTime);
      _moneySaved = _calculateMoneySaved();
    });
  }

  double _calculateMoneySaved() {
    return widget.dailyAmount * _timeSinceQuit.inDays;
  }

  String _formatQuitDate() {
    final day = _quitDateTime.day;
    final month = bosnianMonths[_quitDateTime.month - 1];
    final year = _quitDateTime.year;
    final hour = _quitDateTime.hour.toString().padLeft(2, '0');
    final minute = _quitDateTime.minute.toString().padLeft(2, '0');

    return '$day. $month $year. u $hour:$minute';
  }

  void _toggleTerms() {
    setState(() {
      _showTerms = !_showTerms;
    });
  }

  List<Achievement> _getAchievements() {
    return [
      Achievement(
        title: "Krvni pritisak i puls se vraćaju na normalne vrijednosti",
        time: "20 minuta",
        achieved: _timeSinceQuit.inMinutes >= 20,
        image: _timeSinceQuit.inMinutes >= 20
            ? 'slike/colorheart.png'
            : 'slike/mdi_heart.png',
      ),
      Achievement(
        title: "Nivo ugljenmonoksida u krvi opada i kisik se bolje prenosi",
        time: "24 sata",
        achieved: _timeSinceQuit.inHours >= 24,
        image: _timeSinceQuit.inHours >= 24
            ? 'slike/colorlungs.png'
            : 'slike/mdi_lungs.png',
      ),
      Achievement(
        title: "Prošli ste kroz vrhunac fizičke apstinencije",
        time: "3 dana",
        achieved: _timeSinceQuit.inDays >= 3,
        image: _timeSinceQuit.inDays >= 3
            ? 'slike/colormountain.png'
            : 'slike/mountain-gray.png',
      ),
      Achievement(
        title: "Prošla je prva sedmica bez nikotina!",
        time: "7 dana",
        achieved: _timeSinceQuit.inDays >= 7,
        image: _timeSinceQuit.inDays >= 7
            ? 'slike/color7days.png'
            : 'slike/calendar7daysgray.png',
      ),
      Achievement(
        title:
            "Sada ste u potpunosti oslobođeni i očišćeni od nikotina u organizmu!",
        time: "21 dan",
        achieved: _timeSinceQuit.inDays >= 21,
        image: _timeSinceQuit.inDays >= 21
            ? 'slike/colorptica.png'
            : 'slike/ptica-gray.png',
      ),
      Achievement(
        title:
            "Dokazali ste sebi u svim mjesečnim situacijama da ste slobodni!",
        time: "30 dana",
        achieved: _timeSinceQuit.inDays >= 30,
        image: _timeSinceQuit.inDays >= 30
            ? 'slike/color30days.png'
            : 'slike/calendar30daysgray.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();
    final formattedDate = _formatQuitDate();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  Text(
                    'Slobodni ste već:',
                    style: TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontSize: 18,
                      color: const Color(0xFF676767),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_timeSinceQuit.inDays > 0)
                        _buildTimeUnit(_timeSinceQuit.inDays, 'dana'),
                      if (_timeSinceQuit.inHours % 24 > 0)
                        _buildTimeUnit(_timeSinceQuit.inHours % 24, 'sati'),
                      if (_timeSinceQuit.inMinutes % 60 > 0)
                        _buildTimeUnit(_timeSinceQuit.inMinutes % 60, 'minuta'),
                      if (_timeSinceQuit.inSeconds % 60 > 0)
                        _buildTimeUnit(
                          _timeSinceQuit.inSeconds % 60,
                          'sekundi',
                        ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A6CD6),
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: Text(
                      formattedDate,
                      style: const TextStyle(
                        fontFamily: 'Rethink Sans',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 340,
                    height: 125,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E9FB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              NumberFormat.currency(
                                symbol: '',
                                decimalDigits: 2,
                              ).format(_moneySaved),
                              style: TextStyle(
                                fontFamily: 'Rethink Sans',
                                fontSize: 34,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9A6CD6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.currency,
                              style: TextStyle(
                                fontFamily: 'Rethink Sans',
                                fontSize: 18,
                                color: const Color(0xFF676767),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ušteđeno do sad',
                          style: TextStyle(
                            fontFamily: 'Rethink Sans',
                            fontSize: 16,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Dostignuća od posljednje doze',
                    style: TextStyle(
                      fontFamily: 'Rethink Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 312,
                    margin: const EdgeInsets.only(top: 24, bottom: 40),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: achievements.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        return _buildAchievementItem(achievements[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TOS ikonica
          Positioned(
            left: 10,
            top: 31,
            child: GestureDetector(
              onTap: _toggleTerms,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Center(
                  child: Icon(
                    Icons.info_outline,
                    size: 24,
                    color: Color(0xFF666666),
                  ),
                ),
              ),
            ),
          ),

          // TOS pop up
          if (_showTerms)
            Positioned.fill(
              child: Container(
                color: const Color(0x80000000),

                child: Center(
                  child: Container(
                    width: 312,
                    height: MediaQuery.of(context).size.height * 0.8,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Uslovi korištenja',
                            style: TextStyle(
                              fontFamily: 'Rethink Sans',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Dobrodošli u aplikaciju Slobodni od Nikotina. Korištenjem ove aplikacije, prihvatate sljedeće uslove:\n\n'
                            'Svrha aplikacije\n'
                            'Ova aplikacija je dodatni alat koji korisnicima pomaže da ostanu nepušači nakon što su prošli edukativni program "Slobodni od Nikotina". Aplikacija ne predstavlja medicinsku terapiju.\n\n'
                            'Nema medicinskih savjeta\n'
                            'Sav sadržaj, podaci i funkcionalnosti u ovoj aplikaciji služe isključivo u edukativne i motivacione svrhe. Ova aplikacija ne pruža medicinske savjete. Za bilo kakve zdravstvene probleme, obratite se svom ljekaru ili drugom kvalifikovanom zdravstvenom radniku.\n\n'
                            'Lična odgovornost korisnika\n'
                            'Korištenjem aplikacije prihvatate da sve što radite na osnovu sadržaja aplikacije činite isključivo na vlastitu odgovornost. Tvorac aplikacije ne snosi odgovornost za bilo kakve posljedice, štetu ili gubitke koji mogu nastati kao rezultat korištenja aplikacije.\n\n'
                            'Ograničenje upotrebe\n'
                            'Nije dozvoljeno koristiti aplikaciju na način koji krši zakon ili pokušava da ometa rad aplikacije. Zabranjeno je bilo kakvo kopiranje, distribucija ili komercijalno iskorištavanje bez dozvole autora.\n\n'
                            'Privatnost i podaci\n'
                            'Aplikacija može prikupljati određene anonimne podatke (npr. datum kada ste prestali pušiti i cijena kutije) isključivo u svrhu praćenja vašeg napretka. Ti podaci se ne dijele s trećim stranama.\n\n'
                            'Promjene uslova\n'
                            'Autor zadržava pravo da povremeno izmijeni ove uslove. O svakoj promjeni korisnici će biti obaviješteni putem aplikacije.\n\n'
                            'Ako se ne slažete s ovim uslovima, nemojte koristiti aplikaciju. Nastavkom korištenja se smatra da ste ove uslove pročitali i da ih prihvatate.',
                            style: TextStyle(
                              fontFamily: 'Rethink Sans',
                              fontSize: 16,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _toggleTerms,
                            child: const Text(
                              'Zatvori',
                              style: TextStyle(
                                fontFamily: 'Rethink Sans',
                                fontSize: 16,
                                color: Color(0xFF9A6CD6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.copyright,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Vlasnik i dizajner: Danis Okić\nDeveloper: Ahmed Ibišević',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Rethink Sans',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String unit) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Rethink Sans',
              fontSize: 34,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontFamily: 'Rethink Sans',
              fontSize: 12,
              color: const Color(0xFF676767),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Column(
      children: [
        _buildAchievementImage(achievement.image),
        const SizedBox(height: 12),
        Text(
          achievement.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Rethink Sans',
            fontSize: 16,
            color: achievement.achieved
                ? Colors.black
                : const Color(0xFF676767),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: achievement.achieved
                ? const Color(0xFF9A6CD6)
                : const Color(0xFF949494),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            achievement.time,
            style: const TextStyle(
              fontFamily: 'Rethink Sans',
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementImage(String imagePath) {
    return Image.asset(
      imagePath,
      width: 41,
      height: 41,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 41,
          height: 41,
          color: Colors.grey[200],
          child: const Icon(Icons.image, size: 24),
        );
      },
    );
  }
}

class Achievement {
  final String title;
  final String time;
  final bool achieved;
  final String image;

  Achievement({
    required this.title,
    required this.time,
    required this.achieved,
    required this.image,
  });
}
