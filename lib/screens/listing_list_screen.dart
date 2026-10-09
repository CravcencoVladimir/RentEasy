import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../data/mock_data.dart';
import 'listing_detail_screen.dart';

class ListingListScreen extends StatefulWidget {
  const ListingListScreen({super.key});

  @override
  State<ListingListScreen> createState() => _ListingListScreenState();
}

class _ListingListScreenState extends State<ListingListScreen> {
  List<Listing> _filteredListings = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Filter states
  String _selectedDistrict = 'Все';
  int? _selectedRooms;
  double _maxPrice = 600.0;

  final List<String> _districts = ['Все', 'Центр', 'Рышкановка', 'Ботаника', 'Буюканы', 'Чеканы'];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredListings = mockListings.where((listing) {
        final matchesSearch = listing.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            listing.description.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            listing.address.toLowerCase().contains(_searchController.text.toLowerCase());
        
        final matchesDistrict = _selectedDistrict == 'Все' || listing.district == _selectedDistrict;
        final matchesRooms = _selectedRooms == null || listing.rooms == _selectedRooms;
        final matchesPrice = listing.price <= _maxPrice;

        return matchesSearch && matchesDistrict && matchesRooms && matchesPrice;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedDistrict = 'Все';
      _selectedRooms = null;
      _maxPrice = 600.0;
      _applyFilters();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Фильтры поиска',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          _resetFilters();
                          setModalState(() {
                            _selectedDistrict = 'Все';
                            _selectedRooms = null;
                            _maxPrice = 600.0;
                          });
                        },
                        child: const Text('Сбросить'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // District Filter
                  Text('Район', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _districts.map((district) {
                      final isSelected = _selectedDistrict == district;
                      return ChoiceChip(
                        label: Text(district),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _selectedDistrict = district);
                            _applyFilters();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Rooms Filter
                  Text('Количество комнат', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3].map((roomCount) {
                      final isSelected = _selectedRooms == roomCount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('$roomCountк'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setModalState(() {
                              _selectedRooms = selected ? roomCount : null;
                            });
                            _applyFilters();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Price Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Макс. цена в месяц', style: Theme.of(context).textTheme.titleMedium),
                      Text('\$${_maxPrice.round()}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 100.0,
                    max: 600.0,
                    divisions: 10,
                    label: '\$${_maxPrice.round()}',
                    onChanged: (value) {
                      setModalState(() => _maxPrice = value);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Показать результаты', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RentEasy — Поиск Жилья'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Поиск (улица, описание...)',
                    leading: const Icon(Icons.search),
                    onChanged: (value) => _applyFilters(),
                    trailing: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterBottomSheet,
                  tooltip: 'Фильтры',
                ),
              ],
            ),
          ),

          // Active filter tags info
          if (_selectedDistrict != 'Все' || _selectedRooms != null || _maxPrice < 600.0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Text(
                    'Активные фильтры: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedDistrict != 'Все')
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Chip(
                                label: Text(_selectedDistrict),
                              ),
                            ),
                          if (_selectedRooms != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Chip(
                                label: Text('$_selectedRooms комн.'),
                              ),
                            ),
                          if (_maxPrice < 600.0)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Chip(
                                label: Text('до \$${_maxPrice.round()}'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),

          // Listings list count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            child: Row(
              children: [
                Text(
                  'Найдено объявлений: ${_filteredListings.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Main list
          Expanded(
            child: _filteredListings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.house_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Объявления не найдены',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Сбросить все фильтры'),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredListings.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final listing = _filteredListings[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ListingDetailScreen(listing: listing),
                              ),
                            );
                            // Refresh list when coming back in case favorite status changed
                            setState(() {});
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and favorite button stack
                              Stack(
                                children: [
                                  Image.network(
                                    listing.imageUrls.first,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: IconButton.filledTonal(
                                      icon: Icon(
                                        listing.isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: listing.isFavorite ? Colors.red : null,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          listing.isFavorite = !listing.isFavorite;
                                        });
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        listing.district,
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              
                              // Content padding
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            listing.title,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${listing.price.round()}/мес',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            listing.address,
                                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.king_bed, size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Комнат: ${listing.rooms}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
