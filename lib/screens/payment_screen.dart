import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sambapos_app_restorant/providers/auth_provider.dart';
import 'package:sambapos_app_restorant/providers/order_provider.dart';
import '../models/menu_item.dart';
import '../services/order_service.dart';

class PaymentScreen extends StatefulWidget {
  final String tableNumber;
  final double totalAmount;
  final List<MenuItem> selectedItems;

  const PaymentScreen({
    Key? key,
    required this.tableNumber,
    required this.totalAmount,
    required this.selectedItems,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _noteController = TextEditingController();
  //final OrderService _orderService = OrderService();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Ödeme - ${widget.tableNumber}")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.tableNumber} MASASI",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Toplam Tutar: ₺${widget.totalAmount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Sipariş Notu',
                border: OutlineInputBorder(),
                hintText: 'Ek not yazabilirsiniz...',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                try {
                  final userName = authProvider.userName ?? 'Bilinmiyor';
                  final userId = authProvider.userId?.toString() ?? '0';

                  await orderProvider.completeOrderWithApi(
                    tableNumber: widget.tableNumber,
                    items: widget.selectedItems,
                    note:
                        _noteController.text.isNotEmpty
                            ? _noteController.text
                            : "Not yok",
                    userName: userName,
                    userId: userId,
                    totalAmount: widget.totalAmount,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sipariş başarıyla gönderildi!")),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Hata: ${e.toString()}")),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              },
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text("SİPARİŞİ TAMAMLA"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Geri Dön"),
            ),
          ],
        ),
      ),
    );
  }
}
