import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/src/core/extensions/integer_sizedbox_extension.dart';
import 'package:frontend/src/routes/app_route_path.dart';
import 'package:frontend/src/widgets/custom_button.dart';
import 'package:frontend/src/core/l10n/l10n.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(BuildContext context) {
    final l10n = context.l10n;
    return [
      OnboardingData(
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDesc,
        image: 'assets/images/anh1.png',
      ),
      OnboardingData(
        title: l10n.onboardingConnectTitle,
        description: l10n.onboardingConnectDesc,
        image: 'assets/images/anh2.png',
      ),
      OnboardingData(
        title: l10n.onboardingShareTitle,
        description: l10n.onboardingShareDesc,
        image: 'assets/images/anh3.png',
      ),
      OnboardingData(
        title: l10n.onboardingChatTitle,
        description: l10n.onboardingChatDesc,
        image: 'assets/images/anh4.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingContent(data: pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  32.hS,
                  CustomButton(
                    label: _currentPage == pages.length - 1
                        ? l10n.onboardingStart
                        : l10n.onboardingNext,
                    color: const Color(0xFF3CC18E),
                    onPressed: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go(AppRoutes.welcome.path);
                      }
                    },
                  ),
                  12.hS,
                  if (_currentPage < pages.length - 1)
                    TextButton(
                      onPressed: () => context.go(AppRoutes.welcome.path),
                      child: Text(
                        l10n.onboardingSkip,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    12.hS, // Khoảng trống cho cân đối
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF3CC18E)
            : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}

class OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(data.image, height: 300, fit: BoxFit.contain),
          ),
          40.hS,
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          16.hS,
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
