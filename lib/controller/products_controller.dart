import 'package:get/get.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsController extends GetxController {
  final _all     = <Product>[].obs;
  final loading  = false.obs;
  final error    = RxnString();

  List<Product> get all          => _all;
  List<Product> get electronics  => _all.where((p) => p.category == 'electronics').toList();
  List<Product> get jewelery     => _all.where((p) => p.category == 'jewelery').toList();
  List<Product> get menClothing  => _all.where((p) => p.category == "men's clothing").toList();
  List<Product> get womenClothing=> _all.where((p) => p.category == "women's clothing").toList();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_all.isNotEmpty) return;
    await _fetch();
  }

  @override
  Future<void> refresh() async {
    _all.clear();
    await _fetch();
  }

  Future<void> _fetch() async {
    loading.value = true;
    error.value   = null;

    try {
      final products = await ApiService.getAllProducts();
      _all.assignAll(products);
      error.value = null;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      _all.clear();
    } finally {
      loading.value = false;
    }
  }
}