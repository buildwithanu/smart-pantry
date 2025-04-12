import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/pantry_provider.dart';
import '../models/pantry_item.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PantryProvider>().loadItems());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Pantry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              // TODO: Implement language selection
            },
          ),
        ],
      ),
      body: Consumer<PantryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.kitchen, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Your pantry is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _navigateToAddItem(context),
                    child: const Text('Add your first item'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return _buildItemTile(context, item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItem(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, PantryItem item) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _editItem(context, item),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) => _deleteItem(context, item),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.kitchen),
        ),
        title: Text(item.name),
        subtitle: Text('${item.quantity} ${item.unit}'),
        trailing: Text(
          item.category,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  void _navigateToAddItem(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddItemScreen(),
      ),
    );

    if (result != null && result is PantryItem) {
      context.read<PantryProvider>().addItem(result);
    }
  }

  void _editItem(BuildContext context, PantryItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemScreen(item: item),
      ),
    );

    if (result != null && result is PantryItem) {
      context.read<PantryProvider>().updateItem(result);
    }
  }

  void _deleteItem(BuildContext context, PantryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<PantryProvider>().deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 