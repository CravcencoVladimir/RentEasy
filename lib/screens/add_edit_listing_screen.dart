import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../models/listings_model.dart';

class AddEditListingScreen extends StatefulWidget {
  const AddEditListingScreen({super.key});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedDistrict = 'Центр';
  int _selectedRooms = 1;
  final List<String> _districts = ['Центр', 'Рышкановка', 'Ботаника', 'Буюканы', 'Чеканы'];
  final List<String> _mockUploadedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simulatePhotoUpload() {
    setState(() {
      _mockUploadedImages.add('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Фотография успешно добавлена')),
    );
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final draft = Listing(
        id: '', // Repository generates unique id
        ownerId: 'user_current',
        title: _titleController.text.trim(),
        address: _addressController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        rooms: _selectedRooms,
        district: _selectedDistrict,
        description: _descriptionController.text.trim(),
        imageUrls: _mockUploadedImages.isEmpty
            ? ['https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80']
            : List.from(_mockUploadedImages),
      );

      final error = await context.read<ListingsModel>().addListing(draft);
      if (!mounted) return;

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Объявление "${draft.title}" успешно опубликовано!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новое объявление'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Заполните информацию о жилье',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Название объявления',
                  hintText: 'например, Студия рядом с Политехом',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите название';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address Field
              TextFormField(
                controller: _addressController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Точный адрес',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите адрес';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Row for District and Rooms
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'Район',
                        border: OutlineInputBorder(),
                      ),
                      items: _districts.map((district) {
                        return DropdownMenuItem(value: district, child: Text(district));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedDistrict = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedRooms,
                      decoration: const InputDecoration(
                        labelText: 'Комнат',
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3, 4].map((count) {
                        return DropdownMenuItem(value: count, child: Text('$countк квартира'));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedRooms = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Цена в месяц (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Укажите цену';
                  final price = double.tryParse(value);
                  if (price == null) return 'Введите число';
                  if (price <= 0) return 'Цена должна быть больше 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Описание условий проживания',
                  hintText: 'Расскажите про мебель, интернет, коммунальные услуги, залог...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Заполните описание';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Photo Gallery Section
              Text('Фотографии жилья', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    InkWell(
                      onTap: _simulatePhotoUpload,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, color: Colors.grey),
                            SizedBox(height: 4),
                            Text('Добавить', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    ..._mockUploadedImages.map((url) => Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveForm,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('Опубликовать объявление', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
