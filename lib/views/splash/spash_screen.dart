import 'package:appariteur/controllers/loginController/childlogin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageContent() {
    return [
      _buildPage(
        imagePath: 'assets/images/splash 1.png',
        text: 'Devenez rapidement et facilement surveillant. Et gagnez de l\'argent en travaillant avec nous!',
      ),
      _buildPage(
        imagePath: 'assets/images/splash 2.png',
        text: 'Suivez vos horaires de travail, Et décidez de quand vous travaillez.',
        showButton: true,
      ),
    ];
  }

  Future<void> _setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }

  void _onFinish() async {
    await _setOnboardingSeen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  Widget _buildPageIndicator(bool isCurrentPage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: isCurrentPage ? 10.0 : 8.0,
      width: isCurrentPage ? 10.0 : 8.0,
      decoration: BoxDecoration(
        color: isCurrentPage ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildPage({required String imagePath, required String text, bool showButton = false}) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(_w * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: _w * 0.8),
          SizedBox(height: _h * 0.02),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: _w * 0.045,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (showButton) ...[
            SizedBox(height: _h * 0.04),
            ElevatedButton(
              onPressed: _onFinish,
              child: Text(
                'Commencer',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: _w * 0.1, vertical: _h * 0.02),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _buildPageContent(),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _buildPageContent().length,
                    (int index) => _buildPageIndicator(index == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
