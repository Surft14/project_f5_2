import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // для фильтра маски

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Приложение №2',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: SecondAppScreen(),
    );
  }
}

class SecondAppScreen extends StatefulWidget {
  @override
  _SecondAppScreenState createState() => _SecondAppScreenState();
}

class _SecondAppScreenState extends State<SecondAppScreen> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  final _items = List.generate(10, (i) => 'Запись ${i + 1}');
  final _carouselItems = List.generate(5, (i) => 'https://placehold.co/200x120?text=Image+${i + 1}');


  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Карусель: $_carouselItems');
    final pages = [
      // Главная страница
      SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Добро пожаловать', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _carouselItems.length,
                itemBuilder: (_, i) => Container(
                  width: 200,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade300,
                    image: DecorationImage(
                      image: NetworkImage(_carouselItems[i]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _PhoneMaskFormatter()
                ],
                decoration: InputDecoration(labelText: 'Телефон'),
                validator: (v) {
                  if (v == null || v.length < 10) return 'Введите корректный номер';
                  return null;
                },
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Спасибо'),
                        content: Text('Ваш номер: ${_phoneController.text}'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
                        ],
                      ),
                    );
                  }
                },
                child: Text('Отправить'),
              ),
            ),
          ],
        ),
      ),

      // Страница списка
      ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (_, i) => Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(_items[i]),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Приложение №2')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Список'),
        ],
      ),
    );
  }
}

/// Маска ввода вида +7 (999) 999‑99‑99
class _PhoneMaskFormatter extends TextInputFormatter {
  static const _maxLength = 11;
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > _maxLength ? digits.substring(0, _maxLength) : digits;
    final buffer = StringBuffer('+7 ');
    for (int i = 1; i < limited.length; i++) {
      if (i == 1) buffer.write('(');
      if (i == 4) buffer.write(') ');
      if (i == 7 || i == 9) buffer.write('-');
      buffer.write(limited[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
