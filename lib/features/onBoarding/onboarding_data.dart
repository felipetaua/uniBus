class OnboardingContent {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;

  OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}

List<OnboardingContent> onboardingPages = [
  OnboardingContent(
    imagePath: 'assets/images/onBoarding-1.png',
    title: 'Otimizando o transporte até a sua Universidade!',
    description:
        'Chega de atrasos, listas confusas e grupos de WhatsApp desorganizados. Com o Unibus, você confirma sua presença com 1 clique e acompanha tudo em tempo real.',
    buttonText: 'Descubra',
  ),
  OnboardingContent(
    imagePath: 'assets/images/onBoarding-2.png',
    title: 'Organizadores também fazem parte dessa mudança!',
    description:
        'Visualize listas de presença, otimize rotas e reduza o tempo de espera dos estudantes — tudo no mesmo app.',
    buttonText: 'Participe',
  ),
  OnboardingContent(
    imagePath: 'assets/images/onBoarding-3.png',
    title: 'Mais organização. Mais liberdade. Mais presença.',
    description:
        'Unibus conecta você ao seu trajeto de forma simples, inclusiva e inteligente. Comece agora e transforme sua rotina de ir à faculdade.',
    buttonText: 'Começar',
  ),
];
