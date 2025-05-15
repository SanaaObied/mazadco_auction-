import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

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

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sellerNameController = TextEditingController();

  // Categories list
  final List<String> _categories = [
    'Furniture',
    'Electronics',
    'Fashion',
    'Books',
    'Vehicles',
    'Jewelry',
    'Toys',
    'Home Appliances',
    'Musical Instruments',
    'Sport Equipment'
  ];

  // Image picker function
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

  // Form submission function
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _image == null)) {
      _showErrorSnackBar('Please upload product image');
      return;
    }

    // Validate dates
    try {
      final startDate = _parseDateTime(_startDateController.text);
      final endDate = _parseDateTime(_endDateController.text);
      
      if (endDate.isBefore(startDate)) {
        _showErrorSnackBar('End date must be after start date');
        return;
      }
      
      if (endDate.isBefore(DateTime.now())) {
        _showErrorSnackBar('End date must be in the future');
        return;
      }
    } catch (e) {
      _showErrorSnackBar('Invalid date format');
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      // Use your actual server URL here
      const serverUrl = 'http://10.0.2.2/user_profile/add-product.php';
      var uri = Uri.parse(serverUrl);
      var request = http.MultipartRequest("POST", uri);

      // Add text fields
      request.fields.addAll({
        'title': _nameController.text.trim(),
        'price': _priceController.text.trim(),
        'category': _selectedCategory ?? "",
        'start_time': _startDateController.text,
        'end_time': _endDateController.text,
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
        'saller_name': _sellerNameController.text.trim(),
        'status': 'active',
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

      // Debug print
      debugPrint('Sending request to: $serverUrl');
      debugPrint('Request fields: ${request.fields}');
      debugPrint('Files count: ${request.files.length}');

      // Send request with timeout
      var response = await request.send().timeout(const Duration(seconds: 30));
      
      // Process response
      var respStr = await response.stream.bytesToString();
      debugPrint('Server response: $respStr');
      
      if (response.statusCode == 200) {
        var respJson = jsonDecode(respStr);
        if (respJson['success'] == true) {
          _showSuccessSnackBar(respJson['message'] ?? 'Product added successfully');
          _resetForm();
        } else {
          throw Exception(respJson['message'] ?? 'Server returned error');
        }
      } else {
        throw Exception('HTTP ${response.statusCode} - $respStr');
      }
    } on SocketException {
      _showErrorSnackBar('Network error: Could not connect to server');
    } on http.ClientException {
      _showErrorSnackBar('Server connection failed');
   
    } on FormatException {
      _showErrorSnackBar('Invalid server response format');
    } catch (e) {
      debugPrint('Full error: $e');
      _showErrorSnackBar('Error: ${e.toString().split(':').last.trim()}');
    } finally {
      setState(() => _isSubmitting = false);
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
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product To Auction"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildImageUploadSection(),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  icon: Icons.text_fields,
                  validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                ),
                _buildTextField(
                  controller: _priceController,
                  label: 'Starting Price (NIS)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required field';
                    if (double.tryParse(value!) == null) return 'Invalid number';
                    if (double.parse(value) <= 0) return 'Price must be positive';
                    return null;
                  },
                ),
                _buildDatePickerField(
                  controller: _startDateController,
                  label: 'Auction Start Date',
                ),
                const SizedBox(height: 15),
                _buildDatePickerField(
                  controller: _endDateController,
                  label: 'Auction End Date',
                ),
                _buildCategoryDropdown(),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                  validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                ),
                _buildTextField(
                  controller: _sellerNameController,
                  label: 'Seller Name',
                  icon: Icons.person,
                  validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
                ),
                _buildDescriptionField(),
                const SizedBox(height: 25),
                _buildSubmitButton(),
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
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: _buildImagePreview(),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(_webImage!, fit: BoxFit.cover);
    } else if (!kIsWeb && _image != null) {
      return Image.file(_image!, fit: BoxFit.cover);
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
        SizedBox(height: 10),
        Text("Tap to upload product image", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      ),
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
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () => _selectDate(context, controller),
      validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
    );
  }
Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
  
  if (date != null) {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text('Select From List'),
      items: _categories.map((String value) {
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
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.description),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Required field' : null,
    );
  }

  Widget _buildSubmitButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Add Auction Product",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
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
    _sellerNameController.dispose();
    super.dispose();
  }
}