import 'package:flutter/material.dart';
import 'package:works/create_account_2.dart';

class UserRegistrationForm extends StatefulWidget {
  const UserRegistrationForm({super.key});

  @override
  _UserRegistrationFormState createState() => _UserRegistrationFormState();
}

class _UserRegistrationFormState extends State<UserRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _accountType = 'buyer';
  String? _status2 = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _dateController.text = formattedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF708090)), // Slate Gray
      prefixIcon: Icon(icon, color: Colors.teal),
      filled: true,
      fillColor: Color(0xFFE0F2F1), // Light Teal
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 164, 217, 202),
      appBar: AppBar(
        toolbarHeight: 130, // تحديد ارتفاع الـ AppBar
        backgroundColor: Colors.transparent, // لجعل الخلفية شفافة
        elevation: 0, // لإزالة الظل من الـ AppBar
        automaticallyImplyLeading: true, // إظهار زر الرجوع
        flexibleSpace: Container(
          height: 130,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 8),
              Text(
                "Create New Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
            ],
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: buildInputDecoration(
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter your name'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: buildInputDecoration(
                      label: 'Email Address',
                      icon: Icons.email,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter a valid email'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: buildInputDecoration(
                      label: 'Phone Number',
                      icon: Icons.phone,
                    ),
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) =>
                            value == null || value.length != 10
                                ? 'Enter a valid phone number'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _accountType,
                    decoration: buildInputDecoration(
                      label: 'Account Type',
                      icon: Icons.person_pin,
                    ),
                    items:
                        ['buyer', 'seller', 'admin']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _accountType = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    enabled: false,
                    decoration: buildInputDecoration(
                      label: 'Created At',
                      icon: Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status2!.isEmpty ? null : _status2,
                    decoration: buildInputDecoration(
                      label: 'Payment Method',
                      icon: Icons.payment,
                    ),
                    items:
                        ['Visa', 'PayPal', 'Apple Pay', 'Cash on delivery']
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => _status2 = value),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please select a payment method'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: buildInputDecoration(
                      label: 'Address',
                      icon: Icons.location_on,
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter your address'
                                : null,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => UserCredentialsForm(
                                    name: _nameController.text,
                                    email: _emailController.text,
                                    phone: _phoneController.text,
                                    address: _addressController.text,
                                    date: _dateController.text,
                                    accountType: _accountType,
                                    payment_way: _status2 ?? '',
                                  ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '* All fields are required',
                    style: TextStyle(color: Color(0xFFFF7F50)), // Coral warning
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
