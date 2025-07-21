
import 'package:flutter/material.dart';
import 'package:unibus_mvp/features/onBoarding/onboarding_data.dart'; 

class OnboardingController extends ChangeNotifier {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  PageController get pageController => _pageController;
  int get currentPage => _currentPage;

  // Navega para a próxima página
  void nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      debugPrint('Onboarding finalizado!');
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners(); 
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
