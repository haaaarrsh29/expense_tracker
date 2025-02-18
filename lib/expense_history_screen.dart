import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense History")),
      body: ExpenseList(),
    );
  }
}

class ExpenseList extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("expenses")
        .orderBy("timestamp", descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchExpenses(),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No expenses found."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var expense = snapshot.data![index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                title: Text("${expense["category"]} - ₹${expense["amount"]}"),
                subtitle: Text("${expense["date"]} • ${expense["notes"] ?? 'No notes'}"),
                leading: Icon(Icons.money),
              ),
            );
          },
        );
      },
    );
  }
}
