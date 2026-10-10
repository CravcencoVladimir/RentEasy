import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'listing_detail_screen.dart';
import 'add_edit_listing_screen.dart';

class MyListingsAndViewingsScreen extends StatelessWidget {
  const MyListingsAndViewingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Моя активность'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.house), text: 'Мои объявления'),
              Tab(icon: Icon(Icons.event_available), text: 'Мои просмотры'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: My Listings
            _buildMyListingsTab(context),
            // Tab 2: My Viewings
            _buildMyViewingsTab(context),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditListingScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Подать объявление'),
        ),
      ),
    );
  }

  Widget _buildMyListingsTab(BuildContext context) {
    // Just grab first 2 mock listings as "Mine" for static demonstration
    final myMockListings = mockListings.take(2).toList();
    
    return ListView.builder(
      itemCount: myMockListings.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final listing = myMockListings[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(listing.imageUrls.first, width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('\$${listing.price.round()}/мес • Статус: Активно', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            trailing: IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Переход к редактированию объявления (симуляция)')),
                );
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListingDetailScreen(listing: listing)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMyViewingsTab(BuildContext context) {
    // Static booked viewings simulation data
    final List<Map<String, String>> mockViewings = [
      {
        'title': 'Уютная однокомнатная квартира возле Университета',
        'dateTime': 'Завтра в 14:00',
        'status': 'Подтверждено хозяином',
        'color': 'green'
      },
      {
        'title': 'Современная студия в новом доме',
        'dateTime': 'Пятница, 18:30',
        'status': 'Ожидает подтверждения',
        'color': 'orange'
      }
    ];

    return ListView.builder(
      itemCount: mockViewings.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final viewing = mockViewings[index];
        final isConfirmed = viewing['color'] == 'green';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewing['title']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Время встречи: ${viewing['dateTime']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(isConfirmed ? Icons.check_circle : Icons.pending, size: 16, color: isConfirmed ? Colors.green : Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      viewing['status']!,
                      style: TextStyle(
                        fontSize: 13, 
                        color: isConfirmed ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
