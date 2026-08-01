import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

import 'linkapi.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  File? _image;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  String? _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Categories list with IDs
  final Map<String, int> _categories = {
    'Electronics': 1,
    'Furniture': 2,
    'Vehicles': 3,
    'Home Appliances': 4,
    'Fashion': 5,
    'Sports Equipment': 6,
    'Toys': 7,
    'Books': 8,
    'Jewelry': 9,
    'Musical Instruments': 10
  };

  @override
  Widget build(BuildContext context) {
    final bool isWeb = kIsWeb;
    final double formWidth = isWeb
        ? MediaQuery.of(context).size.width * 0.6
        : MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Add New Auction Product"),
        centerTitle: true,
        backgroundColor: Colors.teal, // Teal color
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWeb ? 800 : double.infinity),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF), // Light blue background
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'images/icon.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Create New Auction',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal, // White color
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in all required details to list your product',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal, // White color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Form Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: SizedBox(
                      width: formWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image Section
                          const Text(
                            'Product Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal, // White color
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildImageUploadSection(),
                          const SizedBox(height: 30),

                          // Product Information Section
                          const Text(
                            'Product Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal, // White color
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Product Name',
                            icon: Icons.shopping_bag,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _priceController,
                            label: 'Starting Price',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildDescriptionField(),
                          const SizedBox(height: 30),

                          // Auction Details Section
                          const Text(
                            'Auction Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal, // White color
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildDatePickerField(
                            controller: _startDateController,
                            label: 'Start Date & Time',
                          ),
                          const SizedBox(height: 20),
                          _buildDatePickerField(
                            controller: _endDateController,
                            label: 'End Date & Time',
                          ),
                          const SizedBox(height: 20),
                          _buildCategoryDropdown(),
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: _locationController,
                            label: 'Location',
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 30),

                          // Submit Button
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal, // White color
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        'All fields are required',
                        style: TextStyle(
                          color: Colors.teal, // White color
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.teal, // White color
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _buildImagePreview(),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.memory(_webImage!, fit: BoxFit.cover),
      );
    } else if (!kIsWeb && _image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.file(_image!, fit: BoxFit.cover),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 50, color: Colors.teal.withOpacity(0.5)),
        const SizedBox(height: 10),
        Text(
          "Tap to upload product image",
          style: TextStyle(
            color: Colors.teal, // White color
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.teal),
        floatingLabelStyle: const TextStyle(color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.teal),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (label.contains('Price') && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(                          color: Colors.teal, // White color
        ),
        floatingLabelStyle: const TextStyle(                          color: Colors.teal, // White color
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(                          color: Colors.teal, // White color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(                          color: Colors.teal, // White color
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(                          color: Colors.teal // White color
              , width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.calendar_today,                          color: Colors.teal, // White color
        ),
        suffixIcon: const Icon(Icons.arrow_drop_down,                           color: Colors.teal, // White color
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please select a date' : null,
      onTap: () => _selectDate(context, controller),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: const TextStyle(                          color: Colors.teal, // White color
        ),
        floatingLabelStyle: const TextStyle(                          color: Colors.teal, // White color
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(                          color: Colors.teal, // White color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(                          color: Colors.teal, // White color
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(                          color: Colors.teal, // White color
               width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.category,                           color: Colors.teal, // White color
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      ),
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(Icons.arrow_drop_down,                           color: Colors.teal, // White color
      ),
      hint: const Text('Select Category'),
      items: _categories.keys.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a category' : null,
      onChanged: (String? newValue) {
        setState(() => _selectedCategory = newValue);
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: const TextStyle(                          color: Colors.teal, // White color
        ),
        floatingLabelStyle: const TextStyle(                          color: Colors.teal, // White color
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(                          color: Colors.teal, // White color
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(                          color: Colors.teal, // White color
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(                          color: Colors.teal, // White color
              width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.description,                           color: Colors.teal, // White color
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008080), // Hex for Teal
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF008080).withOpacity(0.4),
        ),
        child: _isSubmitting
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'ADD AUCTION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );


  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _image = File(pickedFile.path));
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF008080),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF008080),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(
          DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
        );
        controller.text = formattedDate;
      }
    }
  }

  DateTime _parseDateTime(String dateTimeStr) {
    try {
      final parts = dateTimeStr.split(' ');
      final dateParts = parts[0].split('-');
      final timeParts = parts[1].split(':');

      return DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      throw FormatException('Invalid date format');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _image == null)) {
      _showErrorSnackBar('Please upload product image');
      return;
    }

    try {
      final startDate = _parseDateTime(_startDateController.text);
      final endDate = _parseDateTime(_endDateController.text);

      if (endDate.isBefore(startDate)) {
        _showErrorSnackBar('End date must be after start date');
        return;
      }
    } catch (e) {
      _showErrorSnackBar('Invalid date format');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      var uri = Uri.parse(linkAddProduct);
      var request = http.MultipartRequest("POST", uri);

      // Get category ID from selected name
      int? categoryId = _selectedCategory != null ? _categories[_selectedCategory!] : null;
      if (categoryId == null) {
        _showErrorSnackBar('Please select a valid category');
        return;
      }

      // Add fields
      request.fields.addAll({
        'title': _nameController.text.trim(),
        'price': _priceController.text.trim(),
        'category_id': categoryId.toString(),
        'start_time': _startDateController.text,
        'end_time': _endDateController.text,
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'status': 'open',
      });

      // Add image
      if (kIsWeb && _webImage != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _webImage!,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      } else if (!kIsWeb && _image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          filename: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      }

      var response = await request.send().timeout(const Duration(seconds: 30));
      var respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var respJson = jsonDecode(respStr);
        if (respJson['success'] == true) {
          _showSuccessSnackBar(respJson['message'] ?? 'Product added successfully');
          _resetForm();
        } else {
          throw Exception(respJson['message'] ?? respJson['errors']?.values.join(', ') ?? 'Server error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode} - $respStr');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _image = null;
      _webImage = null;
      _selectedCategory = null;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1976D2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );

  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

}