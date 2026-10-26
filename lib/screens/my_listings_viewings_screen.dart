import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/listings_model.dart';
import '../widgets/error_view.dart';

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
          onPressed: () => context.push('/listings/new'),
          icon: const Icon(Icons.add),
          label: const Text('Подать объявление'),
        ),
      ),
    );
  }

  Widget _buildMyListingsTab(BuildContext context) {
    final model = context.watch<ListingsModel>();

    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.error != null) {
      return ErrorView(
        message: model.error!,
        onRetry: () => context.read<ListingsModel>().loadListings(),
      );
    }

    final myListings = model.listings;

    if (myListings.isEmpty) {
      return const Center(child: Text('У вас пока нет опубликованных объявлений'));
    }

    return ListView.builder(
      itemCount: myListings.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final listing = myListings[index];
        return Dismissible(
          key: ValueKey(listing.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (dialogCtx) => AlertDialog(
                title: const Text('Удалить объявление?'),
                content: Text('Вы уверены, что хотите удалить "${listing.title}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx, false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogCtx, true),
                    child: const Text('Удалить'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (_) async {
            final error = await context.read<ListingsModel>().removeListing(listing.id);
            if (!context.mounted) return;
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Объявление удалено')),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  listing.imageUrls.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              title: Text(listing.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('\$${listing.price.round()}/мес • Статус: Активно', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Удалить объявление?'),
                      content: Text('Вы уверены, что хотите удалить "${listing.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: const Text('Отмена'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: const Text('Удалить'),
                        ),
                      ],
                    ),
                  );

                  if (ok == true && context.mounted) {
                    final error = await context.read<ListingsModel>().removeListing(listing.id);
                    if (!context.mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Объявление удалено')),
                      );
                    }
                  }
                },
              ),
              onTap: () => context.push('/listings/${listing.id}'),
            ),
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
