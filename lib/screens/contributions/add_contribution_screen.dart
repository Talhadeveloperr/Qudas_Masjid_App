//qudas\lib\screens\contributions\add_contribution_screen.dart
// qudas/lib/screens/contributions/add_contribution_screen.dart
import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';
import '../../services/contribution_service.dart';

class AddContributionScreen extends StatefulWidget {
  final Contribution? contribution; // Receives data if editing

  const AddContributionScreen({super.key, this.contribution});

  @override
  State<AddContributionScreen> createState() => _AddContributionScreenState();
}

class _AddContributionScreenState extends State<AddContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ContributionService();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.contribution != null;
    
    _nameController = TextEditingController(text: widget.contribution?.contributorName ?? '');
    _amountController = TextEditingController(text: isEditing ? widget.contribution!.amount.toString() : '');
    _remarksController = TextEditingController(text: widget.contribution?.remarks ?? '');

    if (isEditing) {
      _selectedDate = DateTime.parse(widget.contribution!.contributionDate);
      final parts = widget.contribution!.contributionTime.split(':');
      _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final formattedDate = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final formattedTime = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00";

    final item = Contribution(
      contributorName: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      remarks: _remarksController.text.trim(),
      contributionDate: formattedDate,
      contributionTime: formattedTime,
    );

    try {
      if (widget.contribution != null) {
        await _service.updateContribution(widget.contribution!.id!, item);
      } else {
        await _service.addContribution(item);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error saving data: $e")));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contribution != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Contribution" : "Add Contribution")),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Contributor Name (Optional)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Amount  *", border: OutlineInputBorder()),
                      validator: (v) => (v == null || double.tryParse(v) == null) ? "Enter a valid numeric price amount" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Remarks / Notes", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                      title: Text("Date: ${_selectedDate.toLocal()}".split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                      title: Text("Time: ${_selectedTime.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: _pickTime,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(isEditing ? "Update Entry" : "Save Entry", style: const TextStyle(fontSize: 16)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}