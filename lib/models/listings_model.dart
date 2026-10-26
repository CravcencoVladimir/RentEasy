import 'package:flutter/foundation.dart';
import '../core/result.dart';
import '../data/listing_repository.dart';
import 'listing.dart';

class ListingsModel extends ChangeNotifier {
  final ListingRepository _repository;

  ListingsModel(this._repository);

  List<Listing> _listings = [];
  bool _isLoading = false;
  String? _error;

  // Read-only unmodifiable getters
  List<Listing> get listings => List.unmodifiable(_listings);
  List<Listing> get favorites => List.unmodifiable(_listings.where((l) => l.isFavorite).toList());
  int get favoriteCount => _listings.where((l) => l.isFavorite).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Listing? byId(String id) {
    try {
      return _listings.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadListings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getListings();

    switch (result) {
      case Ok(:final value):
        _listings = List.from(value);
        _isLoading = false;
        _error = null;
        notifyListeners();
      case Err(:final msg):
        _error = msg;
        _isLoading = false;
        notifyListeners();
    }
  }

  Future<String?> addListing(Listing draft) async {
    final result = await _repository.createListing(draft);
    switch (result) {
      case Ok(:final value):
        _listings = [..._listings, value];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> removeListing(String id) async {
    final result = await _repository.deleteListing(id);
    switch (result) {
      case Ok():
        _listings = _listings.where((l) => l.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index != -1) {
      final item = _listings[index];
      item.isFavorite = !item.isFavorite;
      notifyListeners();
      await _repository.updateListing(item);
    }
  }
}
