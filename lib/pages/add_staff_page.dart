import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_list_page.dart';

class AddStaffPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const AddStaffPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}


class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final name = _nameController.text.trim();
      final id = _idController.text.trim();
      final age = int.parse(_ageController.text.trim());

      try {
        await FirebaseFirestore.instance.collection('staff').add({
          'name': name,
          'id': id,
          'age': age,
          'created_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => StaffListPage(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      onToggleTheme: (val) {}, // You can pass a real toggle if needed
    ),
  ),
);

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to add staff: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, Icon icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.teal, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Add Staff"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Staff Information",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _nameController,
                decoration:
                    _buildInputDecoration("Full Name", const Icon(Icons.person)),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _idController,
                decoration:
                    _buildInputDecoration("Staff ID", const Icon(Icons.badge)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'ID is required';
                  if (value.length < 3) return 'ID must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _ageController,
                decoration: _buildInputDecoration(
                    "Age", const Icon(Icons.calendar_today_rounded)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final age = int.tryParse(value ?? '');
                  if (value == null || value.trim().isEmpty) return 'Age is required';
                  if (age == null || age < 18 || age > 65) {
                    return 'Enter a valid age (18–65)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitData,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _isLoading ? "Saving..." : "Save Staff",
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
