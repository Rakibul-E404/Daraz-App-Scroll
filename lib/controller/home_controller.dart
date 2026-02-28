import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final currentTab = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(keepPage: true);
    // Listen to page changes driven by native PageView swipe
    pageController.addListener(_onPageChanged);
  }

  @override
  void onClose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.onClose();
  }

  void _onPageChanged() {
    // Keep currentTab in sync as the page animates
    // .page gives fractional position — round to nearest for tab highlight
    if (pageController.hasClients && pageController.page != null) {
      final rounded = pageController.page!.round();
      if (rounded != currentTab.value) {
        currentTab.value = rounded;
      }
    }
  }

  // Called when user taps a tab label
  void switchTab(int index) {
    if (currentTab.value == index) return;
    currentTab.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }
}