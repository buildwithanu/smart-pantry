import 'package:flutter/foundation.dart';
import '../models/pantry_item.dart';
import '../services/database_service.dart';

class PantryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<PantryItem> _items = [];
  bool _isLoading = false;

  List<PantryItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _databaseService.getAllItems();
    } catch (e) {
      debugPrint('Error loading items: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(PantryItem item) async {
    try {
      await _databaseService.insertItem(item);
      _items.add(item);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding item: $e');
    }
  }

  Future<void> updateItem(PantryItem item) async {
    try {
      await _databaseService.updateItem(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _databaseService.deleteItem(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }
} 