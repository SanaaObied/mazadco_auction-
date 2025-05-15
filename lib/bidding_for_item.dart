import 'package:flutter/material.dart';

class MaxBidDialog extends StatefulWidget {
  final double currentPrice;
  final Function(double) onMaxBidAccepted;

  const MaxBidDialog({
    super.key,
    required this.currentPrice,
    required this.onMaxBidAccepted,
  });

  @override
  _MaxBidDialogState createState() => _MaxBidDialogState();
}

class _MaxBidDialogState extends State<MaxBidDialog> {
  final TextEditingController _controller = TextEditingController();
  String _errorMessage = '';

  void _submitBid() {
    // محاولة تحويل المدخل إلى قيمة عددية
    double? bidAmount = double.tryParse(_controller.text);

    // تحقق إذا كان المدخل غير صالح
    if (bidAmount == null) {
      setState(() => _errorMessage = '⚠️ Please enter a valid number.');
      return;
    }

    // حساب الحد الأدنى المسموح به (السعر الحالي + 40%)
    double minRequired = widget.currentPrice + (widget.currentPrice * 0.4);

    // تحقق إذا كان العرض أقل من الحد الأدنى
    if (bidAmount < minRequired) {
      setState(
        () =>
            _errorMessage =
                '⚠️ The amount must be at least ${minRequired.toStringAsFixed(2)} €.',
      );
      return;
    }

    // قبول العرض وتحديث المزايدة
    widget.onMaxBidAccepted(bidAmount);

    // إغلاق الحوار بعد قبول العرض
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Maximum Bid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عرض السعر الحالي
          Text('Current price: ${widget.currentPrice.toStringAsFixed(2)} €'),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter your max bid',
              errorText: _errorMessage.isEmpty ? null : _errorMessage,
            ),
          ),
        ],
      ),
      actions: [
        // زر إلغاء
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        // زر تأكيد
        ElevatedButton(onPressed: _submitBid, child: Text('Submit')),
      ],
    );
  }
}

class BidDialog extends StatelessWidget {
  final double currentPrice;
  final int itemId;
  final Function(double) onBidAccepted;

  const BidDialog({
    super.key,
    required this.currentPrice,
    required this.itemId,
    required this.onBidAccepted,
  });

  void _selectBid(BuildContext context, double bidAmount) {
    onBidAccepted(bidAmount);
    Navigator.pop(context); // ✅ إغلاق Dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Place a Bid'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Price: €$currentPrice'),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  double increment;
                  if (currentPrice < 100) {
                    increment = 5; // إضافة 5 إذا كانت القيمة أقل من 100
                  } else {
                    increment = 30;
                  }
                  _selectBid(context, currentPrice + increment);
                },
                child: Text('€${currentPrice + (currentPrice < 100 ? 5 : 30)}'),
              ),
              ElevatedButton(
                onPressed: () {
                  double increment;
                  if (currentPrice < 100) {
                    increment = 10; // إضافة 10 إذا كانت القيمة أقل من 100
                  } else {
                    increment = 40;
                  }
                  _selectBid(context, currentPrice + increment);
                },
                child: Text(
                  '€${currentPrice + (currentPrice < 100 ? 10 : 40)}',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  double increment;
                  if (currentPrice < 100) {
                    increment = 15; // إضافة 15 إذا كانت القيمة أقل من 100
                  } else {
                    increment = 50;
                  }
                  _selectBid(context, currentPrice + increment);
                },
                child: Text(
                  '€${currentPrice + (currentPrice < 100 ? 15 : 50)}',
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
