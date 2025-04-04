import 'package:flutter/material.dart';
import 'package:sambapos_app_restorant/providers/order_provider.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final String tableNumber;
  final double totalAmount;

  const PaymentScreen({
    Key? key,
    required this.tableNumber,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                final orderProvider = Provider.of<OrderProvider>(
                  context,
                  listen: false,
                );
                // Notu siparişle birlikte kaydet
                orderProvider.updateOrder(
                  widget.tableNumber,
                  [],
                  note: _noteController.text,
                );
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Siparişi Tamamla"),
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
