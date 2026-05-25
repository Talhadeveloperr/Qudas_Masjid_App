//qudas\lib\screens\contributors\add_monthly_payment_screen.dart
import 'package:flutter/material.dart';
import '../../models/contributor_model.dart';
import '../../services/contributor_service.dart';

class AddMonthlyPaymentScreen extends StatefulWidget {
  final Contributor contributor;
  final ContributorPayment? payment;

  const AddMonthlyPaymentScreen({super.key, required this.contributor, this.payment});

  @override
  State<AddMonthlyPaymentScreen> createState() => _AddMonthlyPaymentScreenState();
}

class _AddMonthlyPaymentScreenState extends State<AddMonthlyPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ContributorService _service = ContributorService();

  late TextEditingController _amountController;
  late TextEditingController _remarksController;
  late TextEditingController _monthPaidController;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.payment?.amount.toString() ?? widget.contributor.monthlyCommitment.toString());
    _remarksController = TextEditingController(text: widget.payment?.remarks ?? '');

    // Target tracking month configuration (e.g., "May 2026")
    if (widget.payment != null) {
      _monthPaidController = TextEditingController(text: widget.payment!.monthPaid);
      _selectedDate = DateTime.parse(widget.payment!.contributionDate);
      final rawTime = widget.payment!.contributionTime.split(':');
      _selectedTime = TimeOfDay(hour: int.parse(rawTime[0]), minute: int.parse(rawTime[1]));
    } else {
      _monthPaidController = TextEditingController(text: _getCurrentMonthString());
    }
  }

  String _getCurrentMonthString() {
    final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final now = DateTime.now();
    return "${months[now.month - 1]} ${now.year}";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarksController.dispose();
    _monthPaidController.dispose();
    super.dispose();
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
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _executeSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    try {
      final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final timeString = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00";

      final paymentPayload = ContributorPayment(
        id: widget.payment?.id,
        contributorId: widget.contributor.id!,
        contributorName: widget.contributor.fullName,
        amount: double.parse(_amountController.text.trim()),
        remarks: _remarksController.text.trim().isNotEmpty ? _remarksController.text.trim() : null,
        contributionDate: dateString,
        contributionTime: timeString,
        monthPaid: _monthPaidController.text.trim(),
      );

      if (widget.payment == null) {
        await _service.addPayment(paymentPayload);
      } else {
        await _service.updatePayment(widget.payment!.id!, paymentPayload);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Execution failed: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.payment != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Update Transaction Record" : "Post Contributor Ledger Entry")),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text("Posting tracking row for: ${widget.contributor.fullName}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Payment Amount Received (\Rs)", border: OutlineInputBorder()),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? "Valid receipt amount context required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _monthPaidController,
                    decoration: const InputDecoration(labelText: "Target Allocation Period (e.g., May 2026)", border: OutlineInputBorder()),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Target period missing" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remarksController,
                    decoration: const InputDecoration(labelText: "Execution Notes / Remarks", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                    leading: const Icon(Icons.calendar_today),
                    title: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                    leading: const Icon(Icons.access_time),
                    title: Text("Time: ${_selectedTime.format(context)}"),
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _executeSave,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.teal),
                    child: Text(isEdit ? "Commit Allocation Changes" : "Save Transaction Entry", style: const TextStyle(color: Colors.white, fontSize: 16)),
                  )
                ],
              ),
            ),
    );
  }
}