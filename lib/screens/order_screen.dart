import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sambapos_app_restorant/providers/order_provider.dart';
import 'package:sambapos_app_restorant/services/api_service.dart';
import '../models/menu_item.dart';
import 'payment_screen.dart';
import 'dart:async';

class OrderScreen extends StatefulWidget {
  final String tableNumber;

  const OrderScreen({Key? key, required this.tableNumber}) : super(key: key);

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {
  String _selectedCategory = "Pideler";
  List<MenuItem> _menuItems = [];
  List<MenuItem> _selectedItems = [];
  bool _isLoading = true;
  int _selectedQuantity = 1;
  MenuItem? _lastSelectedItem;
  int _currentQuantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMenuItems());
    _selectedItems = Provider.of<OrderProvider>(
      context,
      listen: false,
    ).getOrders(widget.tableNumber);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tekrar Dene',
          onPressed: _fetchMenuItems,
        ),
      ),
    );
  }

  Future<void> _fetchMenuItems() async {
    try {
      final items = await ApiService.getMenuItems().timeout(
        const Duration(seconds: 10),
      );
      if (!mounted) return;
      setState(() {
        _menuItems = items;
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(
        "Sunucuya bağlanırken zaman aşımı oluştu. Lütfen tekrar deneyin.",
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError("Menü yüklenirken hata oluştu: ${e.toString()}");
    }
  }

  List<String> get categories =>
      _menuItems.map((e) => e.groupCode).toSet().toList();

  List<MenuItem> get categoryItems =>
      _menuItems.where((item) => item.groupCode == _selectedCategory).toList();

  void _addToOrder(MenuItem item) {
    setState(() {
      _selectedQuantity = 1;
      _currentQuantity = 1;
      _selectedItems.add(item);
      _lastSelectedItem = item;
    });
    _updateProvider();
  }

  void _updateQuantity(int newQuantity) {
    if (_lastSelectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen önce bir ürün seçin.")),
      );
      return;
    }

    setState(() {
      final currentCount =
          _selectedItems.where((i) => i.id == _lastSelectedItem!.id).length;
      _selectedItems.removeWhere((i) => i.id == _lastSelectedItem!.id);
      for (int i = 0; i < newQuantity; i++) {
        _selectedItems.add(_lastSelectedItem!);
      }
      _currentQuantity = newQuantity;
      _selectedQuantity = newQuantity;
    });
    _updateProvider();
  }

  void _incrementQuantity() => _updateQuantity(_currentQuantity + 1);
  void _decrementQuantity() =>
      _currentQuantity > 1 ? _updateQuantity(_currentQuantity - 1) : null;

  void _removeAllFromOrder(MenuItem item) {
    setState(() => _selectedItems.removeWhere((i) => i.id == item.id));
    _updateProvider();
  }

  void _updateProvider() {
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).updateOrder(widget.tableNumber, _selectedItems);
  }

  double get _totalPrice =>
      _selectedItems.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.tableNumber} - Sipariş")),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Kategoriler (Sabit Yükseklik)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder:
                          (context, index) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed:
                                  () => setState(
                                    () => _selectedCategory = categories[index],
                                  ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _selectedCategory == categories[index]
                                        ? Colors.orange
                                        : Colors.grey[300],
                              ),
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color:
                                      _selectedCategory == categories[index]
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),

                  // Adet Seçim Çubuğu (Sabit Yükseklik)
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            child: Text(
                              "Adet: ",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _decrementQuantity,
                          child: const Text("-"),
                        ),
                        ...List.generate(10, (index) => index + 1).map(
                          (number) => ElevatedButton(
                            onPressed: () => _updateQuantity(number),
                            child: Text("$number"),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _incrementQuantity,
                          child: const Text("+"),
                        ),
                      ],
                    ),
                  ),

                  // Ana Menü Grid (Esnek Alan)
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true, // İçerik boyutuna göre küçül
                      physics:
                          const ClampingScrollPhysics(), // İç scroll'u devre dışı bırak
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: categoryItems.length,
                      itemBuilder: (context, index) {
                        final item = categoryItems[index];
                        return GestureDetector(
                          onTap: () => _addToOrder(item),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                              color:
                                  _selectedItems.contains(item)
                                      ? Colors.grey[400]
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Sürüklenebilir Panel (Minimum Yükseklik)
                  // Sürüklenebilir Panel Yerine Sabit Liste
                  SizedBox(
                    height: 350, // Sabit yükseklik
                    child: Column(
                      children: [
                        // Siparişler Başlığı
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Siparişler",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Liste Öğeleri
                        Expanded(
                          child:
                              _selectedItems.isEmpty
                                  ? const Center(
                                    child: Text("Henüz sipariş eklenmedi"),
                                  )
                                  : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemCount:
                                        _selectedItems.fold<Map<MenuItem, int>>(
                                          {},
                                          (map, item) {
                                            map[item] = (map[item] ?? 0) + 1;
                                            return map;
                                          },
                                        ).length,
                                    itemBuilder: (context, index) {
                                      final entry = _selectedItems
                                          .fold<Map<MenuItem, int>>({}, (
                                            map,
                                            item,
                                          ) {
                                            map[item] = (map[item] ?? 0) + 1;
                                            return map;
                                          })
                                          .entries
                                          .elementAt(index);
                                      return ListTile(
                                        title: Text(
                                          "${entry.key.name} x${entry.value}",
                                        ),
                                        subtitle: Text(
                                          "₺${(entry.key.price * entry.value).toStringAsFixed(2)}",
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _removeAllFromOrder(
                                                entry.key,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                        // Ödeme Butonu
                        if (_selectedItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PaymentScreen(
                                            tableNumber: widget.tableNumber,
                                            totalAmount: _totalPrice,
                                          ),
                                    ),
                                  ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: Colors.green,
                              ),
                              child: Text(
                                "SİPARİŞ AL (₺${_totalPrice.toStringAsFixed(2)})",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
