import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages In-App Purchases and Pro Status reactively across the entire application.
class PurchaseNotifier extends ChangeNotifier {
  static final PurchaseNotifier instance = PurchaseNotifier._();
  PurchaseNotifier._();

  /// Standard Non-Consumable product ID for removing ads and unlocking Pro features.
  /// Configure this exact ID in Google Play Console (In-app products) and App Store Connect.
  static const String proProductId = 'hymn_book_pro_lifetime';
  static const Set<String> _productIds = {proProductId};
  static const String _prefKeyIsPro = 'is_pro_user';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPro = false;
  bool _isStoreAvailable = false;
  bool _isLoading = false;
  ProductDetails? _proProduct;
  String? _errorMessage;

  bool get isPro => _isPro;
  bool get isStoreAvailable => _isStoreAvailable;
  bool get isLoading => _isLoading;
  ProductDetails? get proProduct => _proProduct;
  String? get errorMessage => _errorMessage;

  /// Human-friendly localized price (e.g. "$2.99" or "₦2,500"), with a fallback if offline.
  String get formattedPrice => _proProduct?.price ?? "Check Store";

  /// Initializes the store connection, restores cached pro status, and queries products.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_prefKeyIsPro) ?? false;
    notifyListeners();

    // Listen to background purchase updates from Play Store / App Store
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        debugPrint("IAP Stream error: $error");
        _errorMessage = error.toString();
        notifyListeners();
      },
    );

    try {
      _isStoreAvailable = await _iap.isAvailable();
      if (_isStoreAvailable) {
        final ProductDetailsResponse response =
            await _iap.queryProductDetails(_productIds);

        if (response.notFoundIDs.isNotEmpty) {
          debugPrint("IAP Products not found in store: ${response.notFoundIDs}");
        }

        if (response.productDetails.isNotEmpty) {
          _proProduct = response.productDetails.firstWhere(
            (p) => p.id == proProductId,
            orElse: () => response.productDetails.first,
          );
        }
      }
    } catch (e) {
      debugPrint("IAP initialization error: $e");
    }

    notifyListeners();
  }

  /// Initiates non-consumable purchase of the Pro tier.
  Future<bool> buyPro() async {
    if (!_isStoreAvailable || _proProduct == null) {
      _errorMessage = "Store is currently unavailable. Please check your internet or Play Store login.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _proProduct!);
    try {
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      if (!success) {
        _isLoading = false;
        _errorMessage = "Failed to launch purchase flow.";
        notifyListeners();
      }
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Restores previous purchases (required by Google Play & Apple App Store).
  Future<void> restorePurchases() async {
    if (!_isStoreAvailable) {
      _errorMessage = "Store is not available to restore purchases.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _iap.restorePurchases();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Internal handler for purchase stream events.
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.productID == proProductId) {
        switch (purchase.status) {
          case PurchaseStatus.pending:
            _isLoading = true;
            notifyListeners();
            break;

          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            await _setProStatus(true);
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
            break;

          case PurchaseStatus.error:
            _isLoading = false;
            _errorMessage = purchase.error?.message ?? "An error occurred during purchase.";
            notifyListeners();
            break;

          case PurchaseStatus.canceled:
            _isLoading = false;
            notifyListeners();
            break;
        }
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          debugPrint("Failed to complete purchase: $e");
        }
      }
    }
  }

  /// Persists and updates Pro status locally.
  Future<void> _setProStatus(bool pro) async {
    _isPro = pro;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsPro, pro);
    notifyListeners();
  }

  /// For testing/debug: allows toggling pro status locally during development
  Future<void> debugSetPro(bool pro) async {
    if (kDebugMode) {
      await _setProStatus(pro);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
