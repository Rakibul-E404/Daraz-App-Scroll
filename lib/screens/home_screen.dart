import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../controller/home_controller.dart';
import '../controller/products_controller.dart';
import '../models/product.dart';
import '../widgets/home/daraz_app_bar.dart';
import '../widgets/home/tab_bar_delegate.dart';
import '../widgets/home/tab_body.dart';

const List<String> kTabLabels = ['All', 'Electronics', 'Jewelery', 'Clothing'];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final products = Get.find<ProductsController>();
    final home = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            Obx(
              () => DarazAppBar(
                user: auth.user.value,
                innerBoxIsScrolled: innerBoxIsScrolled,
              ),
            ),
            Obx(
              () => SliverPersistentHeader(
                pinned: true,
                delegate: TabBarDelegate(
                  currentTab: home.currentTab.value,
                  tabLabels: kTabLabels,
                  onTabSelected: home.switchTab,
                ),
              ),
            ),
          ],
          // Obx here so the whole PageView reacts to ANY
          // observable change — loading, error, or data
          body: Obx(() {
            final loading = products.loading.value;
            final error = products.error.value;
            final allProds = products.all;

            return _TabPageView(
              pageController: home.pageController,
              products: products,
              currentTab: home.currentTab.value,
              loading: loading,
              error: error,
              allProducts: allProds,
              onRefresh: products.refresh,
              onTabChanged: (i) => home.currentTab.value = i,
            );
          }),
        ),
      ),
    );
  }
}

class _TabPageView extends StatelessWidget {
  final PageController pageController;
  final ProductsController products;
  final int currentTab;
  final bool loading;
  final String? error;
  final List<Product> allProducts;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onTabChanged;

  const _TabPageView({
    required this.pageController,
    required this.products,
    required this.currentTab,
    required this.loading,
    required this.error,
    required this.allProducts,
    required this.onRefresh,
    required this.onTabChanged,
  });

  List<Product> _productsForTab(int tab) {
    switch (tab) {
      case 0:
        return products.all;
      case 1:
        return products.electronics;
      case 2:
        return products.jewelery;
      case 3:
        return [...products.menClothing, ...products.womenClothing];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: PageView.builder(
        controller: pageController,
        physics: const PageScrollPhysics(),
        onPageChanged: onTabChanged,
        itemCount: kTabLabels.length,
        itemBuilder: (context, index) => RepaintBoundary(
          child: TabBody(
            key: PageStorageKey('tab_$index'),
            products: _productsForTab(index),
            loading: loading,
            error: error,
            onRefresh: onRefresh,
          ),
        ),
      ),
    );
  }
}
