import 'package:flutter/material.dart';
import 'auth_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пользователя'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar and Main Info
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Иван Иванов',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Студент 3-го курса • Верифицирован',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('3', 'Просмотра'),
                    Container(height: 30, width: 1, color: Colors.grey[300]),
                    _buildStatColumn('2', 'Объявления'),
                    Container(height: 30, width: 1, color: Colors.grey[300]),
                    _buildStatColumn('5', 'В Избранном'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Settings Menu Options
            _buildMenuTile(context, Icons.person_outline, 'Личные данные', 'Изменить имя, контакты'),
            _buildMenuTile(context, Icons.security_outlined, 'Безопасность', 'Смена пароля, сессии'),
            _buildMenuTile(context, Icons.notifications_none, 'Уведомления', 'Настройка push и email'),
            _buildMenuTile(context, Icons.help_outline, 'Помощь и поддержка', 'FAQ, связь со службой заботы'),
            
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Раздел "$title" находится в разработке (L2 - статический интерфейс)')),
        );
      },
    );
  }
}
