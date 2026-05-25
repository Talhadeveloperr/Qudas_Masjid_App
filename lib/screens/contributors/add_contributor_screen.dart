//qudas\lib\screens\contributors\add_contributor_screen.dart
import 'package:flutter/material.dart';
import '../../models/contributor_model.dart';
import '../../services/contributor_service.dart';

class AddContributorScreen extends StatefulWidget {
  final Contributor? contributor;

  const AddContributorScreen({super.key, this.contributor});

  @override
  State<AddContributorScreen> createState() => _AddContributorScreenState();
}

class _AddContributorScreenState extends State<AddContributorScreen> {
  final _formKey = GlobalKey<FormState>();
  final ContributorService _service = ContributorService();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _commitmentController;
  List<TextEditingController> _phoneControllers = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contributor?.fullName ?? '');
    _addressController = TextEditingController(text: widget.contributor?.address ?? '');
    _commitmentController = TextEditingController(text: widget.contributor?.monthlyCommitment.toString() ?? '0.00');

    if (widget.contributor != null && widget.contributor!.phoneNumbers.isNotEmpty) {
      for (var phone in widget.contributor!.phoneNumbers) {
        _phoneControllers.add(TextEditingController(text: phone));
      }
    } else {
      _phoneControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _commitmentController.dispose();
    for (var c in _phoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    if (_phoneControllers.length > 1) {
      setState(() {
        _phoneControllers[index].dispose();
        _phoneControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final List<String> phones = _phoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

      final contributorData = Contributor(
        id: widget.contributor?.id,
        fullName: _nameController.text.trim(),
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        monthlyCommitment: double.parse(_commitmentController.text.trim()),
        phoneNumbers: phones,
      );

      if (widget.contributor == null) {
        await _service.addContributor(contributorData);
      } else {
        await _service.updateContributor(widget.contributor!.id!, contributorData);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving record: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contributor != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Modify Contributor" : "New Contributor")),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Full Name *", border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? "Name required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: "Physical Address", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commitmentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Monthly Commitment Amount (\Rs)", border: OutlineInputBorder()),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return "Amount required";
                      if (double.tryParse(v) == null) return "Enter valid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Phone Contact Vectors", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addPhoneField),
                    ],
                  ),
                  const Divider(),
                  ...List.generate(_phoneControllers.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneControllers[index],
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Phone Line #${index + 1}",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (_phoneControllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => _removePhoneField(index),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEdit ? "Update Directory Record" : "Register Contributor", style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}