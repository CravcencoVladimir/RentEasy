import '../core/result.dart';
import '../models/listing.dart';

abstract class ListingRepository {
  Future<Result<List<Listing>>> getListings();
  Future<Result<Listing>> getListingById(String id);
  Future<Result<Listing>> createListing(Listing listing);
  Future<Result<void>> deleteListing(String id);
  Future<Result<Listing>> updateListing(Listing listing);
}
