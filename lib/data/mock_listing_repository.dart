import '../core/result.dart';
import '../models/listing.dart';
import 'listing_repository.dart';
import 'mock_data.dart';

class MockListingRepository implements ListingRepository {
  final List<Listing> _items = List.from(mockListings);
  bool simulateError = false;

  @override
  Future<Result<List<Listing>>> getListings() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (simulateError) {
      return const Err('Ошибка сети. Проверьте подключение и повторите попытку.');
    }
    return Ok(List.unmodifiable(_items));
  }

  @override
  Future<Result<Listing>> getListingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (simulateError) {
      return const Err('Ошибка загрузки данных. Сеть недоступна.');
    }
    try {
      final listing = _items.firstWhere((item) => item.id == id);
      return Ok(listing);
    } catch (_) {
      return const Err('Объявление не найдено');
    }
  }

  @override
  Future<Result<Listing>> createListing(Listing listing) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (simulateError) {
      return const Err('Не удалось сохранить объявление. Сбой соединения.');
    }
    final newListing = Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: listing.ownerId,
      title: listing.title,
      address: listing.address,
      price: listing.price,
      rooms: listing.rooms,
      imageUrls: listing.imageUrls,
      district: listing.district,
      description: listing.description,
      isFavorite: listing.isFavorite,
    );
    _items.add(newListing);
    return Ok(newListing);
  }

  @override
  Future<Result<void>> deleteListing(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (simulateError) {
      return const Err('Не удалось удалить объявление. Ошибка сети.');
    }
    _items.removeWhere((item) => item.id == id);
    return const Ok(null);
  }

  @override
  Future<Result<Listing>> updateListing(Listing listing) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (simulateError) {
      return const Err('Не удалось обновить объявление.');
    }
    final index = _items.indexWhere((item) => item.id == listing.id);
    if (index != -1) {
      _items[index] = listing;
      return Ok(listing);
    }
    return const Err('Объявление не найдено для обновления');
  }
}
