import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();

    String selectedUnit = 'kg';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedUnit,
              items: ['kg', 'ltr', 'pcs', 'pack']
                  .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  selectedUnit = val;
                }
              },
              decoration: const InputDecoration(labelText: 'Unit'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text.trim();
                String qty = qtyController.text.trim();

                if (name.isEmpty || qty.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                Navigator.pop(context, {
                  'name': name,
                  'qty': qty,
                  'unit': selectedUnit,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add Item'),
            )
          ],
        ),
      ),
    );
  }
}
