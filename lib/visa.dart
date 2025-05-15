class VisaCardValidator {
  // التحقق من رقم البطاقة باستخدام خوارزمية Luhn
  static bool isValidCardNumber(String cardNumber) {
    // إزالة أي مسافات من الرقم
    cardNumber = cardNumber.replaceAll(' ', '');

    // التحقق من أن الرقم يحتوي على أرقام فقط
    if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return false; // إذا كان الرقم يحتوي على حروف أو رموز
    }

    // التحقق من أن الرقم طويل بما فيه الكفاية (يجب أن يكون بين 13 و 19 رقماً)
    if (cardNumber.length < 13 || cardNumber.length > 19) {
      return false;
    }

    // تطبيق خوارزمية Luhn للتحقق من صحة الرقم
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      alternate = !alternate;
    }

    // التحقق إذا كانت النتيجة تقبل القسمة على 10
    return sum % 10 == 0;
  }
}





























// import 'package:flutter/material.dart';


// class ShowVisaDialog extends StatelessWidget {
//   final TextEditingController cardNumberController;
//   final TextEditingController expiryDateController;
//   final TextEditingController cvvController;
//   final GlobalKey<FormState> formKey;
//   final VoidCallback? onSubmit; // Accept the callback

//   ShowVisaDialog({
//     required this.cardNumberController,
//     required this.expiryDateController,
//     required this.cvvController,
//     required this.formKey,
//     required this.onSubmit, // Accept the callback function in the constructor
//   });

//   // Function to show the Date Picker for Expiry Date
//   Future<void> _selectExpiryDate(BuildContext context) async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (selectedDate != null) {
//       // Format the date to MM/YY format and update the text field
//       String formattedDate =
//           '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString().substring(2, 4)}';
//       expiryDateController.text = formattedDate;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       // Ensures scrolling when content overflows
//       child: Container(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Enter Visa Details',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Form(
//               key: formKey,
//               child: Column(
//                 children: [
//                   // Card Number Input
//                   TextFormField(
//                     controller: cardNumberController,
//                     decoration: InputDecoration(
//                       labelText: 'Card Number',
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter card number';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 10),

//                   // Expiry Date Input with Gesture Detector for Date Picker
//                   GestureDetector(
//                     onTap: () => _selectExpiryDate(context),
//                     child: AbsorbPointer(
//                       // Prevent typing in the text field
//                       child: TextFormField(
//                         controller: expiryDateController,
//                         decoration: InputDecoration(
//                           labelText: 'Expiry Date (MM/YY)',
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select expiry date';
//                           }
//                           if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
//                             return 'Expiry date must be in MM/YY format';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),

//                   // CVV Input
//                   TextFormField(
//                     controller: cvvController,
//                     decoration: InputDecoration(
//                       labelText: 'CVV',
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType.number,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter CVV';
//                       }
//                       if (value.length != 3) {
//                         return 'CVV must be 3 digits';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: 20),

//                   // Submit Button
//                   ElevatedButton(
//                     onPressed: () {
//                       if (formKey.currentState?.validate() ?? false) {
//                         onSubmit!();
//                         Navigator.pop(context); // Close the dialog
//                       } else {
//                         // Form is invalid, don't close the dialog
//                         print("Invalid form");
//                       }
//                     },
//                     child: Text('Submit'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
