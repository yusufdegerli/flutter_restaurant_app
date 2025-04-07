import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sambapos_app_restorant/models/table.dart';
import 'package:sambapos_app_restorant/providers/auth_provider.dart';
import 'package:sambapos_app_restorant/providers/order_provider.dart'; // Only this OrderProvider is used
import 'package:sambapos_app_restorant/services/api_service.dart';
import 'package:sambapos_app_restorant/models/menu_item.dart';
import 'order_screen.dart';
import 'package:flutter/foundation.dart';

class TableSelectionScreen extends StatefulWidget {
  @override
  _TableSelectionScreenState createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  List<RestaurantTable> _tables = [];
  Map<String, List<RestaurantTable>> _groupedTables = {};
  bool _isLoading = true;
  String _error = '';
  String? _userName;
  bool _isMovingTable = false;
  String? _sourceTable;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _fetchTables();
    _getUserName();
    _getUserId();
  }

  void _getUserId() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = authProvider.userId;
  }

  void _getUserName() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userName = authProvider.userName;
  }

  Future<void> _fetchTables() async {
    try {
      List<RestaurantTable> tables = await ApiService.getTables();
      final grouped = await _groupTablesInBackground(tables);
      if (!mounted) return;
      setState(() {
        _tables = tables;
        _groupedTables = grouped;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print("Error fetching tables: $e");
      print(stackTrace);
      setState(() {
        _error = 'Masalar yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  Future<Map<String, List<RestaurantTable>>> _groupTablesInBackground(
    List<RestaurantTable> tables,
  ) async {
    return await compute(_groupTablesByCategory, tables);
  }

  static Map<String, List<RestaurantTable>> _groupTablesByCategory(
    List<RestaurantTable> tables,
  ) {
    Map<String, List<RestaurantTable>> grouped = {};
    for (var table in tables) {
      String category = table.category ?? 'Genel';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(table);
    }
    return grouped;
  }

  void _navigateToOrderScreen(BuildContext context, String tableName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderScreen(tableNumber: tableName),
      ),
    );
  }

  void _onTableLongPress(
    String tableName,
    BuildContext context,
    Offset tapPosition,
  ) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (orderProvider != null && orderProvider.hasOrder(tableName)) {
      setState(() {
        _sourceTable = tableName;
        _isMovingTable = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Taşıma modu: ${tableName} masası seçildi. Hedef masaya dokunun.",
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        _sourceTable = tableName;
        _isMovingTable = true;
      });
    }
  }

  void _closeActionMenu() {
    setState(() {
      _sourceTable = null;
      _isMovingTable = false;
    });
  }

  void _showOrderDetails(String tableName) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (orderProvider == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("OrderProvider bulunamadı.")));
      return;
    }
    final orders = orderProvider.getOrders(tableName);
    final orderTime = orderProvider.getOrderTime(tableName);
    final orderNote = orderProvider.getOrderNote(tableName);

    if (orders == null || orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bu masada sipariş bulunmamaktadır.")),
      );
      return;
    }

    Map<MenuItem, int> grouped = {};
    for (var item in orders) {
      grouped[item] = (grouped[item] ?? 0) + 1;
    }

    double total = 0;
    grouped.forEach((item, quantity) {
      total += item.price * quantity;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$tableName Masası Sipariş Detayları",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text("Siparişi Alan: $_userName - $_userId"),
                    SizedBox(height: 10),
                    Text(
                      "Sipariş Saati: ${orderTime?.toString() ?? 'Bilinmiyor'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Not: ${orderNote?.isNotEmpty == true ? orderNote : 'Not eklenmemiş'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final entry = grouped.entries.elementAt(index);
                        final menuItem = entry.key;
                        final quantity = entry.value;
                        return ListTile(
                          title: Text(menuItem.name),
                          subtitle: Text("Adet: $quantity"),
                          trailing: Text(
                            "₺${(menuItem.price * quantity).toStringAsFixed(2)}",
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Toplam: ₺${total.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategorySections() {
    try {
      return Column(
        children:
            _groupedTables.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final table = entry.value[index];
                      return Consumer<OrderProvider>(
                        builder: (context, orderProvider, _) {
                          if (orderProvider == null) {
                            return const Text("OrderProvider bulunamadı.");
                          }
                          final hasOrder = orderProvider.hasOrder(table.name);
                          return GestureDetector(
                            onTap: () {
                              if (_isMovingTable) {
                                if (table.name == _sourceTable) {
                                  setState(() {
                                    _isMovingTable = false;
                                    _sourceTable = null;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Taşıma iptal edildi."),
                                    ),
                                  );
                                } else {
                                  if (!orderProvider.hasOrder(_sourceTable!)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Boş masayı (${_sourceTable}) taşıyamazsınız!",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    setState(() {
                                      _isMovingTable = false;
                                      _sourceTable = null;
                                    });
                                    return;
                                  }
                                  try {
                                    orderProvider.moveOrder(
                                      _sourceTable!,
                                      table.name,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Sipariş ${_sourceTable} → ${table.name} taşındı.",
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isMovingTable = false;
                                      _sourceTable = null;
                                    });
                                  }
                                }
                              } else {
                                if (hasOrder) {
                                  _showOrderDetails(table.name);
                                } else {
                                  _navigateToOrderScreen(context, table.name);
                                }
                              }
                            },
                            onLongPress: () {
                              final box =
                                  context.findRenderObject() as RenderBox;
                              final offset = box.localToGlobal(Offset.zero);
                              _onTableLongPress(table.name, context, offset);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    _isMovingTable && table.name == _sourceTable
                                        ? Colors.purple
                                        : hasOrder
                                        ? Colors.orange
                                        : Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  table.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
    } catch (e, stackTrace) {
      print("Error in _buildCategorySections: $e");
      print(stackTrace);
      return const Center(
        child: Text(
          "Bir hata oluştu, lütfen tekrar deneyin.",
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Masa Seçimi")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Masa Seçimi")),
        body: Center(
          child: Text(
            _error,
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Masa Seçimi"),
            if (_userName != null)
              Text(
                "Hoşgeldin, $_userName",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        toolbarHeight: 70,
      ),
      body: GestureDetector(
        onTap: _closeActionMenu,
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildCategorySections(),
        ),
      ),
    );
  }
}
