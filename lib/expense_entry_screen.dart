import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseEntryScreen extends StatefulWidget {
  @override
  _ExpenseEntryScreenState createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends State<ExpenseEntryScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedCategory = "Food";
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment"];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter an amount")));
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0.0;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("expenses")
        .add({
      "amount": amount,
      "category": _selectedCategory,
      "date": _selectedDate.toIso8601String(),
      "notes": _notesController.text,
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Expense added successfully")));
    _amountController.clear();
    _notesController.clear();
    setState(() {
      _selectedCategory = "Food";
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: _selectedCategory,
              items: _categories.map((String category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue.toString();
                });
              },
              decoration: InputDecoration(labelText: "Category", border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _selectDate(context),
              icon: Icon(Icons.calendar_today),
              label: Text("Select Date: ${_selectedDate.toLocal()}".split(' ')[0]),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: "Notes (Optional)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text("Save Expense"),
            ),
          ],
        ),
      ),
    );
  }
}
