/**

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _all     = [];
  bool          _loading = false;
  String?       _error;

  bool    get loading => _loading;
  String? get error   => _error;

  // ── All products across every category ──────────────────────
  List<Product> get all => List.unmodifiable(_all);

  List<Product> get electronics =>
      _all.where((p) => p.category == 'electronics').toList();

  List<Product> get jewelery =>
      _all.where((p) => p.category == 'jewelery').toList();

  List<Product> get menClothing =>
      _all.where((p) => p.category == "men's clothing").toList();

  List<Product> get womenClothing =>
      _all.where((p) => p.category == "women's clothing").toList();

  Future<void> loadProducts() async {
    if (_all.isNotEmpty) return;
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      _all = await ApiService.getAllProducts();
    } catch (e) {
      _error = e.toString();
    }

    // Safety net — getAllProducts() already returns mock on failure,
    // but if still empty force load mock directly
    if (_all.isEmpty) {
      _all = ApiService.getMockProducts();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _all = [];
    await loadProducts();
  }
}*/









import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _all     = [];
  bool          _loading = false;
  String?       _error;

  bool          get loading      => _loading;
  String?       get error        => _error;
  bool          get hasData      => _all.isNotEmpty;

  // ── Category getters ───────────────────────────────────────────
  List<Product> get all          => List.unmodifiable(_all);
  List<Product> get electronics  => _all.where((p) => p.category == 'electronics').toList();
  List<Product> get jewelery     => _all.where((p) => p.category == 'jewelery').toList();
  List<Product> get menClothing  => _all.where((p) => p.category == "men's clothing").toList();
  List<Product> get womenClothing=> _all.where((p) => p.category == "women's clothing").toList();

  // ── Load (skip if already loaded) ─────────────────────────────
  Future<void> loadProducts() async {
    if (_all.isNotEmpty) return;
    await _fetch();
  }

  // ── Refresh (force reload) ─────────────────────────────────────
  Future<void> refresh() async {
    _all = [];
    await _fetch();
  }

  // ── Internal fetch ─────────────────────────────────────────────
  Future<void> _fetch() async {
    _loading = true;
    _error   = null;
    notifyListeners();

    try {
      _all = await ApiService.getAllProducts();
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _all   = []; // keep empty so UI shows error state, not stale data
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}