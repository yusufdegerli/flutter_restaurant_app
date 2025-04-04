import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sambapos_app_restorant/providers/order_provider.dart';
import 'order_screen.dart';
import 'package:sambapos_app_restorant/models/table.dart';
import 'package:sambapos_app_restorant/services/api_service.dart';
import 'package:sambapos_app_restorant/providers/auth_provider.dart';
import 'login_screen.dart';

class TableSelectionScreen extends StatefulWidget {
  const TableSelectionScreen({Key? key}) : super(key: key);

  @override
  _TableSelectionScreenState createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  List<RestaurantTable> _tables = [];
  Map<String, List<RestaurantTable>> _groupedTables = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    print("TableSelectionScreen initState ÇALIŞTI");
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    try {
      List<RestaurantTable> tables = await ApiService.getTables();
      print(
        "API'den gelen masa verisi: ${tables.map((t) => t.name).toList()}",
      ); // Ekstra print
      _groupedTables = _groupTablesByCategory(tables);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'HATA: $e';
        _isLoading = false;
      });
      print("Masa yükleme hatası detayı: $e"); // Detaylı hata mesajı
    }
  }

  /*Future<void> _fetchTables() async {
    try {
      List<RestaurantTable> tables = await ApiService.getTables();
      _groupedTables = _groupTablesByCategory(tables);
      setState(() {
        _isLoading = false;
        print("API'den gelen masalar: ${tables.map((t) => t.name).toList()}");
      });
    } catch (e) {
      setState(() {
        _error = 'Masalar yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }*/

  Map<String, List<RestaurantTable>> _groupTablesByCategory(
    List<RestaurantTable> tables,
  ) {
    Map<String, List<RestaurantTable>> grouped = {};
    for (var table in tables) {
      if (!grouped.containsKey(table.category)) {
        grouped[table.category] = [];
      }
      grouped[table.category]!.add(table);
    }
    return grouped;
  }

  void _navigateToOrderScreen(BuildContext context, String tableName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderScreen(tableNumber: tableName),
      ),
    );
  }

  Widget _buildCategorySections() {
    if (_groupedTables.isEmpty) {
      return const Center(child: Text("Masa bulunamadı"));
    }
    return Column(
      children:
          _groupedTables.entries.map((entry) {
            String category = entry.key;
            List<RestaurantTable> tablesInCategory = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    category,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: tablesInCategory.length,
                  itemBuilder: (context, index) {
                    final table = tablesInCategory[index];
                    return Consumer<OrderProvider>(
                      builder: (context, orderProvider, _) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                orderProvider.hasOrder(table.name)
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                          onPressed:
                              () => _navigateToOrderScreen(context, table.name),
                          child: Text(
                            table.name,
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("TableSelectionScreen build ÇALIŞTI");

    // Veri yükleniyorsa veya hata varsa UI'ı göster
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            _error,
            style: TextStyle(color: Colors.red, fontSize: 18), // Stil ekleyin
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Masalar')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: _buildCategorySections(),
              ),
            ),
          );
        },
      ),
    );
  }
}
