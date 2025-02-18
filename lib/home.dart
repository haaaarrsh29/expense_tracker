import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_entry_screen.dart';
import 'expense_history_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _financialGoals = {}; // Category-wise goals
  Map<String, double> _spentAmounts = {}; // Category-wise spent amounts

  @override
  void initState() {
    super.initState();
    _fetchGoalsAndExpenses();
  }

  Future<void> _fetchGoalsAndExpenses() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        _financialGoals = userDoc["goals"] ?? {};
        _spentAmounts = userDoc["spent"] != null
            ? Map<String, double>.from(userDoc["spent"])
            : {};
      });
    }
  }

  Future<void> _setCategoryGoals() async {
    Map<String, TextEditingController> controllers = {
      "Food": TextEditingController(),
      "Transport": TextEditingController(),
      "Shopping": TextEditingController(),
      "Entertainment": TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Financial Goals"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: controllers.entries.map((entry) {
            return TextField(
              controller: entry.value,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "${entry.key} Goal"),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Map<String, dynamic> updatedGoals = {};
                controllers.forEach((key, controller) {
                  if (controller.text.isNotEmpty) {
                    updatedGoals[key] = double.tryParse(controller.text) ?? 0;
                  }
                });

                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .set({"goals": updatedGoals}, SetOptions(merge: true));

                setState(() {
                  _financialGoals = updatedGoals;
                });
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSpentAmount(String category) async {
    TextEditingController spentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Spent Amount - $category"),
        content: TextField(
          controller: spentController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Enter Spent Amount"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final User? user = FirebaseAuth.instance.currentUser;
              if (user != null && spentController.text.isNotEmpty) {
                double spentAmount = double.tryParse(spentController.text) ?? 0;
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .set({
                  "spent": {
                    ..._spentAmounts,
                    category: spentAmount,
                  }
                }, SetOptions(merge: true));

                setState(() {
                  _spentAmounts[category] = spentAmount;
                });
              }
              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGoalContainer(),
            SizedBox(height: 15),
            _buildContainer(
              context,
              title: "Add Expense",
              icon: Icons.add,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseEntryScreen()),
                );
              },
            ),
            SizedBox(height: 15),
            _buildContainer(
              context,
              title: "View Expense History",
              icon: Icons.history,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpenseHistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalContainer() {
    return GestureDetector(
      onTap: _setCategoryGoals,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Financial Goals",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ..._financialGoals.entries.map((entry) {
              double spent = _spentAmounts[entry.key] ?? 0;
              return GestureDetector(
                onTap: () => _updateSpentAmount(entry.key),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${entry.key}: ${spent.toStringAsFixed(2)} / ${entry.value.toStringAsFixed(2)}",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: (spent / entry.value).clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Icon(icon, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}
