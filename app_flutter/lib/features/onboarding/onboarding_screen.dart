import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../settings/github_settings_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: "Client Radar OS",
      description: "Votre radar privé et autonome pour détecter des clients freelance sur internet.",
      icon: "📡",
    ),
    OnboardingSlide(
      title: "100% Sans Serveur",
      description: "Pas de base de données payante. Vos données transitent par votre dépôt GitHub Privé et s'exécutent via GitHub Actions.",
      icon: "🛡️",
    ),
    OnboardingSlide(
      title: "Qualification IA & Score",
      description: "Chaque piste de client est analysée en détail : type de service, budget, niveau d'urgence, score de risque et température.",
      icon: "🎯",
    ),
    OnboardingSlide(
      title: "Landing Pages & Réponses",
      description: "Pour chaque client qualifié, le système prépare une réponse sur mesure et génère une page d'offre portfolio prête à publier.",
      icon: "⚡",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: const Text("Passer", style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slide.icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          textAlign: Center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: Center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppTheme.primaryColor : const Color(0xFF232D4F),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _skipOnboarding();
                    }
                  },
                  child: Text(_currentPage == _slides.length - 1 ? "Configurer GitHub" : "Suivant"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _skipOnboarding() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GithubSettingsScreen()),
    );
    
    if (result == true && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final String icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}
