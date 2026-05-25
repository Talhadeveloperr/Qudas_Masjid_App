// lib/screens/expenditures/add_expenditure_screen.dart
import 'package:flutter/material.dart';
import '../../models/expenditure_model.dart';
import '../../services/expenditure_service.dart';

class AddExpenditureScreen extends StatefulWidget {
  final Expenditure? expenditure;

  const AddExpenditureScreen({super.key, this.expenditure});

  @override
  State<AddExpenditureScreen> createState() => _AddExpenditureScreenState();
}

class _AddExpenditureScreenState extends State<AddExpenditureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ExpenditureService();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _paidToController;
  late TextEditingController _detailsController;
  late TextEditingController _remarksController;
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.expenditure != null;
    
    _titleController = TextEditingController(text: widget.expenditure?.title ?? '');
    _amountController = TextEditingController(text: isEditing ? widget.expenditure!.paymentAmount.toString() : '');
    _paidToController = TextEditingController(text: widget.expenditure?.paidTo ?? '');
    _detailsController = TextEditingController(text: widget.expenditure?.details ?? '');
    _remarksController = TextEditingController(text: widget.expenditure?.remarks ?? '');

    if (isEditing) {
      _selectedDate = DateTime.parse(widget.expenditure!.expenditureDate);
      final parts = widget.expenditure!.expenditureTime.split(':');
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

    final item = Expenditure(
      title: _titleController.text.trim(),
      paymentAmount: double.parse(_amountController.text.trim()),
      paidTo: _paidToController.text.trim(),
      details: _detailsController.text.trim(),
      remarks: _remarksController.text.trim(),
      expenditureDate: formattedDate,
      expenditureTime: formattedTime,
    );

    try {
      if (widget.expenditure != null) {
        await _service.updateExpenditure(widget.expenditure!.id!, item);
      } else {
        await _service.addExpenditure(item);
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
    final isEditing = widget.expenditure != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Expenditure" : "Add Expenditure")),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Title *", border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? "Enter a title" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Payment Amount *", border: OutlineInputBorder()),
                      validator: (v) => (v == null || double.tryParse(v) == null) ? "Enter a valid numeric amount" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paidToController,
                      decoration: const InputDecoration(labelText: "Paid To (Optional)", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Details", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _remarksController,
                      maxLines: 2,
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
